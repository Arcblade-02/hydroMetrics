.perf_write_lines <- function(path, lines) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines, con = path, useBytes = TRUE)
}

.perf_time_lines <- function(x) {
  sprintf(
    "%s: %.6f",
    c("user", "system", "elapsed"),
    as.numeric(x[c("user.self", "sys.self", "elapsed")])
  )
}

.perf_memory_mb <- function() {
  if (.Platform$OS.type == "windows" && exists("memory.size", mode = "function")) {
    mem <- suppressWarnings(as.numeric(memory.size(max = FALSE)))
    if (is.finite(mem)) {
      return(mem)
    }
  }

  if (requireNamespace("pryr", quietly = TRUE)) {
    return(as.numeric(pryr::mem_used()) / (1024 ^ 2))
  }

  gc_out <- gc()
  if ("(Mb)" %in% colnames(gc_out)) {
    return(as.numeric(sum(gc_out[, "(Mb)"])))
  }
  as.numeric(sum(gc_out[, "used"]))
}

.perf_extract_pct <- function(by_self, pattern) {
  if (is.null(by_self) || nrow(by_self) == 0L) {
    return(NA_real_)
  }

  time_col <- if ("self.time" %in% colnames(by_self)) "self.time" else colnames(by_self)[[1]]
  total <- sum(by_self[, time_col], na.rm = TRUE)
  if (is.na(total) || total <= 0) {
    return(NA_real_)
  }

  idx <- grepl(pattern, rownames(by_self), ignore.case = TRUE, perl = TRUE)
  if (!any(idx)) {
    return(0)
  }

  sum(by_self[idx, time_col], na.rm = TRUE) / total * 100
}

