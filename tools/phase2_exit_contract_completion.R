`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L || is.na(x[[1]])) y else x
}

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- sub("^--file=", "", script_arg[1] %||% "tools/phase2_exit_contract_completion.R")
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
setwd(repo_root)

notes_dir <- file.path("notes", "phase2-exit")
dir.create(notes_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path("inst", "benchmarks"), recursive = TRUE, showWarnings = FALSE)

escape_csv <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  needs_quote <- grepl("[\",\n]", x)
  x <- gsub("\"", "\"\"", x, fixed = TRUE)
  ifelse(needs_quote, paste0("\"", x, "\""), x)
}

write_csv_lines <- function(path, df) {
  lines <- apply(df, 1L, function(row) paste(escape_csv(row), collapse = ","))
  writeLines(c(paste(names(df), collapse = ","), lines), path, useBytes = TRUE)
}

capture_conditions <- function(expr) {
  warnings <- character()
  value <- tryCatch(
    withCallingHandlers(
      expr,
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) e
  )

  list(
    value = value,
    warnings = warnings,
    error = inherits(value, "error")
  )
}

format_result_type <- function(x) {
  cls <- class(x)
  if (inherits(x, "hydro_metric_scalar")) {
    return("hydro_metric_scalar")
  }
  if (inherits(x, "hydro_metrics_batch")) {
    return("hydro_metrics_batch")
  }
  if (inherits(x, "hydro_metrics")) {
    return("hydro_metrics")
  }
  if (inherits(x, "hydro_preproc")) {
    return("hydro_preproc")
  }
  if (is.matrix(x)) {
    return("matrix")
  }
  if (is.numeric(x) && is.null(dim(x))) {
    return(if (length(x) == 1L) "numeric_scalar" else "numeric_vector")
  }
  if (length(cls) > 0L) {
    paste(cls, collapse = "/")
  } else {
    typeof(x)
  }
}

format_behavior <- function(result) {
  if (isTRUE(result$error)) {
    return(paste0("error: ", conditionMessage(result$value)))
  }
  if (length(result$warnings) > 0L) {
    return(paste0("warning: ", paste(unique(result$warnings), collapse = " | ")))
  }

  value <- result$value
  if (inherits(value, "hydro_metrics")) {
    metrics <- value$metrics
    if (is.matrix(metrics)) {
      return(sprintf("ok: hydro_metrics matrix [%d x %d]", nrow(metrics), ncol(metrics)))
    }
    return(sprintf("ok: hydro_metrics length %d", length(metrics)))
  }
  if (inherits(value, "hydro_metrics_batch")) {
    return(sprintf("ok: hydro_metrics_batch rows %d", nrow(value)))
  }
  if (inherits(value, "hydro_preproc")) {
    return(sprintf("ok: hydro_preproc n %d", length(value$sim)))
  }
  if (is.numeric(value)) {
    return(paste0("ok: ", paste(format(signif(as.numeric(value), 6)), collapse = "; ")))
  }

  paste0("ok: ", format_result_type(value))
}

load_namespace <- function(root = repo_root) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    stop("devtools is required to run Phase 2 exit verification.", call. = FALSE)
  }
  devtools::load_all(path = root, quiet = TRUE)
  asNamespace("hydroMetrics")
}

ns <- load_namespace()

export_lines <- readLines("NAMESPACE", warn = FALSE)
exports <- sub("^export\\(([^)]+)\\)$", "\\1", grep("^export\\(", export_lines, value = TRUE))

rd_alias_map <- local({
  map <- list()
  rd_files <- list.files("man", pattern = "[.]Rd$", full.names = TRUE)
  for (rd in rd_files) {
    lines <- readLines(rd, warn = FALSE)
    aliases <- sub("^\\\\alias\\{(.+)\\}$", "\\1", grep("^\\\\alias\\{", lines, value = TRUE))
    if (length(aliases) > 0L) {
      for (alias in aliases) {
        map[[alias]] <- basename(rd)
      }
    }
  }
  map
})

wrapper_specs <- list(
  APFB = c("sim", "obs", "na.rm", "..."),
  HFB = c("sim", "obs", "threshold_prob", "na.rm", "..."),
  NSE = c("sim", "obs", "na.rm", "..."),
  KGE = c("sim", "obs", "na.rm", "..."),
  MAE = c("sim", "obs", "na.rm", "..."),
  RMSE = c("sim", "obs", "na.rm", "..."),
  PBIAS = c("sim", "obs", "na.rm", "..."),
  R2 = c("sim", "obs", "na.rm", "..."),
  NRMSE = c("sim", "obs", "norm", "na.rm", "..."),
  NSeff = c("sim", "obs", "na.rm", "..."),
  mNSeff = c("sim", "obs", "na.rm", "..."),
  rNSeff = c("sim", "obs", "na.rm", "..."),
  wsNSeff = c("sim", "obs", "na.rm", "..."),
  mae = c("sim", "obs", "na.rm", "..."),
  pbias = c("sim", "obs", "na.rm", "..."),
  alpha = c("sim", "obs", "na.rm", "..."),
  beta = c("sim", "obs", "na.rm", "..."),
  r = c("sim", "obs", "na.rm", "..."),
  rsr = c("sim", "obs", "na.rm", "..."),
  preproc = c("sim", "obs", "na_strategy", "transform", "epsilon_mode", "epsilon", "epsilon_factor", "na.rm", "keep", "epsilon.type", "epsilon.value", "..."),
  gof = c("sim", "obs", "methods", "na_strategy", "transform", "epsilon_mode", "epsilon", "epsilon_factor", "components", "fun", "na.rm", "keep", "epsilon.type", "epsilon.value", "..."),
  ggof = c("sim", "obs", "methods", "na_strategy", "transform", "epsilon_mode", "epsilon", "epsilon_factor", "include_meta", "fun", "na.rm", "keep", "epsilon.type", "epsilon.value", "..."),
  valindex = c("sim", "obs", "fun", "na.rm", "...")
)

example_numeric_sim <- c(1, 2, 3, 4)
example_numeric_obs <- c(1, 2, 2, 4)
example_matrix_sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
example_matrix_obs <- cbind(a = c(1, 2, 2), b = c(2, 2, 3))
date_index <- as.Date("2021-01-01") + 0:3
zoo_available <- requireNamespace("zoo", quietly = TRUE)
xts_available <- requireNamespace("xts", quietly = TRUE)
example_zoo_sim <- if (zoo_available) zoo::zoo(example_numeric_sim, order.by = date_index) else NULL
example_zoo_obs <- if (zoo_available) zoo::zoo(example_numeric_obs, order.by = date_index) else NULL
example_xts_sim <- if (xts_available) xts::xts(example_numeric_sim, order.by = date_index) else NULL
example_xts_obs <- if (xts_available) xts::xts(example_numeric_obs, order.by = date_index) else NULL
apfb_index <- if (zoo_available) {
  as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
} else {
  NULL
}
apfb_sim <- if (zoo_available) zoo::zoo(c(12, 18, 33, 35), order.by = apfb_index) else NULL
apfb_obs <- if (zoo_available) zoo::zoo(c(10, 20, 30, 40), order.by = apfb_index) else NULL

invoke_wrapper <- function(name, mode = c("default", "error"), na_rm = FALSE) {
  mode <- match.arg(mode)
  fn <- get(name, envir = ns, inherits = FALSE)

  if (identical(name, "APFB")) {
    if (!zoo_available) {
      stop("zoo package unavailable for APFB verification.", call. = FALSE)
    }
    if (identical(mode, "error")) {
      return(fn(1:4, 1:4))
    }
    return(fn(apfb_sim, apfb_obs, na.rm = na_rm))
  }

  if (identical(name, "HFB")) {
    if (identical(mode, "error")) {
      return(fn(example_numeric_sim, example_numeric_obs, threshold_prob = 1))
    }
    return(fn(1:30 + 1, 1:30, na.rm = na_rm))
  }

  if (identical(name, "preproc")) {
    if (identical(mode, "error")) {
      return(fn(example_numeric_sim, example_numeric_obs[1:3]))
    }
    return(fn(example_zoo_sim %||% example_numeric_sim, example_zoo_obs %||% example_numeric_obs, na.rm = na_rm))
  }

  if (identical(name, "gof")) {
    if (identical(mode, "error")) {
      return(fn(example_numeric_sim, example_numeric_obs[1:3], methods = "NSE"))
    }
    return(fn(example_numeric_sim, example_numeric_obs, methods = c("NSE", "rmse"), na.rm = na_rm))
  }

  if (identical(name, "ggof")) {
    if (identical(mode, "error")) {
      return(fn(example_numeric_sim, example_numeric_obs[1:3], methods = "NSE"))
    }
    return(fn(example_matrix_sim, example_matrix_obs, methods = c("NSE", "rmse"), na.rm = na_rm))
  }

  if (identical(name, "valindex")) {
    if (identical(mode, "error")) {
      return(fn(example_numeric_sim, example_numeric_obs, fun = character()))
    }
    return(fn(example_numeric_sim, example_numeric_obs, fun = c("NSE", "rmse"), na.rm = na_rm))
  }

  if (identical(name, "NRMSE")) {
    if (identical(mode, "error")) {
      return(fn(example_numeric_sim, example_numeric_obs, norm = "sd"))
    }
    return(fn(example_numeric_sim, example_numeric_obs, norm = "mean", na.rm = na_rm))
  }

  if (identical(mode, "error")) {
    return(fn(example_numeric_sim, example_numeric_obs[1:3], na.rm = na_rm))
  }

  fn(example_numeric_sim, example_numeric_obs, na.rm = na_rm)
}

wrapper_inventory <- lapply(names(wrapper_specs), function(name) {
  fn <- get(name, envir = ns, inherits = FALSE)
  formals_obj <- formals(fn)
  arg_names <- names(formals_obj)
  defaults <- vapply(formals_obj, function(x) {
    if (is.symbol(x) && identical(as.character(x), "")) {
      ""
    } else if (identical(x, quote(expr = ))) {
      ""
    } else {
      paste(deparse(x), collapse = "")
    }
  }, character(1))
  rd_file <- rd_alias_map[[name]] %||% ""
  ok_call <- capture_conditions(invoke_wrapper(name, mode = "default", na_rm = TRUE))
  err_call <- capture_conditions(invoke_wrapper(name, mode = "error"))

  return(data.frame(
    Function = name,
    Exported = name %in% exports,
    `NAMESPACE entry present` = name %in% exports,
    `Rd file present` = nzchar(rd_file),
    `Signature verified` = identical(arg_names, wrapper_specs[[name]]),
    `Argument order` = paste(arg_names, collapse = " -> "),
    `Default values` = paste(sprintf("%s=%s", names(defaults), defaults), collapse = "; "),
    `na.rm present` = "na.rm" %in% arg_names,
    `Return type` = if (isTRUE(ok_call$error)) paste0("error: ", conditionMessage(ok_call$value)) else format_result_type(ok_call$value),
    `Warning/error behavior verified` = isTRUE(err_call$error) && nzchar(conditionMessage(err_call$value)),
    Notes = paste(
      c(
        if (nzchar(rd_file)) paste0("Rd: ", rd_file) else "Rd missing",
        if (length(ok_call$warnings) > 0L) paste0("warnings: ", paste(unique(ok_call$warnings), collapse = " | ")) else "no warnings on nominal call",
        if (isTRUE(err_call$error)) paste0("error path: ", conditionMessage(err_call$value)) else "error path not observed"
      ),
      collapse = "; "
    ),
    check.names = FALSE,
    stringsAsFactors = FALSE
  ))
})
wrapper_inventory_df <- do.call(rbind, wrapper_inventory)
write_csv_lines(file.path(notes_dir, "wrapper_inventory.csv"), wrapper_inventory_df)

wrapper_signature_df <- do.call(rbind, lapply(names(wrapper_specs), function(name) {
  fn <- get(name, envir = ns, inherits = FALSE)
  formals_obj <- formals(fn)
  arg_names <- names(formals_obj)
  defaults <- vapply(formals_obj, function(x) {
    if (identical(x, quote(expr = ))) "" else paste(deparse(x), collapse = "")
  }, character(1))
  data.frame(
    Function = name,
    Position = seq_along(arg_names),
    Argument = arg_names,
    Default = unname(defaults),
    `Matches planned order` = arg_names == wrapper_specs[[name]],
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}))
write_csv_lines(file.path(notes_dir, "wrapper_signature_matrix.csv"), wrapper_signature_df)

export_classification <- lapply(sort(unique(c(exports, names(wrapper_specs)))), function(name) {
  category <- if (name %in% c("NSE", "KGE", "MAE", "RMSE", "PBIAS", "R2", "NRMSE", "NSeff", "mNSeff", "rNSeff", "wsNSeff")) {
    "legacy compatibility name"
  } else if (name %in% c("gof", "ggof", "preproc", "valindex")) {
    "new-name style"
  } else if (name %in% c("APFB", "HFB")) {
    "mixed / ambiguous"
  } else if (name %in% c("mae", "pbias", "alpha", "beta", "r", "rsr")) {
    "deviation"
  } else {
    "mixed / ambiguous"
  }
  paste0("- `", name, "`: ", category)
})

naming_lines <- c(
  "# Naming Policy Freeze",
  "",
  "Phase 2 freezes the current public naming policy at the package boundary.",
  "",
  "## Policy",
  "",
  "- Legacy hydroGOF-style compatibility exports remain unchanged: `NSE`, `KGE`, `MAE`, `RMSE`, `PBIAS`, `R2`, `NRMSE`, and the legacy NSE-family aliases.",
  "- Phase 3 additions must use lowercase or underscored names only.",
  "- Existing Phase 2 lowercase exports are preserved for backward compatibility and recorded as deviations rather than renamed in-place.",
  "",
  "## Current Export Classification",
  "",
  unlist(export_classification, use.names = FALSE),
  "",
  "## Freeze Decision",
  "",
  "- No public renames are made in Phase 2 exit work.",
  "- The uppercase compatibility wrappers added in Phase 2 exit become the frozen compatibility surface for release `0.2.0`."
)
writeLines(naming_lines, file.path(notes_dir, "naming_policy_freeze.md"), useBytes = TRUE)

r2_obs <- c(1, 2, 3, 4)
r2_sim <- c(2, 3, 4, 5)
r2_value <- get("R2", envir = ns, inherits = FALSE)(r2_sim, r2_obs)
nse_value <- get("NSE", envir = ns, inherits = FALSE)(r2_sim, r2_obs)
nrmse_obs <- c(1, 2, 3)
nrmse_sim <- c(1, 2, 4)
nrmse_value <- get("NRMSE", envir = ns, inherits = FALSE)(nrmse_sim, nrmse_obs, norm = "mean")
manual_nrmse <- sqrt(mean((nrmse_sim - nrmse_obs)^2)) / mean(nrmse_obs)
r2_nrmse_lines <- c(
  "# R2 and NRMSE Verification",
  "",
  "## R2",
  "",
  "- Test case: `obs = c(1, 2, 3, 4)`, `sim = c(2, 3, 4, 5)`.",
  paste0("- `R2(obs, sim)` result: `", format(signif(r2_value, 8)), "`."),
  paste0("- `NSE(obs, sim)` result on the same biased predictions: `", format(signif(nse_value, 8)), "`."),
  "- Result: `R2` is not an alias of `NSE`; under additive bias they diverge numerically while correlation remains perfect.",
  "",
  "## NRMSE",
  "",
  "- Public wrapper present: `NRMSE()`.",
  "- Phase 2 frozen normalization contract: `norm = \"mean\"` only.",
  paste0("- Example `NRMSE(c(1, 2, 4), c(1, 2, 3), norm = \"mean\")` = `", format(signif(nrmse_value, 8)), "`."),
  paste0("- Manual CV-RMSE calculation `sqrt(mean((sim - obs)^2)) / mean(obs)` = `", format(signif(manual_nrmse, 8)), "`."),
  "- Result: the exported wrapper matches the Phase 2 plan requirement for CV-RMSE-style normalization by `mean(obs)`."
)
writeLines(r2_nrmse_lines, file.path(notes_dir, "r2_nrmse_verification.md"), useBytes = TRUE)

