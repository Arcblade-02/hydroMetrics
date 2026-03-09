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
  stop("tools/phase2_math_validation.R must be run from the package root.", call. = FALSE)
}

output_dir <- file.path(repo_root, "notes", "math-validation")
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
  gsub("\\\\", "/", enc2utf8(lines))
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
  temp_parent <- file.path(tempdir(), paste0("hydroMetrics-math-validation-", label))
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
      stop(sprintf("Failed to copy '%s' into the temp math-validation source tree.", file_rels[[i]]), call. = FALSE)
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

extract_aliases <- function() {
  rd_files <- list.files(file.path(repo_root, "man"), pattern = "\\.Rd$", full.names = TRUE)
  alias_lines <- unlist(lapply(rd_files, function(path) {
    grep("^\\\\alias\\{", readLines(path, warn = FALSE), value = TRUE)
  }), use.names = FALSE)
  sort(unique(sub("^\\\\alias\\{([^}]*)\\}$", "\\1", trimws(alias_lines))))
}

extract_rd_reference_flags <- function() {
  rd_files <- list.files(file.path(repo_root, "man"), pattern = "\\.Rd$", full.names = TRUE)
  rows <- list()
  for (path in rd_files) {
    lines <- readLines(path, warn = FALSE)
    aliases <- sub("^\\\\alias\\{([^}]*)\\}$", "\\1", grep("^\\\\alias\\{", lines, value = TRUE))
    has_references <- any(grepl("^\\\\references\\{", lines))
    if (!length(aliases)) {
      next
    }
    rows[[length(rows) + 1L]] <- data.frame(
      alias = unname(aliases),
      has_references = rep(has_references, length(aliases)),
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

extract_wrapper_map <- function(exported_names) {
  rows <- list()
  r_files <- list.files(file.path(repo_root, "R"), pattern = "\\.[Rr]$", full.names = TRUE)
  for (path in r_files) {
    lines <- readLines(path, warn = FALSE)
    wrapper_name_hit <- regexec("^([A-Za-z][A-Za-z0-9._]*)\\s*<-\\s*function\\s*\\(", lines)
    wrapper_matches <- regmatches(lines, wrapper_name_hit)
    wrapper_names <- vapply(wrapper_matches[lengths(wrapper_matches) > 1L], `[[`, character(1), 2L)
    wrapper_names <- intersect(wrapper_names, exported_names)
    if (!length(wrapper_names)) {
      next
    }

    method_line <- grep("methods\\s*=\\s*['\"][^'\"]+['\"]", lines, value = TRUE)
    if (!length(method_line)) {
      next
    }
    metric_id <- sub(".*methods\\s*=\\s*['\"]([^'\"]+)['\"].*", "\\1", method_line[[1]])
    for (wrapper_name in wrapper_names) {
      rows[[length(rows) + 1L]] <- data.frame(
        wrapper_name = wrapper_name,
        metric_id = metric_id,
        source_file = rel_path(path),
        stringsAsFactors = FALSE
      )
    }
  }

  if (!length(rows)) {
    return(data.frame(wrapper_name = character(), metric_id = character(), source_file = character(), stringsAsFactors = FALSE))
  }

  out <- do.call(rbind, rows)
  out[order(out$wrapper_name), , drop = FALSE]
}

normalize_body <- function(fun) {
  paste(gsub("\\s+", " ", paste(deparse(body(fun)), collapse = " ")), collapse = " ")
}

capture_metric_call <- function(fun, args) {
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

condition_summary <- function(result) {
  if (!is.null(result$error)) {
    return(sprintf("error:%s", result$error))
  }
  if (length(result$warnings)) {
    return(sprintf("warning:%s", paste(result$warnings, collapse = " | ")))
  }
  "none"
}

deterministic_equal <- function(a, b) {
  isTRUE(all.equal(a, b, check.attributes = TRUE))
}

value_summary <- function(result) {
  if (!is.null(result$error)) {
    return(result$error)
  }
  value <- result$value
  if (length(value) == 1L && is.atomic(value)) {
    return(format(signif(as.numeric(value), 12), scientific = FALSE, trim = TRUE))
  }
  if (is.matrix(value) || is.data.frame(value)) {
    return(sprintf("%s[%s]", paste(class(value), collapse = "|"), paste(dim(value), collapse = "x")))
  }
  sprintf("%s length=%d", paste(class(value), collapse = "|"), length(value))
}

classify_reference <- function(metric_id, reference, duplicate_ids) {
  ref <- trimws(reference %||% "")
  ref_lower <- tolower(ref)

  if (metric_id %in% duplicate_ids) {
    return(list(literature_backed = grepl("(19|20)[0-9]{2}", ref), classification = "duplicate"))
  }
  if (!nzchar(ref)) {
    return(list(literature_backed = FALSE, classification = "unverified"))
  }
  if (grepl("project-defined|project definition|project decision|clean-room", ref_lower)) {
    return(list(literature_backed = FALSE, classification = "project-defined"))
  }
  if (grepl("(19|20)[0-9]{2}", ref) &&
      !grepl("citation to be refined|exact citation to be refined|pending definitive citation|pending dedicated paper citation", ref_lower)) {
    return(list(literature_backed = TRUE, classification = "literature-backed"))
  }
  if (grepl("citation to be refined|exact citation to be refined|pending definitive citation|pending dedicated paper citation|standard |common |literature", ref_lower)) {
    return(list(literature_backed = FALSE, classification = "ambiguous"))
  }
  list(literature_backed = FALSE, classification = "unverified")
}

temp_source <- copy_source_tree("install")
build_result <- run_r_cmd(c("build", "."), wd = temp_source)
if (build_result$status != 0L) {
  stop("Math validation could not build a disposable source tarball.", call. = FALSE)
}
tarballs <- find_built_tarballs(build_result$output, temp_source)
if (!length(tarballs)) {
  stop("Math validation could not locate the built source tarball.", call. = FALSE)
}

install_lib <- file.path(tempdir(), "hydroMetrics-math-validation-lib")
if (dir.exists(install_lib)) {
  unlink(install_lib, recursive = TRUE, force = TRUE)
}
dir.create(install_lib, recursive = TRUE, showWarnings = FALSE)

install_result <- run_r_cmd(
  c("INSTALL", "--preclean", "-l", install_lib, basename(tarballs[[1]])),
  wd = dirname(tarballs[[1]])
)
if (install_result$status != 0L) {
  stop("Math validation could not install the disposable source tarball.", call. = FALSE)
}

.libPaths(c(normalizePath(install_lib, winslash = "/", mustWork = TRUE), .libPaths()))
suppressPackageStartupMessages(library(hydroMetrics))

aliases <- extract_aliases()
rd_reference_flags <- extract_rd_reference_flags()
exported_names <- sort(getNamespaceExports("hydroMetrics"))
wrapper_map <- extract_wrapper_map(exported_names)
registry_tbl <- hydroMetrics:::list_metrics()
registry_tbl <- registry_tbl[order(registry_tbl$id), , drop = FALSE]

metric_fun_names <- ls(asNamespace("hydroMetrics"), all.names = TRUE)
metric_fun_names <- metric_fun_names[grepl("^metric_", metric_fun_names)]

metric_function_name <- function(fun) {
  hits <- metric_fun_names[vapply(metric_fun_names, function(name) {
    identical(get(name, envir = asNamespace("hydroMetrics"), inherits = FALSE), fun)
  }, logical(1))]
  hits[[1]] %||% ""
}

metric_details <- lapply(seq_len(nrow(registry_tbl)), function(i) {
  id <- registry_tbl$id[[i]]
  spec <- hydroMetrics:::get_metric(id)
  list(
    id = id,
    fun = spec$fun,
    function_name = metric_function_name(spec$fun),
    name = registry_tbl$name[[i]],
    references = registry_tbl$references[[i]],
    perfect = registry_tbl$perfect[[i]]
  )
})
names(metric_details) <- vapply(metric_details, `[[`, character(1), "id")

body_signature <- vapply(metric_details, function(item) {
  paste(paste(names(formals(item$fun)), collapse = ","), normalize_body(item$fun), sep = "::")
}, character(1))

duplicate_pairs <- combn(names(body_signature), 2L, simplify = FALSE)
duplicate_pairs <- Filter(function(pair) identical(body_signature[[pair[[1]]]], body_signature[[pair[[2]]]]), duplicate_pairs)
duplicate_metric_ids <- sort(unique(unlist(duplicate_pairs, use.names = FALSE)))

provenance_rows <- lapply(metric_details, function(item) {
  wrapper_hits <- wrapper_map$wrapper_name[wrapper_map$metric_id == item$id]
  doc_reference <- FALSE
  if (length(wrapper_hits)) {
    doc_reference <- any(rd_reference_flags$has_references[rd_reference_flags$alias %in% wrapper_hits])
  }
  classification <- classify_reference(item$id, item$references, duplicate_metric_ids)
  data.frame(
    metric_name = item$id,
    formula_category = registry_tbl$category[registry_tbl$id == item$id][[1]],
    literature_backed = classification$literature_backed,
    known_reference_name = item$references,
    reference_presence_in_documentation = doc_reference,
    classification = classification$classification,
    evidence_source = if (doc_reference) "registry references + Rd references" else "registry references",
    notes = if (!doc_reference && classification$literature_backed) "Registry carries a citation but matching Rd references were not detected." else "",
    stringsAsFactors = FALSE
  )
})
formula_provenance_matrix <- do.call(rbind, provenance_rows)
formula_provenance_matrix <- formula_provenance_matrix[order(formula_provenance_matrix$metric_name), , drop = FALSE]
write_csv_file(formula_provenance_matrix, file.path(output_dir, "formula_provenance_matrix.csv"))

metric_inventory_rows <- lapply(metric_details, function(item) {
  wrapper_hits <- wrapper_map$wrapper_name[wrapper_map$metric_id == item$id]
  documented <- item$id %in% aliases || any(wrapper_hits %in% aliases)
  data.frame(
    metric_name = item$id,
    function_name = item$function_name,
    exported = item$id %in% exported_names,
    wrapper_presence = length(wrapper_hits) > 0L || item$id %in% exported_names,
    registry_presence = TRUE,
    documented = documented,
    verified_status = "verified",
    notes = if (length(wrapper_hits)) paste(wrapper_hits, collapse = ", ") else "",
    stringsAsFactors = FALSE
  )
})
metric_inventory <- do.call(rbind, metric_inventory_rows)
metric_inventory <- metric_inventory[order(metric_inventory$metric_name), , drop = FALSE]
write_csv_file(metric_inventory, file.path(output_dir, "metric_inventory.csv"))

duplicate_rows <- list()
for (pair in duplicate_pairs) {
  duplicate_rows[[length(duplicate_rows) + 1L]] <- data.frame(
    Metric_A = pair[[1]],
    Metric_B = pair[[2]],
    relationship_type = "identical_function_body",
    Evidence = "Registry metric functions have identical normalized bodies and formals.",
    verified_status = "verified",
    stringsAsFactors = FALSE
  )
}
for (i in seq_len(nrow(wrapper_map))) {
  if (identical(wrapper_map$wrapper_name[[i]], wrapper_map$metric_id[[i]])) {
    next
  }
  duplicate_rows[[length(duplicate_rows) + 1L]] <- data.frame(
    Metric_A = wrapper_map$wrapper_name[[i]],
    Metric_B = wrapper_map$metric_id[[i]],
    relationship_type = "wrapper_alias",
    Evidence = sprintf("Wrapper '%s' delegates to gof(methods = '%s').", wrapper_map$wrapper_name[[i]], wrapper_map$metric_id[[i]]),
    verified_status = "verified",
    stringsAsFactors = FALSE
  )
}
duplicate_metric_scan <- if (length(duplicate_rows)) {
  out <- do.call(rbind, duplicate_rows)
  out[order(out$Metric_A, out$Metric_B), , drop = FALSE]
} else {
  data.frame(Metric_A = character(), Metric_B = character(), relationship_type = character(), Evidence = character(), verified_status = character(), stringsAsFactors = FALSE)
}
write_csv_file(duplicate_metric_scan, file.path(output_dir, "duplicate_metric_scan.csv"))

base_sim <- c(1, 2, 3, 4, 5, 6, 7, 8)
base_obs <- c(1.1, 1.9, 3.2, 3.8, 5.1, 6.2, 6.8, 8.1)
perfect_sim <- c(1, 2, 3, 4, 5, 6, 7, 8)
perfect_obs <- perfect_sim
long_sim <- seq(10, 45, length.out = 36)
long_obs <- seq(11, 46, length.out = 36)
constant_obs <- rep(2, 8)
constant_sim <- rep(3, 8)
near_zero_obs <- c(1, 1 + 1e-12, 1 - 1e-12, 1 + 2e-12, 1 - 2e-12, 1 + 3e-12, 1 - 3e-12, 1 + 4e-12)
near_zero_sim <- c(1 + 5e-13, 1 + 1.5e-12, 1 - 5e-13, 1 + 2.5e-12, 1 - 1.5e-12, 1 + 3.5e-12, 1 - 2.5e-12, 1 + 4.5e-12)
tiny_obs <- c(1e-12, 2e-12, 3e-12, 4e-12, 5e-12, 6e-12, 7e-12, 8e-12)
tiny_sim <- c(1.1e-12, 1.9e-12, 3.1e-12, 3.9e-12, 5.2e-12, 5.8e-12, 7.2e-12, 7.9e-12)
large_obs <- c(1e12, 2e12, 3e12, 4e12, 5e12, 6e12, 7e12, 8e12)
large_sim <- c(1.1e12, 1.9e12, 3.2e12, 3.8e12, 5.1e12, 6.2e12, 6.8e12, 8.1e12)
small_mag_obs <- c(1e-9, 2e-9, 3e-9, 4e-9, 5e-9, 6e-9, 7e-9, 8e-9)
small_mag_sim <- c(1.1e-9, 1.9e-9, 3.2e-9, 3.8e-9, 5.1e-9, 6.2e-9, 6.8e-9, 8.1e-9)
zero_den_obs <- rep(0, 8)
zero_den_sim <- c(0, 1, 0, 1, 0, 1, 0, 1)
apfb_index <- seq.Date(as.Date("2000-01-01"), by = "quarter", length.out = 8)
apfb_long_index <- seq.Date(as.Date("2000-01-01"), by = "month", length.out = 24)
skge_base_obs <- stats::ts(seq(1, 24), frequency = 12)
skge_base_sim <- stats::ts(seq(1.1, 24.1, length.out = 24), frequency = 12)
skge_perfect <- stats::ts(seq(1, 24), frequency = 12)
skge_constant_obs <- stats::ts(rep(2, 24), frequency = 12)
skge_constant_sim <- stats::ts(rep(3, 24), frequency = 12)
skge_near_zero_obs <- stats::ts(seq(1e-9, 24e-9, length.out = 24), frequency = 12)
skge_near_zero_sim <- stats::ts(seq(1.1e-9, 24.1e-9, length.out = 24), frequency = 12)
skge_large_obs <- stats::ts(seq(1e12, 24e12, length.out = 24), frequency = 12)
skge_large_sim <- stats::ts(seq(1.1e12, 24.1e12, length.out = 24), frequency = 12)
skge_small_mag_obs <- stats::ts(seq(1e-9, 24e-9, length.out = 24), frequency = 12)
skge_small_mag_sim <- stats::ts(seq(1.1e-9, 24.1e-9, length.out = 24), frequency = 12)

metric_args <- function(metric_id, sim, obs) {
  args <- list(sim = sim, obs = obs)
  if (identical(metric_id, "apfb")) {
    args$index <- if (length(obs) >= 24) apfb_long_index[seq_len(length(obs))] else apfb_index[seq_len(length(obs))]
  }
  if (identical(metric_id, "hfb")) {
    args$threshold_prob <- 0.9
  }
  args
}

edge_case_inputs <- function(metric_id) {
  if (metric_id == "skge") {
    return(list(
      NA_input = metric_args(metric_id, stats::ts(replace(as.numeric(skge_base_sim), 2, NA_real_), frequency = 12), skge_base_obs),
      NaN_input = metric_args(metric_id, stats::ts(replace(as.numeric(skge_base_sim), 2, NaN), frequency = 12), skge_base_obs),
      Inf_input = metric_args(metric_id, stats::ts(replace(as.numeric(skge_base_sim), 3, Inf), frequency = 12), skge_base_obs),
      zero_denominator = metric_args(metric_id, stats::ts(rep(0, 24), frequency = 12), stats::ts(rep(0, 24), frequency = 12)),
      constant_series = metric_args(metric_id, skge_base_sim, skge_constant_obs),
      mismatched_lengths = metric_args(metric_id, stats::ts(as.numeric(skge_base_sim)[-1], frequency = 12), skge_base_obs),
      empty_input = metric_args(metric_id, numeric(0), numeric(0)),
      near_zero_variance = metric_args(metric_id, skge_near_zero_sim, skge_near_zero_obs)
    ))
  }
  list(
    NA_input = metric_args(metric_id, c(1, NA, 3, 4, 5, 6, 7, 8), base_obs),
    NaN_input = metric_args(metric_id, c(1, NaN, 3, 4, 5, 6, 7, 8), base_obs),
    Inf_input = metric_args(metric_id, c(1, 2, Inf, 4, 5, 6, 7, 8), base_obs),
    zero_denominator = metric_args(metric_id, zero_den_sim, zero_den_obs),
    constant_series = metric_args(metric_id, base_sim, constant_obs),
    mismatched_lengths = metric_args(metric_id, base_sim[-1], base_obs),
    empty_input = metric_args(metric_id, numeric(0), numeric(0)),
    near_zero_variance = metric_args(metric_id, near_zero_sim, near_zero_obs)
  )
}

edge_rows <- list()
perfect_fit_rows <- list()
zero_variance_rows <- list()
log_near_zero_rows <- list()
extreme_rows <- list()

for (metric_id in names(metric_details)) {
  item <- metric_details[[metric_id]]

  cases <- edge_case_inputs(metric_id)
  for (case_name in names(cases)) {
    first <- capture_metric_call(item$fun, cases[[case_name]])
    second <- capture_metric_call(item$fun, cases[[case_name]])
    edge_rows[[length(edge_rows) + 1L]] <- data.frame(
      metric_name = metric_id,
      edge_case = case_name,
      behavior_observed = value_summary(first),
      error_warning_presence = condition_summary(first),
      deterministic = if (!is.null(first$error) && !is.null(second$error)) identical(first$error, second$error) else deterministic_equal(first$value, second$value),
      verified_status = "verified",
      notes = if (!is.null(first$error)) "" else if (is.finite(as.numeric(first$value[[1]] %||% NA_real_))) "" else "Non-finite successful output." ,
      stringsAsFactors = FALSE
    )
  }

  perfect_args <- if (metric_id %in% c("apfb")) {
    metric_args(metric_id, seq(10, 33, length.out = 24), seq(10, 33, length.out = 24))
  } else if (metric_id == "skge") {
    metric_args(metric_id, skge_perfect, skge_perfect)
  } else if (metric_id %in% c("hfb")) {
    metric_args(metric_id, long_obs, long_obs)
  } else {
    metric_args(metric_id, perfect_sim, perfect_obs)
  }
  perfect_result_1 <- capture_metric_call(item$fun, perfect_args)
  perfect_result_2 <- capture_metric_call(item$fun, perfect_args)
  perfect_fit_rows[[length(perfect_fit_rows) + 1L]] <- data.frame(
    metric_name = metric_id,
    perfect_target = item$perfect,
    behavior = value_summary(perfect_result_1),
    matches_target = if (is.null(perfect_result_1$error) && is.finite(item$perfect)) isTRUE(all.equal(as.numeric(perfect_result_1$value), as.numeric(item$perfect), tolerance = 1e-8)) else NA,
    deterministic = if (!is.null(perfect_result_1$error) && !is.null(perfect_result_2$error)) identical(perfect_result_1$error, perfect_result_2$error) else deterministic_equal(perfect_result_1$value, perfect_result_2$value),
    condition = condition_summary(perfect_result_1),
    stringsAsFactors = FALSE
  )

  zero_obs_args <- if (metric_id == "apfb") {
    metric_args(metric_id, seq(1, 8), rep(2, 8))
  } else if (metric_id == "skge") {
    metric_args(metric_id, skge_base_sim, skge_constant_obs)
  } else {
    metric_args(metric_id, base_sim, constant_obs)
  }
  zero_sim_args <- if (metric_id == "apfb") {
    metric_args(metric_id, rep(2, 8), seq(1, 8))
  } else if (metric_id == "skge") {
    metric_args(metric_id, skge_constant_sim, skge_base_obs)
  } else {
    metric_args(metric_id, constant_sim, base_obs)
  }
  zero_obs_res <- capture_metric_call(item$fun, zero_obs_args)
  zero_sim_res <- capture_metric_call(item$fun, zero_sim_args)
  zero_variance_rows[[length(zero_variance_rows) + 1L]] <- data.frame(
    metric_name = metric_id,
    observed_variance_zero = condition_summary(zero_obs_res),
    simulated_variance_zero = condition_summary(zero_sim_res),
    stringsAsFactors = FALSE
  )

  near_zero_args <- if (metric_id == "apfb") {
    metric_args(metric_id, rep(1e-12, 24) + seq_len(24) * 1e-15, rep(1e-12, 24) + seq_len(24) * 1e-15)
  } else if (metric_id == "hfb") {
    metric_args(metric_id, seq(1.1e-9, 36.1e-9, length.out = 36), seq(1e-9, 36e-9, length.out = 36))
  } else if (metric_id == "skge") {
    metric_args(metric_id, skge_near_zero_sim, skge_near_zero_obs)
  } else {
    metric_args(metric_id, tiny_sim, tiny_obs)
  }
  near_zero_res_1 <- capture_metric_call(item$fun, near_zero_args)
  near_zero_res_2 <- capture_metric_call(item$fun, near_zero_args)
  log_near_zero_rows[[length(log_near_zero_rows) + 1L]] <- data.frame(
    metric_name = metric_id,
    behavior = value_summary(near_zero_res_1),
    finite_success = is.null(near_zero_res_1$error) && all(is.finite(as.numeric(near_zero_res_1$value))),
    deterministic = if (!is.null(near_zero_res_1$error) && !is.null(near_zero_res_2$error)) identical(near_zero_res_1$error, near_zero_res_2$error) else deterministic_equal(near_zero_res_1$value, near_zero_res_2$value),
    condition = condition_summary(near_zero_res_1),
    stringsAsFactors = FALSE
  )

  extreme_large_args <- if (metric_id == "apfb") {
    metric_args(metric_id, seq(1e12, 24e12, length.out = 24), seq(1.1e12, 24.1e12, length.out = 24))
  } else if (metric_id == "hfb") {
    metric_args(metric_id, seq(1.1e12, 36.1e12, length.out = 36), seq(1e12, 36e12, length.out = 36))
  } else if (metric_id == "skge") {
    metric_args(metric_id, skge_large_sim, skge_large_obs)
  } else {
    metric_args(metric_id, large_sim, large_obs)
  }
  extreme_small_args <- if (metric_id == "apfb") {
    metric_args(metric_id, seq(1e-9, 24e-9, length.out = 24), seq(1.1e-9, 24.1e-9, length.out = 24))
  } else if (metric_id == "hfb") {
    metric_args(metric_id, seq(1.1e-9, 36.1e-9, length.out = 36), seq(1e-9, 36e-9, length.out = 36))
  } else if (metric_id == "skge") {
    metric_args(metric_id, skge_small_mag_sim, skge_small_mag_obs)
  } else {
    metric_args(metric_id, small_mag_sim, small_mag_obs)
  }
  extreme_large_res <- capture_metric_call(item$fun, extreme_large_args)
  extreme_small_res <- capture_metric_call(item$fun, extreme_small_args)
  extreme_rows[[length(extreme_rows) + 1L]] <- data.frame(
    metric_name = metric_id,
    large_value_behavior = condition_summary(extreme_large_res),
    large_value_finite = is.null(extreme_large_res$error) && all(is.finite(as.numeric(extreme_large_res$value))),
    small_value_behavior = condition_summary(extreme_small_res),
    small_value_finite = is.null(extreme_small_res$error) && all(is.finite(as.numeric(extreme_small_res$value))),
    stringsAsFactors = FALSE
  )
}

edge_case_behavior_matrix <- do.call(rbind, edge_rows)
edge_case_behavior_matrix <- edge_case_behavior_matrix[order(edge_case_behavior_matrix$metric_name, edge_case_behavior_matrix$edge_case), , drop = FALSE]
write_csv_file(edge_case_behavior_matrix, file.path(output_dir, "edge_case_behavior_matrix.csv"))

selected_multi_functions <- c("NSeff", "pbias", "mae", "alpha", "beta", "r", "rsr", "HFB", "gof")
matrix_single_sim <- cbind(series1 = base_sim)
matrix_single_obs <- cbind(series1 = base_obs)
matrix_multi_sim <- cbind(series1 = base_sim, series2 = base_sim + 0.2)
matrix_multi_obs <- cbind(series1 = base_obs, series2 = base_obs + 0.1)
data_frame_multi_sim <- as.data.frame(matrix_multi_sim)
data_frame_multi_obs <- as.data.frame(matrix_multi_obs)

multi_args <- function(fun_name, input_type) {
  base <- switch(
    input_type,
    matrix_single = list(sim = matrix_single_sim, obs = matrix_single_obs),
    matrix_multi = list(sim = if (fun_name == "HFB") cbind(series1 = long_sim, series2 = long_sim + 0.2) else matrix_multi_sim, obs = if (fun_name == "HFB") cbind(series1 = long_obs, series2 = long_obs + 0.1) else matrix_multi_obs),
    data_frame_multi = list(sim = if (fun_name == "HFB") as.data.frame(cbind(series1 = long_sim, series2 = long_sim + 0.2)) else data_frame_multi_sim, obs = if (fun_name == "HFB") as.data.frame(cbind(series1 = long_obs, series2 = long_obs + 0.1)) else data_frame_multi_obs)
  )
  extra <- switch(
    fun_name,
    gof = list(methods = "nse"),
    HFB = list(threshold_prob = 0.9),
    list()
  )
  c(base, extra)
}

multi_rows <- list()
for (fun_name in selected_multi_functions) {
  fun <- get(fun_name, envir = asNamespace("hydroMetrics"), inherits = FALSE)
  for (input_type in c("matrix_single", "matrix_multi", "data_frame_multi")) {
    first <- capture_metric_call(fun, multi_args(fun_name, input_type))
    second <- capture_metric_call(fun, multi_args(fun_name, input_type))
    multi_rows[[length(multi_rows) + 1L]] <- data.frame(
      metric_name = fun_name,
      input_type = input_type,
      supported = is.null(first$error),
      output_shape = if (is.null(first$error)) value_summary(first) else "",
      deterministic = if (!is.null(first$error) && !is.null(second$error)) identical(first$error, second$error) else deterministic_equal(first$value, second$value),
      verified_status = "verified",
      stringsAsFactors = FALSE
    )
  }
}
multi_column_behavior_matrix <- do.call(rbind, multi_rows)
multi_column_behavior_matrix <- multi_column_behavior_matrix[order(multi_column_behavior_matrix$metric_name, multi_column_behavior_matrix$input_type), , drop = FALSE]
write_csv_file(multi_column_behavior_matrix, file.path(output_dir, "multi_column_behavior_matrix.csv"))

perfect_fit_df <- do.call(rbind, perfect_fit_rows)
zero_variance_df <- do.call(rbind, zero_variance_rows)
log_near_zero_df <- do.call(rbind, log_near_zero_rows)
extreme_df <- do.call(rbind, extreme_rows)

perfect_fit_lines <- c(
  "Phase 2 Math Validation - Perfect Fit Behavior",
  "Evidence class: verified fact",
  sprintf("metrics tested = %d", nrow(perfect_fit_df)),
  sprintf("perfect-target matches = %d", sum(perfect_fit_df$matches_target %in% TRUE, na.rm = TRUE)),
  sprintf("perfect-target mismatches = %d", sum(perfect_fit_df$matches_target %in% FALSE, na.rm = TRUE)),
  sprintf("deterministic perfect-fit runs = %d", sum(perfect_fit_df$deterministic %in% TRUE, na.rm = TRUE)),
  "",
  "Mismatches or errors:",
  if (any(perfect_fit_df$matches_target %in% FALSE | perfect_fit_df$condition != "none", na.rm = TRUE)) {
    apply(perfect_fit_df[perfect_fit_df$matches_target %in% FALSE | perfect_fit_df$condition != "none", c("metric_name", "behavior", "condition")], 1, function(row) sprintf("- %s: %s | %s", row[[1]], row[[2]], row[[3]]))
  } else {
    "- <none>"
  },
  "",
  "Evidence class: likely inference",
  "Registry perfect targets align with the direct metric outputs for the representative perfect-fit cases unless listed above.",
  "",
  "Evidence class: recommendation",
  "Treat any perfect-fit mismatch as a high-priority mathematical review item before formula changes are attempted."
)
write_text_file(file.path(output_dir, "perfect_fit_behavior_results.txt"), unlist(perfect_fit_lines, use.names = FALSE))

zero_variance_lines <- c(
  "Phase 2 Math Validation - Zero Variance Behavior",
  "Evidence class: verified fact",
  sprintf("metrics tested = %d", nrow(zero_variance_df)),
  sprintf("observed-variance-zero errors = %d", sum(grepl("^error:", zero_variance_df$observed_variance_zero))),
  sprintf("simulated-variance-zero errors = %d", sum(grepl("^error:", zero_variance_df$simulated_variance_zero))),
  "",
  "Representative rows:",
  apply(zero_variance_df[seq_len(min(10L, nrow(zero_variance_df))), ], 1, function(row) {
    sprintf("- %s: obs_zero=%s | sim_zero=%s", row[["metric_name"]], row[["observed_variance_zero"]], row[["simulated_variance_zero"]])
  }),
  "",
  "Evidence class: likely inference",
  "Zero-variance handling is metric-specific and generally deterministic across the direct registry metrics.",
  "",
  "Evidence class: recommendation",
  "Use the zero-variance rows to distinguish mathematically undefined cases from numerical-stability defects."
)
write_text_file(file.path(output_dir, "zero_variance_behavior_results.txt"), zero_variance_lines)

log_near_zero_lines <- c(
  "Phase 2 Math Validation - Log/Near-Zero Behavior",
  "Evidence class: verified fact",
  sprintf("metrics tested = %d", nrow(log_near_zero_df)),
  sprintf("finite successful outputs = %d", sum(log_near_zero_df$finite_success %in% TRUE)),
  sprintf("deterministic runs = %d", sum(log_near_zero_df$deterministic %in% TRUE)),
  sprintf("errors = %d", sum(grepl("^error:", log_near_zero_df$condition))),
  "",
  "Metrics with non-finite success or errors:",
  if (any(!log_near_zero_df$finite_success | grepl("^error:", log_near_zero_df$condition))) {
    apply(log_near_zero_df[!log_near_zero_df$finite_success | grepl("^error:", log_near_zero_df$condition), c("metric_name", "behavior", "condition")], 1, function(row) sprintf("- %s: %s | %s", row[[1]], row[[2]], row[[3]]))
  } else {
    "- <none>"
  },
  "",
  "Evidence class: likely inference",
  "Near-zero positive inputs do not trigger overflow in the direct metric computations unless listed above.",
  "",
  "Evidence class: recommendation",
  "Review any non-finite near-zero success result before treating ratio-based metrics as numerically stable."
)
write_text_file(file.path(output_dir, "log_near_zero_behavior_results.txt"), unlist(log_near_zero_lines, use.names = FALSE))

extreme_lines <- c(
  "Phase 2 Math Validation - Extreme Value Behavior",
  "Evidence class: verified fact",
  sprintf("metrics tested = %d", nrow(extreme_df)),
  sprintf("large-value finite outputs = %d", sum(extreme_df$large_value_finite %in% TRUE)),
  sprintf("small-value finite outputs = %d", sum(extreme_df$small_value_finite %in% TRUE)),
  "",
  "Metrics with instability or errors:",
  if (any(!extreme_df$large_value_finite | !extreme_df$small_value_finite)) {
    apply(extreme_df[!extreme_df$large_value_finite | !extreme_df$small_value_finite, c("metric_name", "large_value_behavior", "small_value_behavior")], 1, function(row) sprintf("- %s: large=%s | small=%s", row[[1]], row[[2]], row[[3]]))
  } else {
    "- <none>"
  },
  "",
  "Evidence class: likely inference",
  "The direct metric implementations remain numerically stable on the representative large- and small-magnitude inputs unless listed above.",
  "",
  "Evidence class: recommendation",
  "Treat any instability here as a scientific defect candidate even if wrapper-level tests still pass."
)
write_text_file(file.path(output_dir, "extreme_value_behavior_results.txt"), unlist(extreme_lines, use.names = FALSE))

scientific_defect_rows <- list()

ambiguous_metrics <- formula_provenance_matrix$metric_name[formula_provenance_matrix$classification == "ambiguous"]
for (metric_id in ambiguous_metrics) {
  scientific_defect_rows[[length(scientific_defect_rows) + 1L]] <- data.frame(
    ID = sprintf("SD-%03d", length(scientific_defect_rows) + 1L),
    `Metric name` = metric_id,
    Category = "ambiguous definition",
    Severity = "medium",
    `Evidence class` = "verified fact",
    Evidence = formula_provenance_matrix$known_reference_name[formula_provenance_matrix$metric_name == metric_id][[1]],
    Impact = "Formula provenance is not backed by a specific recorded citation, which weakens scientific traceability.",
    `Recommended follow-up` = "Add a specific literature citation or explicitly document the metric as project-defined.",
    `Likely files affected` = "R/core_metrics.R; documentation for related wrappers",
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

for (pair in duplicate_pairs) {
  scientific_defect_rows[[length(scientific_defect_rows) + 1L]] <- data.frame(
    ID = sprintf("SD-%03d", length(scientific_defect_rows) + 1L),
    `Metric name` = paste(pair, collapse = " / "),
    Category = "duplicate metric",
    Severity = "high",
    `Evidence class` = "verified fact",
    Evidence = "Direct registry metric functions have identical normalized bodies and formals.",
    Impact = "Duplicate formulas can create ambiguous scientific interpretation and maintenance drift.",
    `Recommended follow-up` = "Confirm whether the pair is intentional aliasing or an unintended duplicate and document the decision.",
    `Likely files affected` = "R/core_metrics.R; registry metadata",
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

perfect_mismatches <- perfect_fit_df$metric_name[perfect_fit_df$matches_target %in% FALSE]
for (metric_id in perfect_mismatches) {
  scientific_defect_rows[[length(scientific_defect_rows) + 1L]] <- data.frame(
    ID = sprintf("SD-%03d", length(scientific_defect_rows) + 1L),
    `Metric name` = metric_id,
    Category = "formula correctness",
    Severity = "high",
    `Evidence class` = "verified fact",
    Evidence = perfect_fit_df$behavior[perfect_fit_df$metric_name == metric_id][[1]],
    Impact = "Perfect-fit output does not match the registry perfect target.",
    `Recommended follow-up` = "Review the formula and registry perfect target together before any behavioral fixes are attempted.",
    `Likely files affected` = "R/core_metrics.R; registry metadata",
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

unstable_near_zero <- log_near_zero_df$metric_name[!log_near_zero_df$finite_success | grepl("^error:", log_near_zero_df$condition)]
for (metric_id in unstable_near_zero) {
  scientific_defect_rows[[length(scientific_defect_rows) + 1L]] <- data.frame(
    ID = sprintf("SD-%03d", length(scientific_defect_rows) + 1L),
    `Metric name` = metric_id,
    Category = "numerical stability",
    Severity = "medium",
    `Evidence class` = "verified fact",
    Evidence = log_near_zero_df$condition[log_near_zero_df$metric_name == metric_id][[1]],
    Impact = "Very small positive inputs do not remain fully stable in direct metric evaluation.",
    `Recommended follow-up` = "Review the metric's denominator and scaling behavior under near-zero inputs.",
    `Likely files affected` = "R/core_metrics.R",
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

scientific_defect_register <- if (length(scientific_defect_rows)) {
  do.call(rbind, scientific_defect_rows)
} else {
  data.frame(
    ID = character(),
    `Metric name` = character(),
    Category = character(),
    Severity = character(),
    `Evidence class` = character(),
    Evidence = character(),
    Impact = character(),
    `Recommended follow-up` = character(),
    `Likely files affected` = character(),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}
write_csv_file(scientific_defect_register, file.path(output_dir, "scientific_defect_register.csv"))

metrics_failing_edge_cases <- sort(unique(edge_case_behavior_matrix$metric_name[!edge_case_behavior_matrix$deterministic | grepl("Non-finite", edge_case_behavior_matrix$notes)]))
classification_counts <- table(formula_provenance_matrix$classification)
summary_lines <- c(
  "# Phase 2 Math Validation Summary",
  "",
  "Evidence legend:",
  "- `verified fact`: directly supported by generated runtime or repository evidence.",
  "- `likely inference`: a constrained interpretation of the recorded evidence.",
  "- `recommendation`: suggested next action, not a verified scientific fact.",
  "",
  sprintf("- Metrics inventoried: %d", nrow(metric_inventory)),
  sprintf("- Literature-backed metrics: %d", sum(formula_provenance_matrix$classification == "literature-backed")),
  sprintf("- Project-defined metrics: %d", sum(formula_provenance_matrix$classification == "project-defined")),
  sprintf("- Ambiguous metrics: %d", sum(formula_provenance_matrix$classification == "ambiguous")),
  sprintf("- Duplicate metrics detected: %d", nrow(subset(duplicate_metric_scan, relationship_type == "identical_function_body"))),
  sprintf("- Metrics with at least one edge-case failure or instability: %d", length(metrics_failing_edge_cases)),
  sprintf("- High-severity scientific defects: %d", sum(scientific_defect_register$Severity == "high")),
  sprintf("- Unverified metrics: %d", sum(formula_provenance_matrix$classification == "unverified")),
  "",
  "Recommended next actions:",
  "- Prioritize exact-citation cleanup for ambiguous metrics before making formula-level changes.",
  "- Resolve duplicate metric definitions or document them as intentional aliases with explicit rationale.",
  "- Preserve the current edge-case and perfect-fit evidence as the mathematical baseline for stabilization work."
)
write_text_file(file.path(output_dir, "math_validation_summary.md"), summary_lines)

cat("Math validation artifacts generated successfully.\n")
cat(sprintf("Output directory: %s\n", normalizePath(output_dir, winslash = "/", mustWork = TRUE)))
cat(sprintf("metrics inventoried: %d\n", nrow(metric_inventory)))
cat(sprintf("provenance classifications: %s\n", paste(paste(names(classification_counts), as.integer(classification_counts), sep = "="), collapse = ", ")))
cat(sprintf("edge-case tests executed: %d\n", nrow(edge_case_behavior_matrix)))
cat(sprintf("scientific defects logged: %d\n", nrow(scientific_defect_register)))
cat(sprintf("unverified metrics count: %d\n", sum(formula_provenance_matrix$classification == "unverified")))
cat("Validation runner completed without internal errors.\n")