run_performance_suite <- function(project_root = ".", output_dir = file.path(project_root, "notes", "performance")) {
  project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  if (!requireNamespace("microbenchmark", quietly = TRUE)) {
    stop("The 'microbenchmark' package is required for performance_suite.R.", call. = FALSE)
  }

  if (requireNamespace("devtools", quietly = TRUE)) {
    devtools::load_all(path = project_root, quiet = TRUE)
  } else {
    suppressPackageStartupMessages(library(hydroMetrics))
  }

  metric_nse <- get("metric_nse", envir = asNamespace("hydroMetrics"), inherits = FALSE)
  gof_fn <- get("gof", envir = asNamespace("hydroMetrics"), inherits = FALSE)

  summary_values <- list()
  run_errors <- character()

  set.seed(20260305L)

  # SECTION 1 - MICROBENCHMARK
  n_micro <- 10000L
  sim_micro <- stats::rnorm(n_micro, mean = 50, sd = 12)
  obs_micro <- sim_micro + stats::rnorm(n_micro, mean = 0, sd = 4)
  sim_micro_matrix <- cbind(model1 = sim_micro, model2 = sim_micro * 1.02, model3 = sim_micro * 0.98)
  obs_micro_matrix <- cbind(model1 = obs_micro, model2 = obs_micro * 1.01, model3 = obs_micro * 0.99)

  mb <- microbenchmark::microbenchmark(
    direct_nse = metric_nse(sim_micro, obs_micro),
    gof_single = gof_fn(sim_micro, obs_micro, methods = "NSE"),
    gof_multi = gof_fn(sim_micro, obs_micro, methods = c("NSE", "KGE", "rmse", "pbias")),
    gof_batch = gof_fn(sim_micro_matrix, obs_micro_matrix, methods = c("NSE", "KGE")),
    times = 100L
  )
  mb_summary <- summary(mb)
  micro_path <- file.path(output_dir, "microbenchmark_results.txt")
  .perf_write_lines(
    micro_path,
    c(
      "SECTION 1 - MICROBENCHMARK (n=10000, iterations=100)",
      paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      "",
      capture.output(print(mb_summary, row.names = FALSE))
    )
  )

  summary_values$direct_nse_median_ns <- unname(mb_summary$median[mb_summary$expr == "direct_nse"][[1]])
  summary_values$gof_single_median_ns <- unname(mb_summary$median[mb_summary$expr == "gof_single"][[1]])
  summary_values$gof_multi_median_ns <- unname(mb_summary$median[mb_summary$expr == "gof_multi"][[1]])
  summary_values$gof_batch_median_ns <- unname(mb_summary$median[mb_summary$expr == "gof_batch"][[1]])

  # SECTION 2 - LARGE VECTOR STRESS TEST
  n_large <- 1e6L
  sim_large <- stats::rnorm(n_large, mean = 100, sd = 20)
  obs_large <- sim_large + stats::rnorm(n_large, mean = 0, sd = 8)
  tm_large <- system.time(invisible(gof_fn(sim_large, obs_large)))
  large_path <- file.path(output_dir, "large_vector_test.txt")
  .perf_write_lines(
    large_path,
    c(
      "SECTION 2 - LARGE VECTOR STRESS TEST (n=1e6)",
      paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      .perf_time_lines(tm_large)
    )
  )
  summary_values$large_vector_elapsed_sec <- as.numeric(tm_large[["elapsed"]])

  # SECTION 3 - MATRIX SCALING TEST
  n_scale <- 50000L
  sim_scale_base <- matrix(stats::rnorm(n_scale * 20L, mean = 20, sd = 6), nrow = n_scale, ncol = 20L)
  obs_scale_base <- sim_scale_base + matrix(stats::rnorm(n_scale * 20L, sd = 2), nrow = n_scale, ncol = 20L)

  tm_scale_10 <- system.time(invisible(gof_fn(sim_scale_base[, 1:10, drop = FALSE], obs_scale_base[, 1:10, drop = FALSE])))
  tm_scale_20 <- system.time(invisible(gof_fn(sim_scale_base, obs_scale_base)))
  ratio_20_vs_10 <- as.numeric(tm_scale_20[["elapsed"]] / tm_scale_10[["elapsed"]])
  linear_scaling <- is.finite(ratio_20_vs_10) && ratio_20_vs_10 >= 1.5 && ratio_20_vs_10 <= 2.5

  scale_path <- file.path(output_dir, "matrix_scaling_test.txt")
  .perf_write_lines(
    scale_path,
    c(
      "SECTION 3 - MATRIX SCALING TEST (n=50000, m=20)",
      paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      "",
      "m=10 timing:",
      .perf_time_lines(tm_scale_10),
      "",
      "m=20 timing:",
      .perf_time_lines(tm_scale_20),
      "",
      sprintf("elapsed_ratio_m20_to_m10: %.6f", ratio_20_vs_10),
      sprintf("linear_scaling_confirmed: %s", if (linear_scaling) "TRUE" else "FALSE")
    )
  )
  summary_values$matrix_scaling_elapsed_sec <- as.numeric(tm_scale_20[["elapsed"]])

  # SECTION 4 - MEMORY STABILITY TEST
  sim_mem <- stats::rnorm(2000L, mean = 30, sd = 10)
  obs_mem <- sim_mem + stats::rnorm(2000L, sd = 3)
  invisible(gc(reset = TRUE))
  mem_before <- .perf_memory_mb()
  for (i in seq_len(1000L)) {
    invisible(gof_fn(sim_mem, obs_mem, methods = "NSE"))
  }
  invisible(gc())
  mem_after <- .perf_memory_mb()
  mem_delta <- mem_after - mem_before
  mem_path <- file.path(output_dir, "memory_stability_test.txt")
  .perf_write_lines(
    mem_path,
    c(
      "SECTION 4 - MEMORY STABILITY TEST (1000 runs)",
      paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      sprintf("memory_before_mb: %.6f", mem_before),
      sprintf("memory_after_mb: %.6f", mem_after),
      sprintf("memory_delta_mb: %.6f", mem_delta)
    )
  )
  summary_values$memory_delta_mb <- mem_delta

  # SECTION 5 - REGISTRY PROFILING
  profile_path <- file.path(output_dir, "registry_profile.out")
  sim_profile <- stats::rnorm(50000L, mean = 10, sd = 4)
  obs_profile <- sim_profile + stats::rnorm(50000L, sd = 2)
  utils::Rprof(profile_path, interval = 0.001)
  for (i in seq_len(200L)) {
    invisible(gof_fn(sim_profile, obs_profile, methods = c("NSE", "KGE", "rmse", "pbias")))
  }
  utils::Rprof(NULL)
  profile_summary <- summaryRprof(profile_path)
  by_self <- profile_summary$by.self
  if (is.null(by_self)) {
    by_self <- data.frame()
  }
  metric_pct <- .perf_extract_pct(by_self, "(^|:::)metric_|(^|:::)compute_")
  dispatch_pct <- .perf_extract_pct(by_self, "registry|dispatch|\\.gof_|evaluate|resolve_methods")
  profile_note <- "Computed from summaryRprof(by.self)."
  if (nrow(by_self) == 0L || is.na(metric_pct) || is.na(dispatch_pct)) {
    metric_pct <- as.numeric(summary_values$direct_nse_median_ns / summary_values$gof_single_median_ns) * 100
    dispatch_pct <- 100 - metric_pct
    profile_note <- "No Rprof samples captured; used direct NSE vs gof single median ratio fallback."
  }
  reg_path <- file.path(output_dir, "registry_profile_summary.txt")
  .perf_write_lines(
    reg_path,
    c(
      "SECTION 5 - REGISTRY PROFILING",
      paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      profile_note,
      sprintf("metric_time_pct: %.6f", metric_pct),
      sprintf("registry_dispatch_time_pct: %.6f", dispatch_pct),
      "",
      "Top self-time functions:",
      capture.output(print(utils::head(by_self, n = 15)))
    )
  )
  summary_values$metric_time_pct <- metric_pct
  summary_values$registry_dispatch_pct <- dispatch_pct

  # SECTION 6 - EDGE CASE ROBUSTNESS
  run_case <- function(case_name, sim, obs, transform = "none", epsilon = NULL) {
    warnings <- character()
    execute <- function() {
      withCallingHandlers(
        gof_fn(
          sim = sim,
          obs = obs,
          methods = c("NSE", "rmse", "pbias"),
          na_strategy = "remove",
          transform = transform,
          epsilon_mode = "constant",
          epsilon = epsilon
        ),
        warning = function(w) {
          warnings <<- c(warnings, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      )
    }

    first <- tryCatch(execute(), error = function(e) e)
    second <- tryCatch(execute(), error = function(e) e)

    deterministic <- FALSE
    if (inherits(first, "error") && inherits(second, "error")) {
      deterministic <- identical(conditionMessage(first), conditionMessage(second))
    } else if (!inherits(first, "error") && !inherits(second, "error")) {
      deterministic <- isTRUE(all.equal(as.numeric(first$metrics), as.numeric(second$metrics), tolerance = 0, check.attributes = FALSE))
    }

    has_overflow <- any(grepl("overflow", warnings, ignore.case = TRUE))
    status <- if (inherits(first, "error")) "handled_error" else "ok"

    data.frame(
      case = case_name,
      status = status,
      deterministic = deterministic,
      warning_count = length(warnings),
      overflow_warning = has_overflow,
      stringsAsFactors = FALSE
    )
  }

  edge_rows <- rbind(
    run_case("all_na_input", rep(NA_real_, 1000L), rep(NA_real_, 1000L)),
    run_case("constant_series", rep(7, 1000L), rep(7, 1000L)),
    run_case("zero_variance_obs", stats::rnorm(1000L, mean = 5, sd = 0.1), rep(5, 1000L)),
    run_case("very_small_numbers", rep(1e-12, 1000L) + stats::runif(1000L, 0, 1e-14), rep(1e-12, 1000L)),
    run_case("very_large_numbers", rep(1e12, 1000L) + stats::runif(1000L, 0, 1e9), rep(1e12, 1000L)),
    run_case("log_transform_near_zero", c(0, rep(1e-12, 999L)), c(1e-14, rep(1e-12, 999L)), transform = "log", epsilon = 1e-6)
  )

  edge_path <- file.path(output_dir, "edge_case_results.txt")
  .perf_write_lines(
    edge_path,
    c(
      "SECTION 6 - EDGE CASE ROBUSTNESS",
      paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      "",
      capture.output(print(edge_rows, row.names = FALSE))
    )
  )

  if (any(edge_rows$overflow_warning)) {
    run_errors <- c(run_errors, "Overflow warning detected in edge case section.")
  }

  # SECTION 7 - NAMESPACE LOAD TIME
  rscript <- file.path(R.home("bin"), "Rscript")
  load_script <- tempfile(pattern = "hm_load_time_", fileext = ".R")
  writeLines(
    c(
      "tm <- system.time(suppressPackageStartupMessages(library(hydroMetrics)))",
      "cat(sprintf('user=%.6f\\n', tm[['user.self']]))",
      "cat(sprintf('system=%.6f\\n', tm[['sys.self']]))",
      "cat(sprintf('elapsed=%.6f\\n', tm[['elapsed']]))"
    ),
    con = load_script,
    useBytes = TRUE
  )
  load_output <- tryCatch(
    system2(rscript, load_script, stdout = TRUE, stderr = TRUE),
    error = function(e) e
  )
  unlink(load_script)

  load_lines <- c(
    "SECTION 7 - NAMESPACE LOAD TIME",
    paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"))
  )
  load_elapsed <- NA_real_
  if (inherits(load_output, "error")) {
    run_errors <- c(run_errors, paste("Load time command failed:", conditionMessage(load_output)))
    load_lines <- c(load_lines, "error: unable to measure load time")
  } else {
    load_lines <- c(load_lines, "", load_output)
    elapsed_line <- load_output[grepl("^elapsed=", load_output)]
    if (length(elapsed_line) == 1L) {
      load_elapsed <- as.numeric(sub("^elapsed=", "", elapsed_line))
    }
  }
  load_path <- file.path(output_dir, "load_time.txt")
  .perf_write_lines(load_path, load_lines)
  summary_values$load_time_elapsed_sec <- load_elapsed

  # Final summary record
  summary_df <- data.frame(
    metric = c(
      "direct_nse_median_ns",
      "gof_single_median_ns",
      "gof_multi_median_ns",
      "gof_batch_median_ns",
      "large_vector_elapsed_sec",
      "matrix_scaling_elapsed_sec",
      "memory_delta_mb",
      "metric_time_pct",
      "registry_dispatch_pct",
      "load_time_elapsed_sec"
    ),
    value = as.numeric(unlist(summary_values[c(
      "direct_nse_median_ns",
      "gof_single_median_ns",
      "gof_multi_median_ns",
      "gof_batch_median_ns",
      "large_vector_elapsed_sec",
      "matrix_scaling_elapsed_sec",
      "memory_delta_mb",
      "metric_time_pct",
      "registry_dispatch_pct",
      "load_time_elapsed_sec"
    )])),
    stringsAsFactors = FALSE
  )

  summary_path <- file.path(output_dir, "performance_summary.csv")
  utils::write.csv(summary_df, file = summary_path, row.names = FALSE)

  session_path <- file.path(output_dir, "session_info.txt")
  .perf_write_lines(
    session_path,
    c(
      paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      capture.output(sessionInfo())
    )
  )

  list(
    summary = summary_df,
    errors = unique(run_errors),
    outputs = list(
      microbenchmark = micro_path,
      large_vector = large_path,
      matrix_scaling = scale_path,
      memory_stability = mem_path,
      registry_profile = profile_path,
      registry_summary = reg_path,
      edge_cases = edge_path,
      load_time = load_path,
      summary = summary_path,
      session = session_path
    )
  )
}