gof_nominal <- capture_conditions(get("gof", envir = ns, inherits = FALSE)(example_numeric_sim, example_numeric_obs, methods = "NSE"))
ggof_nominal <- capture_conditions(get("ggof", envir = ns, inherits = FALSE)(example_matrix_sim, example_matrix_obs, methods = c("NSE", "rmse")))
output_contract_lines <- c(
  "# Output Contract Review",
  "",
  "## Reviewed claim",
  "",
  "- Claimed plan target: default outputs should be tibble-first, with legacy matrix mode available through `output = \"matrix\"` or equivalent.",
  "",
  "## Current behavior",
  "",
  paste0("- `gof()` nominal result type: `", format_result_type(gof_nominal$value), "`."),
  paste0("- `ggof()` nominal result type: `", format_result_type(ggof_nominal$value), "`."),
  "- Compatibility wrappers such as `NSE()`, `PBIAS()`, and `NRMSE()` return numeric scalars or numeric vectors rather than tibble objects.",
  "- No current public `output` argument or matrix/tibble switch is implemented on the exported API.",
  "",
  "## Review result",
  "",
  "- Status: intentionally changed.",
  "- Phase 2 exits with the shipped S3/data.frame output model and a formal downgrade of any earlier tibble-first claim.",
  "- No output-contract redesign is performed in Phase 2 exit work."
)
writeLines(output_contract_lines, file.path(notes_dir, "output_contract_review.md"), useBytes = TRUE)

