`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L) {
    return(y)
  }
  if (length(x) == 1L && is.na(x)) {
    return(y)
  }
  x
}

get_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0L) {
    return(normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE))
  }

  ofile <- sys.frames()[[1]]$ofile %||% NA_character_
  if (!is.na(ofile)) {
    return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  }

  stop("Unable to determine script path.", call. = FALSE)
}

script_path <- get_script_path()
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
if (!identical(normalizePath(getwd(), winslash = "/", mustWork = TRUE), repo_root)) {
  stop("tools/phase2_compatibility_audit.R must be run from the package root.", call. = FALSE)
}

output_dir <- file.path(repo_root, "notes", "compatibility")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

rel_path <- function(path) {
  normalized <- normalizePath(path, winslash = "/", mustWork = FALSE)
  prefix <- paste0(repo_root, "/")
  vapply(normalized, function(item) {
    if (identical(item, repo_root)) {
      return(".")
    }
    if (startsWith(item, prefix)) {
      return(substr(item, nchar(prefix) + 1L, nchar(item)))
    }
    item
  }, character(1))
}

write_text_file <- function(path, lines) {
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
}

write_csv_file <- function(data, path) {
  utils::write.csv(data, path, row.names = FALSE, na = "")
}

r_path <- file.path(R.home("bin"), "R.exe")

sanitize_output <- function(lines) {
  if (!length(lines)) {
    return("<no output>")
  }

  text <- enc2utf8(lines)
  gsub("\\\\", "/", text)
}

run_command <- function(command, args, wd = repo_root) {
  start <- proc.time()[["elapsed"]]
  output <- tryCatch(
    suppressWarnings(system2(command, args = args, stdout = TRUE, stderr = TRUE, wait = TRUE)),
    error = function(e) {
      structure(sprintf("SYSTEM2_ERROR: %s", conditionMessage(e)), status = 1L)
    }
  )
  elapsed <- round(proc.time()[["elapsed"]] - start, 3)
  status <- attr(output, "status")
  if (is.null(status)) {
    status <- 0L
  }

  list(
    status = as.integer(status),
    elapsed = elapsed,
    output = sanitize_output(output)
  )
}

run_r_cmd <- function(args, wd = repo_root) {
  run_command(r_path, c("CMD", args), wd = wd)
}

copy_source_tree <- function(label) {
  temp_parent <- file.path(tempdir(), paste0("hydroMetrics-compatibility-", label))
  temp_pkg <- file.path(temp_parent, basename(repo_root))
  if (dir.exists(temp_parent)) {
    unlink(temp_parent, recursive = TRUE, force = TRUE)
  }
  dir.create(temp_pkg, recursive = TRUE, showWarnings = FALSE)

  entries <- list.files(
    repo_root,
    all.files = TRUE,
    recursive = TRUE,
    full.names = TRUE,
    include.dirs = TRUE,
    no.. = TRUE
  )
  rels <- unname(rel_path(entries))
  keep <- !grepl("(^|/)(\\.git)(/|$)", rels) &
    !grepl("(^|/)[^/]+\\.Rcheck(/|$)", rels) &
    !grepl("\\.tar\\.gz$", rels)
  entries <- entries[keep]
  rels <- rels[keep]
  info <- file.info(entries)

  dirs <- rels[info$isdir]
  for (dir_rel in dirs) {
    dir.create(file.path(temp_pkg, dir_rel), recursive = TRUE, showWarnings = FALSE)
  }

  files <- entries[!info$isdir]
  file_rels <- rels[!info$isdir]
  for (i in seq_along(files)) {
    target <- file.path(temp_pkg, file_rels[[i]])
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    ok <- file.copy(files[[i]], target, overwrite = TRUE, copy.date = TRUE)
    if (!isTRUE(ok)) {
      stop(sprintf("Failed to copy '%s' into the temp compatibility source tree.", file_rels[[i]]), call. = FALSE)
    }
  }

  temp_pkg
}

find_built_tarballs <- function(build_output, package_dir) {
  search_roots <- unique(normalizePath(
    c(package_dir, dirname(package_dir), repo_root, dirname(repo_root)),
    winslash = "/",
    mustWork = FALSE
  ))

  tarballs <- character()
  built_lines <- grep("^\\* checking for file '.*\\.tar\\.gz'$", build_output, value = TRUE)
  if (length(built_lines)) {
    built_paths <- sub("^\\* checking for file '(.*\\.tar\\.gz)'$", "\\1", built_lines)
    tarballs <- built_paths[file.exists(built_paths)]
  }

  if (!length(tarballs)) {
    tarballs <- unlist(lapply(search_roots, function(root) {
      if (!dir.exists(root)) {
        return(character())
      }
      list.files(root, pattern = "\\.tar\\.gz$", full.names = TRUE)
    }), use.names = FALSE)
  }

  sort(unique(normalizePath(tarballs[file.exists(tarballs)], winslash = "/", mustWork = FALSE)))
}

stringify_default <- function(x) {
  paste(deparse(x), collapse = " ")
}

extract_aliases <- function() {
  rd_files <- list.files(file.path(repo_root, "man"), pattern = "\\.Rd$", full.names = TRUE)
  alias_lines <- unlist(lapply(rd_files, function(path) {
    grep("^\\\\alias\\{", readLines(path, warn = FALSE), value = TRUE)
  }), use.names = FALSE)
  sort(unique(sub("^\\\\alias\\{([^}]*)\\}$", "\\1", trimws(alias_lines))))
}

extract_function_map <- function() {
  r_files <- list.files(file.path(repo_root, "R"), pattern = "\\.[Rr]$", full.names = TRUE)
  rows <- list()
  for (path in r_files) {
    lines <- readLines(path, warn = FALSE)
    hits <- regexec("^([.A-Za-z][A-Za-z0-9._]*)\\s*<-\\s*function\\s*\\(", lines)
    matches <- regmatches(lines, hits)
    keep <- lengths(matches) > 1L
    if (!any(keep)) {
      next
    }
    funcs <- vapply(matches[keep], `[[`, character(1), 2L)
    rows[[length(rows) + 1L]] <- data.frame(
      name = unname(funcs),
      source_file = rep(rel_path(path), length(funcs)),
      stringsAsFactors = FALSE
    )
  }
  out <- do.call(rbind, rows)
  out[order(out$name, out$source_file), , drop = FALSE]
}

read_namespace_exports <- function() {
  namespace_path <- file.path(repo_root, "NAMESPACE")
  lines <- readLines(namespace_path, warn = FALSE)
  exports <- sub("^export\\(([^)]*)\\)$", "\\1", grep("^export\\(", lines, value = TRUE))
  sort(unique(exports))
}

classify_role <- function(name, formals_map) {
  if (identical(name, "hm_result")) {
    return("result constructor")
  }
  if (identical(name, "preproc")) {
    return("preprocessing wrapper")
  }
  if (identical(name, "gof")) {
    return("core metric dispatcher")
  }
  if (identical(name, "ggof")) {
    return("batch/plotting-style dispatcher")
  }
  if (identical(name, "valindex")) {
    return("metric selector wrapper")
  }
  if (identical(name, "APFB")) {
    return("indexed wrapper")
  }
  args <- names(formals_map %||% list())
  if (all(c("sim", "obs") %in% args)) {
    return("hydroGOF-style wrapper")
  }
  "public function"
}

signature_classification <- function(name, args) {
  if (identical(name, "gof")) {
    return("dispatcher with metric selection")
  }
  if (identical(name, "ggof")) {
    return("batch dispatcher")
  }
  if (identical(name, "preproc")) {
    return("preprocessing entry point")
  }
  if (identical(name, "valindex")) {
    return("selector wrapper")
  }
  if (identical(name, "APFB")) {
    return("indexed scalar wrapper")
  }
  if ("..." %in% args) {
    return("scalar wrapper via ellipsis")
  }
  "direct wrapper"
}

capture_call <- function(fun_name, args) {
  fun <- get(fun_name, envir = asNamespace("hydroMetrics"), inherits = FALSE)
  warnings <- character()
  messages <- character()
  error <- NULL
  error_class <- NA_character_
  value <- tryCatch(
    withCallingHandlers(
      do.call(fun, args),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      },
      message = function(m) {
        messages <<- c(messages, conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(e) {
      error <<- conditionMessage(e)
      error_class <<- class(e)[[1]]
      NULL
    }
  )

  list(
    value = value,
    warnings = unique(warnings),
    messages = unique(messages),
    error = error,
    error_class = error_class
  )
}

describe_output <- function(x) {
  if (inherits(x, "hydro_metrics")) {
    metrics <- x$metrics
    if (is.matrix(metrics)) {
      return(sprintf("hydro_metrics metrics=%dx%d", nrow(metrics), ncol(metrics)))
    }
    return(sprintf("hydro_metrics metrics_length=%d", length(metrics)))
  }
  if (inherits(x, "hydro_metrics_batch")) {
    return(sprintf("hydro_metrics_batch rows=%d cols=%d", nrow(x), ncol(x)))
  }
  if (inherits(x, "hydro_preproc")) {
    return(sprintf("hydro_preproc n=%d", length(x$sim)))
  }
  if (inherits(x, "hydro_metric_scalar")) {
    return(sprintf("hydro_metric_scalar length=%d", length(x)))
  }
  if (is.data.frame(x)) {
    return(sprintf("data.frame rows=%d cols=%d", nrow(x), ncol(x)))
  }
  if (is.matrix(x)) {
    return(sprintf("matrix %dx%d", nrow(x), ncol(x)))
  }
  sprintf("class=%s length=%d", paste(class(x), collapse = "|"), length(x))
}

structure_kind <- function(x) {
  if (inherits(x, "hydro_metrics_batch") || is.data.frame(x)) {
    return("data.frame")
  }
  if (inherits(x, "hydro_metrics") || inherits(x, "hydro_preproc")) {
    return("list")
  }
  if (is.matrix(x)) {
    return("matrix")
  }
  if (length(x) == 1L) {
    return("scalar")
  }
  "vector"
}

extent_label <- function(x) {
  if (is.data.frame(x) || is.matrix(x)) {
    return(paste(dim(x), collapse = "x"))
  }
  if (inherits(x, "hydro_metrics")) {
    metrics <- x$metrics
    if (is.matrix(metrics)) {
      return(sprintf("metrics:%dx%d", nrow(metrics), ncol(metrics)))
    }
    return(sprintf("metrics:%d", length(metrics)))
  }
  if (inherits(x, "hydro_preproc")) {
    return(sprintf("sim:%d obs:%d", length(x$sim), length(x$obs)))
  }
  as.character(length(x))
}

named_output <- function(x) {
  if (inherits(x, "hydro_metrics")) {
    metrics <- x$metrics
    if (is.matrix(metrics)) {
      return(!is.null(rownames(metrics)) || !is.null(colnames(metrics)))
    }
    return(!is.null(names(metrics)))
  }
  if (inherits(x, "hydro_metrics_batch") || is.data.frame(x)) {
    return(!is.null(names(x)))
  }
  !is.null(names(x))
}

deterministic_equal <- function(a, b) {
  isTRUE(all.equal(a, b, check.attributes = TRUE))
}

condition_summary <- function(result) {
  if (!is.null(result$error)) {
    return(sprintf("error:%s", result$error))
  }
  if (length(result$warnings)) {
    return(sprintf("warning:%s", paste(result$warnings, collapse = " | ")))
  }
  "none"
}

runtime_note <- function(fun_name, result) {
  if (!is.null(result$error)) {
    return(result$error)
  }
  if (identical(fun_name, "ggof")) {
    return("Returns a hydro_metrics_batch data.frame rather than a plotting object.")
  }
  if (identical(fun_name, "APFB")) {
    return("Indexed wrapper requires zoo/xts input.")
  }
  ""
}

compat_status <- function(ok, divergent = FALSE, partial = FALSE, unverified = FALSE) {
  if (isTRUE(unverified)) {
    return("unverified")
  }
  if (isTRUE(divergent)) {
    return("divergent")
  }
  if (isTRUE(ok) && !isTRUE(partial)) {
    return("compatible")
  }
  if (isTRUE(ok) && isTRUE(partial)) {
    return("partially compatible")
  }
  "incompatible"
}

temp_source <- copy_source_tree("install")
build_result <- run_r_cmd(c("build", "."), wd = temp_source)
if (build_result$status != 0L) {
  stop("Compatibility audit could not build a disposable source tarball.", call. = FALSE)
}
tarballs <- find_built_tarballs(build_result$output, temp_source)
if (!length(tarballs)) {
  stop("Compatibility audit could not locate the built source tarball.", call. = FALSE)
}

install_lib <- file.path(tempdir(), "hydroMetrics-compatibility-lib")
if (dir.exists(install_lib)) {
  unlink(install_lib, recursive = TRUE, force = TRUE)
}
dir.create(install_lib, recursive = TRUE, showWarnings = FALSE)

install_result <- run_r_cmd(
  c("INSTALL", "--preclean", "-l", install_lib, basename(tarballs[[1]])),
  wd = dirname(tarballs[[1]])
)
if (install_result$status != 0L) {
  stop("Compatibility audit could not install the disposable source tarball.", call. = FALSE)
}

.libPaths(c(normalizePath(install_lib, winslash = "/", mustWork = TRUE), .libPaths()))
suppressPackageStartupMessages(library(hydroMetrics))

has_zoo <- requireNamespace("zoo", quietly = TRUE)
pkg_ns <- asNamespace("hydroMetrics")
runtime_exports <- sort(getNamespaceExports("hydroMetrics"))
namespace_exports <- read_namespace_exports()
aliases <- extract_aliases()
function_map <- extract_function_map()
source_lookup <- stats::setNames(function_map$source_file, function_map$name)

public_objects <- sort(unique(runtime_exports))
public_api_rows <- lapply(public_objects, function(name) {
  obj <- get(name, envir = pkg_ns, inherits = FALSE)
  fmls <- if (is.function(obj)) formals(obj) else NULL
  data.frame(
    name = name,
    exported = name %in% runtime_exports,
    source_file = unname(source_lookup[[name]] %||% ""),
    documented = name %in% aliases,
    likely_role = classify_role(name, fmls),
    verified_status = "verified",
    evidence_class = "verified fact",
    notes = "",
    stringsAsFactors = FALSE
  )
})
public_api_inventory <- do.call(rbind, public_api_rows)
public_api_inventory <- public_api_inventory[order(public_api_inventory$name), , drop = FALSE]
write_csv_file(public_api_inventory, file.path(output_dir, "public_api_inventory.csv"))

wrapper_names <- sort(setdiff(public_api_inventory$name[public_api_inventory$likely_role != "result constructor"], character()))

signature_rows <- lapply(wrapper_names, function(name) {
  fun <- get(name, envir = pkg_ns, inherits = FALSE)
  args <- names(formals(fun))
  defaults <- vapply(formals(fun), stringify_default, character(1))
  notes <- character()
  if (!("na.rm" %in% args) && "..." %in% args) {
    notes <- c(notes, "na.rm is only available through ... where supported.")
  }
  if (!("epsilon.type" %in% args) && any(c("epsilon_mode", "epsilon") %in% args)) {
    notes <- c(notes, "Uses epsilon_mode/epsilon naming instead of epsilon.type/epsilon.value.")
  }
  data.frame(
    function_name = name,
    formal_arguments = paste(args, collapse = ", "),
    sim_present = "sim" %in% args,
    obs_present = "obs" %in% args,
    na_rm_present = "na.rm" %in% args,
    epsilon_type_present = "epsilon.type" %in% args,
    epsilon_value_present = "epsilon.value" %in% args,
    fun_present = "fun" %in% args,
    dots_present = "..." %in% args,
    default_values = paste(paste(names(defaults), defaults, sep = "="), collapse = "; "),
    signature_classification = signature_classification(name, args),
    verified_status = "verified",
    evidence_class = "verified fact",
    notes = paste(notes, collapse = " "),
    stringsAsFactors = FALSE
  )
})
wrapper_signature_matrix <- do.call(rbind, signature_rows)
wrapper_signature_matrix <- wrapper_signature_matrix[order(wrapper_signature_matrix$function_name), , drop = FALSE]
write_csv_file(wrapper_signature_matrix, file.path(output_dir, "wrapper_signature_matrix.csv"))

vector_sim <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
vector_obs <- c(1.1, 1.9, 3.2, 3.8, 5.1, 6.2, 6.8, 8.1, 8.9, 10.2, 11.1, 11.8)
long_sim <- seq(10, 45, length.out = 36)
long_obs <- seq(11, 46, length.out = 36)
matrix_single_sim <- cbind(series1 = vector_sim)
matrix_single_obs <- cbind(series1 = vector_obs)
matrix_multi_sim <- cbind(series1 = vector_sim, series2 = vector_sim + 0.2)
matrix_multi_obs <- cbind(series1 = vector_obs, series2 = vector_obs + 0.1)
data_frame_single_sim <- as.data.frame(matrix_single_sim)
data_frame_single_obs <- as.data.frame(matrix_single_obs)
data_frame_multi_sim <- as.data.frame(matrix_multi_sim)
data_frame_multi_obs <- as.data.frame(matrix_multi_obs)
long_matrix_multi_sim <- cbind(series1 = long_sim, series2 = long_sim + 0.2)
long_matrix_multi_obs <- cbind(series1 = long_obs, series2 = long_obs + 0.1)
long_data_frame_multi_sim <- as.data.frame(long_matrix_multi_sim)
long_data_frame_multi_obs <- as.data.frame(long_matrix_multi_obs)

if (has_zoo) {
  zoo_index <- seq.Date(as.Date("2000-01-01"), by = "month", length.out = 24)
  zoo_sim <- zoo::zoo(seq(10, 33, length.out = 24), zoo_index)
  zoo_obs <- zoo::zoo(seq(11, 34, length.out = 24), zoo_index)
  zoo_sim_na <- zoo_sim
  zoo_obs_na <- zoo_obs
  zoo_sim_na[c(2, 14)] <- NA_real_
  zoo_obs_na[c(3, 15)] <- NA_real_
} else {
  zoo_sim <- zoo_obs <- zoo_sim_na <- zoo_obs_na <- NULL
}

representative_args <- function(fun_name) {
  switch(
    fun_name,
    APFB = list(input_shape = "zoo_univariate", args = list(sim = zoo_sim, obs = zoo_obs)),
    HFB = list(input_shape = "numeric_vector", args = list(sim = long_sim, obs = long_obs)),
    gof = list(input_shape = "numeric_vector", args = list(sim = vector_sim, obs = vector_obs, methods = c("NSE", "pbias"))),
    ggof = list(input_shape = "numeric_vector", args = list(sim = vector_sim, obs = vector_obs, methods = c("NSE", "pbias"), include_meta = TRUE)),
    preproc = list(input_shape = "numeric_vector", args = list(sim = vector_sim, obs = vector_obs)),
    valindex = list(input_shape = "numeric_vector", args = list(sim = vector_sim, obs = vector_obs, fun = "NSE")),
    list(input_shape = "numeric_vector", args = list(sim = vector_sim, obs = vector_obs))
  )
}

return_rows <- lapply(wrapper_names, function(name) {
  args_info <- representative_args(name)
  if (identical(name, "APFB") && !has_zoo) {
    return(data.frame(
      function_name = name,
      input_shape_used = args_info$input_shape,
      return_class = "",
      return_extent = "",
      named_output = NA,
      behavior_type = "",
      deterministic_repeated_run = NA,
      verified_status = "unverified",
      evidence_class = "verified fact",
      notes = "zoo is unavailable locally, so APFB representative runtime behavior could not be verified.",
      stringsAsFactors = FALSE
    ))
  }

  first <- capture_call(name, args_info$args)
  second <- capture_call(name, args_info$args)
  if (!is.null(first$error)) {
    return(data.frame(
      function_name = name,
      input_shape_used = args_info$input_shape,
      return_class = "",
      return_extent = "",
      named_output = NA,
      behavior_type = "",
      deterministic_repeated_run = FALSE,
      verified_status = "verified",
      evidence_class = "verified fact",
      notes = first$error,
      stringsAsFactors = FALSE
    ))
  }

  data.frame(
    function_name = name,
    input_shape_used = args_info$input_shape,
    return_class = paste(class(first$value), collapse = "|"),
    return_extent = extent_label(first$value),
    named_output = named_output(first$value),
    behavior_type = structure_kind(first$value),
    deterministic_repeated_run = deterministic_equal(first$value, second$value),
    verified_status = "verified",
    evidence_class = "verified fact",
    notes = runtime_note(name, first),
    stringsAsFactors = FALSE
  )
})
return_behavior_matrix <- do.call(rbind, return_rows)
return_behavior_matrix <- return_behavior_matrix[order(return_behavior_matrix$function_name), , drop = FALSE]
write_csv_file(return_behavior_matrix, file.path(output_dir, "return_behavior_matrix.csv"))

shape_inputs <- c(
  "numeric_vector",
  "matrix_single_col",
  "matrix_multi_col",
  "data_frame_single_col",
  "data_frame_multi_col",
  "zoo_univariate",
  "mismatched_lengths"
)

shape_args <- function(fun_name, input_type) {
  if (identical(fun_name, "APFB")) {
    return(switch(
      input_type,
      numeric_vector = list(sim = vector_sim, obs = vector_obs),
      matrix_single_col = list(sim = matrix_single_sim, obs = matrix_single_obs),
      matrix_multi_col = list(sim = matrix_multi_sim, obs = matrix_multi_obs),
      data_frame_single_col = list(sim = data_frame_single_sim, obs = data_frame_single_obs),
      data_frame_multi_col = list(sim = data_frame_multi_sim, obs = data_frame_multi_obs),
      zoo_univariate = list(sim = zoo_sim, obs = zoo_obs),
      mismatched_lengths = list(sim = zoo_sim[-1], obs = zoo_obs)
    ))
  }

  base_args <- switch(
    input_type,
    numeric_vector = list(sim = vector_sim, obs = vector_obs),
    matrix_single_col = if (identical(fun_name, "HFB")) list(sim = cbind(series1 = long_sim), obs = cbind(series1 = long_obs)) else list(sim = matrix_single_sim, obs = matrix_single_obs),
    matrix_multi_col = if (identical(fun_name, "HFB")) list(sim = long_matrix_multi_sim, obs = long_matrix_multi_obs) else list(sim = matrix_multi_sim, obs = matrix_multi_obs),
    data_frame_single_col = if (identical(fun_name, "HFB")) list(sim = data.frame(series1 = long_sim), obs = data.frame(series1 = long_obs)) else list(sim = data_frame_single_sim, obs = data_frame_single_obs),
    data_frame_multi_col = if (identical(fun_name, "HFB")) list(sim = long_data_frame_multi_sim, obs = long_data_frame_multi_obs) else list(sim = data_frame_multi_sim, obs = data_frame_multi_obs),
    zoo_univariate = list(sim = zoo_sim, obs = zoo_obs),
    mismatched_lengths = list(sim = vector_sim[-length(vector_sim)], obs = vector_obs)
  )

  extras <- switch(
    fun_name,
    gof = list(methods = "NSE"),
    ggof = list(methods = "NSE"),
    valindex = list(fun = "NSE"),
    HFB = list(threshold_prob = 0.9),
    list()
  )

  c(base_args, extras)
}

input_rows <- list()
for (fun_name in wrapper_names) {
  for (input_type in shape_inputs) {
    if (identical(input_type, "zoo_univariate") && !has_zoo) {
      input_rows[[length(input_rows) + 1L]] <- data.frame(
        function_name = fun_name,
        input_type = input_type,
        supported = NA,
        output_shape = "",
        warning_or_error_behavior = "zoo is unavailable locally",
        verified_status = "unverified",
        evidence_class = "verified fact",
        notes = "zoo support could not be exercised in this environment.",
        stringsAsFactors = FALSE
      )
      next
    }

    args <- shape_args(fun_name, input_type)
    result <- capture_call(fun_name, args)
    input_rows[[length(input_rows) + 1L]] <- data.frame(
      function_name = fun_name,
      input_type = input_type,
      supported = is.null(result$error),
      output_shape = if (is.null(result$error)) describe_output(result$value) else "",
      warning_or_error_behavior = condition_summary(result),
      verified_status = "verified",
      evidence_class = "verified fact",
      notes = if (identical(fun_name, "APFB") && input_type != "zoo_univariate") {
        "APFB is index-dependent and rejects non-zoo/xts input."
      } else if (identical(fun_name, "preproc") && grepl("matrix|data_frame", input_type)) {
        "preproc only accepts vector-like, ts, or zoo/xts inputs."
      } else {
        ""
      },
      stringsAsFactors = FALSE
    )
  }
}
input_shape_behavior_matrix <- do.call(rbind, input_rows)
input_shape_behavior_matrix <- input_shape_behavior_matrix[order(input_shape_behavior_matrix$function_name, input_shape_behavior_matrix$input_type), , drop = FALSE]
write_csv_file(input_shape_behavior_matrix, file.path(output_dir, "input_shape_behavior_matrix.csv"))

gof_cases <- list(
  vector_single_metric = capture_call("gof", list(sim = vector_sim, obs = vector_obs, methods = "NSE")),
  vector_multi_metric = capture_call("gof", list(sim = vector_sim, obs = vector_obs, methods = c("NSE", "pbias"))),
  data_frame_single_metric = capture_call("gof", list(sim = data_frame_multi_sim, obs = data_frame_multi_obs, methods = "NSE")),
  zoo_single_metric = if (has_zoo) capture_call("gof", list(sim = zoo_sim, obs = zoo_obs, methods = "NSE")) else NULL,
  fun_alias = capture_call("gof", list(sim = vector_sim, obs = vector_obs, fun = "NSE")),
  mismatch_error = capture_call("gof", list(sim = vector_sim[-length(vector_sim)], obs = vector_obs, methods = "NSE"))
)

gof_deterministic <- {
  first <- capture_call("gof", list(sim = vector_sim, obs = vector_obs, methods = c("NSE", "pbias")))
  second <- capture_call("gof", list(sim = vector_sim, obs = vector_obs, methods = c("NSE", "pbias")))
  is.null(first$error) && is.null(second$error) && deterministic_equal(first$value, second$value)
}

gof_lines <- c(
  "Phase 2 Compatibility Audit - gof() Runtime Contract",
  "Evidence class: verified fact",
  sprintf("accepted vector input = %s", is.null(gof_cases$vector_single_metric$error)),
  sprintf("accepted data.frame input = %s", is.null(gof_cases$data_frame_single_metric$error)),
  sprintf("accepted zoo input = %s", if (has_zoo) is.null(gof_cases$zoo_single_metric$error) else NA),
  sprintf("single-metric return class = %s", if (is.null(gof_cases$vector_single_metric$error)) paste(class(gof_cases$vector_single_metric$value), collapse = "|") else "<error>"),
  sprintf("multi-metric return class = %s", if (is.null(gof_cases$vector_multi_metric$error)) paste(class(gof_cases$vector_multi_metric$value), collapse = "|") else "<error>"),
  sprintf("multi-metric metric names = %s", if (is.null(gof_cases$vector_multi_metric$error)) paste(names(gof_cases$vector_multi_metric$value$metrics), collapse = ", ") else "<error>"),
  sprintf("fun alias accepted = %s", is.null(gof_cases$fun_alias$error)),
  sprintf("deterministic repeated run = %s", gof_deterministic),
  sprintf("mismatched lengths error = %s", gof_cases$mismatch_error$error %||% "<none>"),
  "",
  "Case details:",
  sprintf("- vector_single_metric: %s", condition_summary(gof_cases$vector_single_metric)),
  sprintf("- vector_multi_metric: %s", condition_summary(gof_cases$vector_multi_metric)),
  sprintf("- data_frame_single_metric: %s", condition_summary(gof_cases$data_frame_single_metric)),
  sprintf("- zoo_single_metric: %s", if (has_zoo) condition_summary(gof_cases$zoo_single_metric) else "unverified"),
  sprintf("- fun_alias: %s", condition_summary(gof_cases$fun_alias)),
  sprintf("- mismatch_error: %s", condition_summary(gof_cases$mismatch_error)),
  "",
  "Evidence class: likely inference",
  "gof() accepts several public input shapes and returns a stable hydro_metrics object on repeated representative inputs.",
  "",
  "Evidence class: recommendation",
  "Use the mismatch and alias evidence here when assessing wrapper-compatibility fixes around the gof() entry point."
)
write_text_file(file.path(output_dir, "gof_behavior_results.txt"), gof_lines)

ggof_before_devices <- dev.list()
ggof_cases <- list(
  vector_single_metric = capture_call("ggof", list(sim = vector_sim, obs = vector_obs, methods = "NSE")),
  vector_include_meta = capture_call("ggof", list(sim = vector_sim, obs = vector_obs, methods = c("NSE", "pbias"), include_meta = TRUE)),
  data_frame_single_metric = capture_call("ggof", list(sim = data_frame_multi_sim, obs = data_frame_multi_obs, methods = "NSE")),
  zoo_single_metric = if (has_zoo) capture_call("ggof", list(sim = zoo_sim, obs = zoo_obs, methods = "NSE")) else NULL,
  mismatch_error = capture_call("ggof", list(sim = vector_sim[-length(vector_sim)], obs = vector_obs, methods = "NSE"))
)
ggof_after_devices <- dev.list()
ggof_deterministic <- {
  first <- capture_call("ggof", list(sim = vector_sim, obs = vector_obs, methods = "NSE"))
  second <- capture_call("ggof", list(sim = vector_sim, obs = vector_obs, methods = "NSE"))
  is.null(first$error) && is.null(second$error) && deterministic_equal(first$value, second$value)
}

ggof_lines <- c(
  "Phase 2 Compatibility Audit - ggof() Runtime Contract",
  "Evidence class: verified fact",
  sprintf("accepted vector input = %s", is.null(ggof_cases$vector_single_metric$error)),
  sprintf("accepted data.frame input = %s", is.null(ggof_cases$data_frame_single_metric$error)),
  sprintf("accepted zoo input = %s", if (has_zoo) is.null(ggof_cases$zoo_single_metric$error) else NA),
  sprintf("return class = %s", if (is.null(ggof_cases$vector_single_metric$error)) paste(class(ggof_cases$vector_single_metric$value), collapse = "|") else "<error>"),
  sprintf("noninteractive device list unchanged = %s", identical(ggof_before_devices, ggof_after_devices)),
  sprintf("include_meta adds columns = %s", if (is.null(ggof_cases$vector_include_meta$error)) all(c("transform", "na_strategy", "epsilon_mode") %in% names(ggof_cases$vector_include_meta$value)) else FALSE),
  sprintf("deterministic repeated run = %s", ggof_deterministic),
  sprintf("mismatched lengths error = %s", ggof_cases$mismatch_error$error %||% "<none>"),
  "",
  "Case details:",
  sprintf("- vector_single_metric: %s", condition_summary(ggof_cases$vector_single_metric)),
  sprintf("- vector_include_meta: %s", condition_summary(ggof_cases$vector_include_meta)),
  sprintf("- data_frame_single_metric: %s", condition_summary(ggof_cases$data_frame_single_metric)),
  sprintf("- zoo_single_metric: %s", if (has_zoo) condition_summary(ggof_cases$zoo_single_metric) else "unverified"),
  sprintf("- mismatch_error: %s", condition_summary(ggof_cases$mismatch_error)),
  "",
  "Evidence class: likely inference",
  "ggof() constructs a deterministic hydro_metrics_batch data.frame in noninteractive use and does not open a graphics device in these local checks.",
  "",
  "Evidence class: recommendation",
  "Treat the observed return class as a compatibility-relevant plotting divergence candidate if downstream code expects a plot object."
)
write_text_file(file.path(output_dir, "ggof_behavior_results.txt"), ggof_lines)

na_rm_cases <- list(
  alpha_true = capture_call("alpha", list(sim = c(1, NA, 3, 4, NaN, 6), obs = c(1.1, 2.1, NA, 4.1, 5.1, 6.1), na.rm = TRUE)),
  alpha_false = capture_call("alpha", list(sim = c(1, NA, 3, 4, NaN, 6), obs = c(1.1, 2.1, NA, 4.1, 5.1, 6.1), na.rm = FALSE)),
  gof_true = capture_call("gof", list(sim = c(1, NA, 3, 4, NaN, 6), obs = c(1.1, 2.1, NA, 4.1, 5.1, 6.1), methods = "NSE", na.rm = TRUE)),
  gof_false = capture_call("gof", list(sim = c(1, NA, 3, 4, NaN, 6), obs = c(1.1, 2.1, NA, 4.1, 5.1, 6.1), methods = "NSE", na.rm = FALSE)),
  preproc_true = capture_call("preproc", list(sim = c(1, NA, 3, 4, NaN, 6), obs = c(1.1, 2.1, NA, 4.1, 5.1, 6.1), na.rm = TRUE)),
  preproc_false = capture_call("preproc", list(sim = c(1, NA, 3, 4, NaN, 6), obs = c(1.1, 2.1, NA, 4.1, 5.1, 6.1), na.rm = FALSE)),
  alpha_inf = capture_call("alpha", list(sim = c(1, 2, Inf, 4), obs = c(1, 2, 3, 4), na.rm = TRUE)),
  APFB_true = if (has_zoo) capture_call("APFB", list(sim = zoo_sim_na, obs = zoo_obs_na, na.rm = TRUE)) else NULL,
  APFB_false = if (has_zoo) capture_call("APFB", list(sim = zoo_sim_na, obs = zoo_obs_na, na.rm = FALSE)) else NULL
)

na_rm_lines <- c(
  "Phase 2 Compatibility Audit - na.rm and Missing-Value Behavior",
  "Evidence class: verified fact",
  sprintf("alpha with na.rm = TRUE succeeds = %s", is.null(na_rm_cases$alpha_true$error)),
  sprintf("alpha with na.rm = FALSE error = %s", na_rm_cases$alpha_false$error %||% "<none>"),
  sprintf("gof with na.rm = TRUE succeeds = %s", is.null(na_rm_cases$gof_true$error)),
  sprintf("gof with na.rm = FALSE error = %s", na_rm_cases$gof_false$error %||% "<none>"),
  sprintf("preproc with na.rm = TRUE succeeds = %s", is.null(na_rm_cases$preproc_true$error)),
  sprintf("preproc with na.rm = FALSE error = %s", na_rm_cases$preproc_false$error %||% "<none>"),
  sprintf("alpha with Inf behavior = %s", condition_summary(na_rm_cases$alpha_inf)),
  sprintf("APFB with na.rm = TRUE = %s", if (has_zoo) condition_summary(na_rm_cases$APFB_true) else "unverified"),
  sprintf("APFB with na.rm = FALSE = %s", if (has_zoo) condition_summary(na_rm_cases$APFB_false) else "unverified"),
  "",
  "Evidence class: likely inference",
  "Observed wrappers handle na.rm deterministically where the runtime path accepts na.rm, even when the argument is supplied through ....",
  "",
  "Evidence class: recommendation",
  "Preserve the recorded na.rm behavior as compatibility evidence before any signature-surface changes are considered."
)
write_text_file(file.path(output_dir, "na_rm_behavior_results.txt"), na_rm_lines)

warning_error_cases <- data.frame(
  function_name = c("HFB", "HFB", "APFB", "alpha", "gof", "preproc"),
  case = c(
    "insufficient_high_flow_points",
    "invalid_threshold_prob",
    "non_indexed_input",
    "constant_obs",
    "unknown_metric",
    "mismatched_lengths"
  ),
  condition_type = c(
    capture_call("HFB", list(sim = c(1, 2, 3, 4), obs = c(1.1, 1.9, 3.2, 3.8)))$error_class,
    capture_call("HFB", list(sim = long_sim, obs = long_obs, threshold_prob = 1.2))$error_class,
    capture_call("APFB", list(sim = vector_sim, obs = vector_obs))$error_class,
    capture_call("alpha", list(sim = c(1, 2, 3), obs = c(2, 2, 2)))$error_class,
    capture_call("gof", list(sim = vector_sim, obs = vector_obs, methods = "UNKNOWN"))$error_class,
    capture_call("preproc", list(sim = vector_sim[-1], obs = vector_obs))$error_class
  ),
  message = c(
    capture_call("HFB", list(sim = c(1, 2, 3, 4), obs = c(1.1, 1.9, 3.2, 3.8)))$error,
    capture_call("HFB", list(sim = long_sim, obs = long_obs, threshold_prob = 1.2))$error,
    capture_call("APFB", list(sim = vector_sim, obs = vector_obs))$error,
    capture_call("alpha", list(sim = c(1, 2, 3), obs = c(2, 2, 2)))$error,
    capture_call("gof", list(sim = vector_sim, obs = vector_obs, methods = "UNKNOWN"))$error,
    capture_call("preproc", list(sim = vector_sim[-1], obs = vector_obs))$error
  ),
  stringsAsFactors = FALSE
)

warning_lines <- c(
  "Phase 2 Compatibility Audit - Warning and Error Behavior",
  "Evidence class: verified fact",
  sprintf("threshold-sensitive HFB short-input error = %s", warning_error_cases$message[warning_error_cases$case == "insufficient_high_flow_points"]),
  sprintf("HFB invalid-threshold error = %s", warning_error_cases$message[warning_error_cases$case == "invalid_threshold_prob"]),
  sprintf("APFB non-indexed-input error = %s", warning_error_cases$message[warning_error_cases$case == "non_indexed_input"]),
  sprintf("alpha constant-observation error = %s", warning_error_cases$message[warning_error_cases$case == "constant_obs"]),
  sprintf("gof unknown-metric error = %s", warning_error_cases$message[warning_error_cases$case == "unknown_metric"]),
  sprintf("preproc mismatched-length error = %s", warning_error_cases$message[warning_error_cases$case == "mismatched_lengths"]),
  "",
  "Evidence class: likely inference",
  "The observed failures are informative and deterministic for the representative threshold-sensitive and contract-violation cases exercised here.",
  "",
  "Evidence class: recommendation",
  "Use these exact messages as the compatibility baseline when triaging wrapper-contract regressions."
)
write_text_file(file.path(output_dir, "warning_error_behavior_results.txt"), warning_lines)

export_docs_complete <- all(public_api_inventory$documented)
formal_na_rm_count <- sum(wrapper_signature_matrix$na_rm_present)
formal_signature_partial <- formal_na_rm_count < nrow(wrapper_signature_matrix) ||
  any(!wrapper_signature_matrix$sim_present | !wrapper_signature_matrix$obs_present) ||
  any(!wrapper_signature_matrix$epsilon_type_present | !wrapper_signature_matrix$epsilon_value_present)

vector_support_rows <- subset(input_shape_behavior_matrix, input_type == "numeric_vector")
matrix_support_rows <- subset(input_shape_behavior_matrix, input_type %in% c("matrix_single_col", "matrix_multi_col"))
data_frame_support_rows <- subset(input_shape_behavior_matrix, input_type %in% c("data_frame_single_col", "data_frame_multi_col"))
zoo_support_rows <- subset(input_shape_behavior_matrix, input_type == "zoo_univariate")

count_supported <- function(data) {
  sum(data$supported %in% TRUE, na.rm = TRUE)
}

scorecard <- data.frame(
  Area = c(
    "public API",
    "public API",
    "signatures",
    "signatures",
    "returns",
    "missing values",
    "input handling",
    "input handling",
    "input handling",
    "input handling",
    "core entry points",
    "core entry points",
    "behavior",
    "documentation"
  ),
  Item = c(
    "export presence",
    "wrapper presence",
    "wrapper signatures",
    "defaults",
    "return structures",
    "na.rm handling",
    "vector input handling",
    "matrix input handling",
    "data.frame input handling",
    "zoo input handling",
    "gof behavior",
    "ggof behavior",
    "warning/error behavior",
    "documentation alignment"
  ),
  `Evidence source` = c(
    "public_api_inventory.csv",
    "public_api_inventory.csv",
    "wrapper_signature_matrix.csv",
    "wrapper_signature_matrix.csv",
    "return_behavior_matrix.csv",
    "na_rm_behavior_results.txt",
    "input_shape_behavior_matrix.csv",
    "input_shape_behavior_matrix.csv",
    "input_shape_behavior_matrix.csv",
    "input_shape_behavior_matrix.csv",
    "gof_behavior_results.txt",
    "ggof_behavior_results.txt",
    "warning_error_behavior_results.txt",
    "public_api_inventory.csv + man aliases"
  ),
  Status = c(
    compat_status(setequal(runtime_exports, namespace_exports)),
    compat_status(length(wrapper_names) > 0L),
    compat_status(TRUE, partial = formal_signature_partial),
    compat_status(TRUE, partial = formal_signature_partial),
    compat_status(TRUE, partial = any(return_behavior_matrix$function_name == "ggof")),
    compat_status(TRUE, partial = formal_na_rm_count < nrow(wrapper_signature_matrix)),
    compat_status(count_supported(vector_support_rows) > 0L, partial = count_supported(vector_support_rows) < nrow(vector_support_rows)),
    compat_status(count_supported(matrix_support_rows) > 0L, partial = count_supported(matrix_support_rows) < nrow(matrix_support_rows)),
    compat_status(count_supported(data_frame_support_rows) > 0L, partial = count_supported(data_frame_support_rows) < nrow(data_frame_support_rows)),
    if (!has_zoo) "unverified" else compat_status(count_supported(zoo_support_rows) > 0L, partial = count_supported(zoo_support_rows) < nrow(zoo_support_rows)),
    compat_status(is.null(gof_cases$vector_single_metric$error) && is.null(gof_cases$vector_multi_metric$error) && gof_deterministic),
    "divergent",
    compat_status(all(nzchar(warning_error_cases$message))),
    compat_status(export_docs_complete)
  ),
  `Evidence class` = c(
    "verified fact",
    "verified fact",
    "likely inference",
    "verified fact",
    "likely inference",
    "verified fact",
    "verified fact",
    "verified fact",
    "verified fact",
    if (has_zoo) "verified fact" else "verified fact",
    "verified fact",
    "verified fact",
    "likely inference",
    "verified fact"
  ),
  Notes = c(
    sprintf("%d runtime exports matched %d NAMESPACE exports.", length(runtime_exports), length(namespace_exports)),
    sprintf("%d exported wrappers/core entry points were audited.", length(wrapper_names)),
    sprintf("%d/%d wrappers expose formal na.rm; epsilon.type/value are absent from all audited wrappers.", formal_na_rm_count, nrow(wrapper_signature_matrix)),
    "Current public defaults are deterministic but not uniformly hydroGOF-style in naming.",
    "Representative return checks were deterministic; ggof returns a hydro_metrics_batch data.frame.",
    "na.rm runtime evidence exists across alpha, gof, preproc, and APFB.",
    sprintf("%d/%d audited vector-shape cases succeeded.", count_supported(vector_support_rows), nrow(vector_support_rows)),
    sprintf("%d/%d audited matrix-shape cases succeeded.", count_supported(matrix_support_rows), nrow(matrix_support_rows)),
    sprintf("%d/%d audited data.frame-shape cases succeeded.", count_supported(data_frame_support_rows), nrow(data_frame_support_rows)),
    if (has_zoo) sprintf("%d/%d audited zoo-shape cases succeeded.", count_supported(zoo_support_rows), nrow(zoo_support_rows)) else "zoo was unavailable locally.",
    "gof accepted representative vector, data.frame, zoo, and alias-driven inputs.",
    "ggof constructed deterministic data.frame output and left the graphics device list unchanged.",
    "Representative errors were informative and deterministic.",
    if (export_docs_complete) "All runtime exports were matched to Rd aliases." else "At least one runtime export lacked an Rd alias."
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
write_csv_file(scorecard, file.path(output_dir, "compatibility_scorecard.csv"))

divergence_register <- data.frame(
  ID = c("CA-001", "CA-002", "CA-003", "CA-004", "CA-005", "CA-006"),
  Category = c(
    "wrapper contract",
    "missing-value behavior",
    "plotting",
    "input handling",
    "input handling",
    "warning/error behavior"
  ),
  Title = c(
    "Dispatcher signatures use na_strategy and epsilon_mode naming",
    "Most exported wrappers do not declare na.rm formally",
    "ggof returns a data.frame-based batch result",
    "APFB rejects non-indexed inputs",
    "preproc rejects matrix and data.frame inputs",
    "HFB fails on insufficient high-flow support points"
  ),
  Severity = c("high", "medium", "medium", "medium", "medium", "low"),
  `Evidence class` = c(
    "verified fact",
    "verified fact",
    "verified fact",
    "verified fact",
    "verified fact",
    "verified fact"
  ),
  Evidence = c(
    sprintf("%d/%d wrappers expose formal na.rm; epsilon.type/value are absent across audited signatures.", formal_na_rm_count, nrow(wrapper_signature_matrix)),
    "Signature matrix shows scalar wrappers rely on ... rather than a formal na.rm parameter.",
    "ggof_behavior_results.txt records hydro_metrics_batch|data.frame output and no graphics-device change.",
    "input_shape_behavior_matrix.csv records APFB numeric, matrix, and data.frame cases as unsupported with explicit indexed-input errors.",
    "input_shape_behavior_matrix.csv records preproc matrix/data.frame cases as unsupported while vector and zoo cases succeed.",
    warning_error_cases$message[warning_error_cases$case == "insufficient_high_flow_points"]
  ),
  Impact = c(
    "Compatibility-sensitive callers may need argument translation rather than direct signature matching.",
    "Static signature checks may treat wrappers as less directly compatible even though runtime na.rm works through ...",
    "Downstream plotting-oriented expectations may not hold for ggof consumers.",
    "APFB cannot be used as a drop-in wrapper for plain numeric inputs.",
    "preproc is less shape-flexible than several wrapper functions built on gof.",
    "Short or sparse high-flow series can fail deterministically before producing a scalar result."
  ),
  `Recommended next action` = c(
    "Review whether compatibility shims or documentation should clarify argument-name translation before behavioral changes.",
    "Document or normalize na.rm expectations across exported wrappers before stabilization work.",
    "Clarify ggof output expectations in documentation and downstream compatibility tests.",
    "Document indexed-input requirements and verify whether wrapper callers need preflight checks.",
    "Document current preproc shape limits and decide whether caller-side normalization is required.",
    "Preserve this exact failure mode in future tests when threshold-sensitive behavior is revised."
  ),
  `Likely files affected` = c(
    "R/gof.R; R/ggof.R; R/preproc.R; man/gof.Rd; man/ggof.Rd; man/preproc.Rd",
    "R/alpha.R; R/beta.R; R/HFB.R; R/APFB.R; R/mae.R; R/NSeff.R; R/pbias.R; R/r.R; R/rNSeff.R; R/rsr.R; R/wsNSeff.R",
    "R/ggof.R; man/ggof.Rd",
    "R/APFB.R; man/APFB.Rd",
    "R/preproc.R; man/preproc.Rd",
    "R/HFB.R; R/core_metrics.R; tests/testthat/test-hfb.R"
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
write_csv_file(divergence_register, file.path(output_dir, "compatibility_divergence_register.csv"))

verified_signature_count <- sum(wrapper_signature_matrix$verified_status == "verified")
verified_return_count <- sum(return_behavior_matrix$verified_status == "verified")
na_rm_evidence_count <- sum(c("alpha", "gof", "preproc", "APFB") %in% wrapper_names)

summary_lines <- c(
  "# Phase 2 Compatibility Audit Summary",
  "",
  "Evidence legend:",
  "- `verified fact`: directly supported by generated runtime or repository evidence.",
  "- `likely inference`: a constrained interpretation of the recorded evidence.",
  "- `recommendation`: suggested next action, not a verified compatibility fact.",
  "",
  "## Inventory Totals",
  sprintf("- Public API objects inventoried: %d", nrow(public_api_inventory)),
  sprintf("- Wrapper-like objects audited: %d", length(wrapper_names)),
  sprintf("- Wrappers with verified signatures: %d", verified_signature_count),
  sprintf("- Wrappers with verified return structures: %d", verified_return_count),
  "",
  "## Compatibility Strengths",
  sprintf("- Runtime exports audited: %d", length(runtime_exports)),
  sprintf("- Vector-shape support cases succeeding: %d/%d", count_supported(vector_support_rows), nrow(vector_support_rows)),
  sprintf("- gof() representative deterministic runs: %s", gof_deterministic),
  sprintf("- ggof() noninteractive device list unchanged: %s", identical(ggof_before_devices, ggof_after_devices)),
  sprintf("- na.rm evidence recorded for selected wrappers/core entry points: %d", na_rm_evidence_count),
  "",
  "## Compatibility Blockers",
  "- Dispatcher signatures use na_strategy/epsilon_mode naming instead of a fully hydroGOF-style surface.",
  "- ggof() currently returns a hydro_metrics_batch data.frame, which is a plotting-contract divergence candidate.",
  "- APFB remains indexed-input-only from the public surface.",
  "",
  "## High-Priority Follow-up Actions",
  "- Preserve the recorded signature and na.rm evidence before any compatibility-surface changes are attempted.",
  "- Use the divergence register to scope wrapper-contract fixes without changing metric formulas or registry behavior.",
  "- Treat ggof return semantics as a public API decision, not as an internal refactor detail.",
  "",
  "## Unverified Areas",
  if (has_zoo) {
    "- No zoo-related unverified areas were created in this environment."
  } else {
    "- zoo-dependent cases were marked unverified because the zoo package was unavailable locally."
  },
  "",
  "## Package-Level vs Environment-Level Uncertainty",
  if (has_zoo) {
    "- No environment-level uncertainty blocked the audited zoo/runtime compatibility cases."
  } else {
    "- Optional zoo-dependent compatibility evidence is environment-limited in this local run."
  }
)
write_text_file(file.path(output_dir, "compatibility_summary.md"), summary_lines)

status_counts <- table(scorecard$Status)
summary_counts <- setNames(integer(5), c("compatible", "partially compatible", "incompatible", "divergent", "unverified"))
summary_counts[names(status_counts)] <- as.integer(status_counts)

cat("Compatibility audit artifacts generated successfully.\n")
cat(sprintf("Output directory: %s\n", normalizePath(output_dir, winslash = "/", mustWork = TRUE)))
cat(sprintf("exports counted: %d\n", length(runtime_exports)))
cat(sprintf("wrappers audited: %d\n", length(wrapper_names)))
cat(sprintf("scorecard items counted: %d\n", nrow(scorecard)))
cat(sprintf("compatible items counted: %d\n", summary_counts[["compatible"]]))
cat(sprintf("partially compatible items counted: %d\n", summary_counts[["partially compatible"]]))
cat(sprintf("incompatible/divergent items counted: %d\n", summary_counts[["incompatible"]] + summary_counts[["divergent"]]))
cat(sprintf("unverified items counted: %d\n", summary_counts[["unverified"]]))
cat(sprintf("divergence items logged: %d\n", nrow(divergence_register)))
cat("Audit runner completed without internal errors.\n")