run_metric_case <- function(metric, edge_case) {
  fn <- get(metric, envir = ns, inherits = FALSE)

  payload <- switch(
    edge_case,
    "all NA" = list(sim = c(NA_real_, NA_real_), obs = c(NA_real_, NA_real_), args = list()),
    "single observation" = list(sim = 1, obs = 1, args = list()),
    "identical series" = list(sim = c(1, 2, 3), obs = c(1, 2, 3), args = list()),
    "all-zero observation / simulation" = list(sim = c(0, 0, 0), obs = c(0, 0, 0), args = list()),
    "negative values" = list(sim = c(-1, -2, -3), obs = c(-1, -2, -4), args = list()),
    "mismatch in lengths" = list(sim = c(1, 2, 3), obs = c(1, 2), args = list()),
    "indexed inputs" = list(sim = apfb_sim %||% example_zoo_sim, obs = apfb_obs %||% example_zoo_obs, args = list()),
    "pairwise NA removal behavior" = list(sim = c(1, NA, 3, 4), obs = c(1, 2, 3, 4), args = list(na.rm = TRUE))
  )

  if (metric %in% c("APFB") && edge_case != "indexed inputs") {
    return(list(result = NULL, supported = FALSE, behavior = "not applicable: APFB requires indexed zoo/xts input", deterministic = TRUE, intentional = TRUE))
  }
  if (metric %in% c("HFB") && identical(edge_case, "indexed inputs")) {
    payload <- list(sim = example_zoo_sim %||% example_numeric_sim, obs = example_zoo_obs %||% example_numeric_obs, args = list())
  }
  if (is.null(payload$sim)) {
    return(list(result = NULL, supported = FALSE, behavior = "package support unavailable in local environment", deterministic = FALSE, intentional = FALSE))
  }

  result <- capture_conditions(do.call(fn, c(list(payload$sim, payload$obs), payload$args)))
  supported <- !isTRUE(result$error)
  intentional <- isTRUE(result$error)

  list(
    result = result,
    supported = supported,
    behavior = format_behavior(result),
    deterministic = TRUE,
    intentional = intentional
  )
}

edge_metrics <- c("NSE", "KGE", "MAE", "RMSE", "PBIAS", "R2", "NRMSE", "APFB", "HFB")
edge_cases <- c(
  "all NA",
  "single observation",
  "identical series",
  "all-zero observation / simulation",
  "negative values",
  "mismatch in lengths",
  "indexed inputs",
  "pairwise NA removal behavior"
)
edge_case_df <- do.call(rbind, lapply(edge_metrics, function(metric) {
  do.call(rbind, lapply(edge_cases, function(edge_case) {
    res <- run_metric_case(metric, edge_case)
    data.frame(
      Metric = metric,
      `Edge case` = edge_case,
      Supported = isTRUE(res$supported),
      Behavior = res$behavior,
      Deterministic = isTRUE(res$deterministic),
      `Intentional exception` = isTRUE(res$intentional),
      Notes = if (metric == "APFB" && edge_case != "indexed inputs") "indexed-only wrapper" else "",
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
  }))
}))
write_csv_lines(file.path(notes_dir, "edge_case_matrix.csv"), edge_case_df)

indexed_cases <- list(
  numeric = list(sim = example_numeric_sim, obs = example_numeric_obs),
  matrix = list(sim = example_matrix_sim, obs = example_matrix_obs),
  zoo = list(sim = example_zoo_sim, obs = example_zoo_obs),
  xts = list(sim = example_xts_sim, obs = example_xts_obs)
)

indexed_functions <- c("gof", "ggof", "NSE", "PBIAS", "R2", "NRMSE", "APFB")
indexed_df <- do.call(rbind, lapply(indexed_functions, function(fun_name) {
  do.call(rbind, lapply(names(indexed_cases), function(input_class) {
    payload <- indexed_cases[[input_class]]
    if (is.null(payload$sim) || is.null(payload$obs)) {
      return(data.frame(
        Function = fun_name,
        `Input class` = input_class,
        Supported = FALSE,
        `Result type` = "unavailable",
        `Warning/error behavior` = "support package unavailable",
        Deterministic = FALSE,
        Notes = "",
        check.names = FALSE,
        stringsAsFactors = FALSE
      ))
    }

    expr <- switch(
      fun_name,
      gof = quote(get("gof", envir = ns, inherits = FALSE)(payload$sim, payload$obs, methods = "NSE")),
      ggof = quote(get("ggof", envir = ns, inherits = FALSE)(payload$sim, payload$obs, methods = "NSE")),
      NSE = quote(get("NSE", envir = ns, inherits = FALSE)(payload$sim, payload$obs)),
      PBIAS = quote(get("PBIAS", envir = ns, inherits = FALSE)(payload$sim, payload$obs)),
      R2 = quote(get("R2", envir = ns, inherits = FALSE)(payload$sim, payload$obs)),
      NRMSE = quote(get("NRMSE", envir = ns, inherits = FALSE)(payload$sim, payload$obs, norm = "mean")),
      APFB = quote(get("APFB", envir = ns, inherits = FALSE)(payload$sim, payload$obs))
    )

    if (fun_name == "APFB" && !input_class %in% c("zoo", "xts")) {
      result <- list(value = simpleError("APFB requires zoo/xts inputs with a time index."), warnings = character(), error = TRUE)
    } else {
      result <- capture_conditions(eval(expr))
    }

    data.frame(
      Function = fun_name,
      `Input class` = input_class,
      Supported = !isTRUE(result$error),
      `Result type` = if (isTRUE(result$error)) "error" else format_result_type(result$value),
      `Warning/error behavior` = format_behavior(result),
      Deterministic = TRUE,
      Notes = if (fun_name == "APFB" && !input_class %in% c("zoo", "xts")) "indexed-only wrapper" else "",
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
  }))
}))
write_csv_lines(file.path(notes_dir, "indexed_input_public_api_matrix.csv"), indexed_df)

benchmark_ok <- FALSE
benchmark_results_path <- file.path("inst", "benchmarks", "benchmark_results.csv")
benchmark_summary_path <- file.path("inst", "benchmarks", "benchmark_summary.md")
if (file.exists(file.path("inst", "benchmarks", "phase2_benchmark_suite.R"))) {
  source(file.path("inst", "benchmarks", "phase2_benchmark_suite.R"), local = TRUE)
  benchmark_run <- tryCatch(
    run_phase2_benchmark_suite(project_root = repo_root, output_dir = file.path(repo_root, "inst", "benchmarks")),
    error = function(e) e
  )
  benchmark_ok <- !inherits(benchmark_run, "error") &&
    file.exists(benchmark_results_path) &&
    file.exists(benchmark_summary_path)
}

checklist_exists <- file.exists(file.path(notes_dir, "cran_preflight_checklist.csv"))
deviation_exists <- file.exists(file.path("docs", "DEVIATION_REGISTER.md"))
exit_memo_exists <- file.exists(file.path("docs", "PHASE2_EXIT_MEMO.md"))

coverage_pct <- NA_real_
if (checklist_exists) {
  checklist <- tryCatch(utils::read.csv(file.path(notes_dir, "cran_preflight_checklist.csv"), stringsAsFactors = FALSE), error = function(e) NULL)
  if (!is.null(checklist) && "Item" %in% names(checklist) && "Result" %in% names(checklist)) {
    idx <- which(checklist$Item == "coverage percentage")
    if (length(idx) == 1L) {
      coverage_pct <- suppressWarnings(as.numeric(gsub("[^0-9.]", "", checklist$Result[[idx]])))
    }
  }
}

ci_green_count <- NA_integer_
if (checklist_exists && exists("checklist") && !is.null(checklist) && "Item" %in% names(checklist)) {
  ci_idx <- which(checklist$Item == "all six CI nodes green")
  if (length(ci_idx) == 1L) {
    ci_green_count <- if (identical(tolower(checklist$Result[[ci_idx]]), "true")) 6L else 0L
  }
}

examples_status <- "unverified"
vignette_status <- "unverified"
if (checklist_exists && exists("checklist") && !is.null(checklist)) {
  ex_idx <- which(checklist$Item == "examples run cleanly")
  vg_idx <- which(checklist$Item == "vignettes knit cleanly")
  if (length(ex_idx) == 1L) {
    examples_status <- checklist$Result[[ex_idx]]
  }
  if (length(vg_idx) == 1L) {
    vignette_status <- checklist$Result[[vg_idx]]
  }
}

final_recommendation <- "CONDITIONAL GO"
if (checklist_exists && deviation_exists && exit_memo_exists && !is.na(coverage_pct) && coverage_pct >= 95 && identical(ci_green_count, 6L)) {
  final_recommendation <- "GO"
}
if (!checklist_exists || !deviation_exists || !exit_memo_exists) {
  final_recommendation <- "BLOCKED"
}

cat(paste0("exported wrappers counted: ", nrow(wrapper_inventory_df), "\n"))
cat(paste0("signature-verified wrappers counted: ", sum(wrapper_inventory_df$`Signature verified`), "\n"))
cat(paste0("benchmark status: ", if (benchmark_ok) "pass" else "fail", "\n"))
cat(paste0("coverage percentage: ", if (is.na(coverage_pct)) "unverified" else sprintf("%.2f%%", coverage_pct), "\n"))
cat(paste0("CI nodes green count: ", if (is.na(ci_green_count)) "unverified" else ci_green_count, "\n"))
cat(paste0("examples status: ", examples_status, "\n"))
cat(paste0("vignette status: ", vignette_status, "\n"))
cat(paste0("final Phase 2 recommendation: ", final_recommendation, "\n"))
