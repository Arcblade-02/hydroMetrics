get_workstream_b_benchmark_repo_root <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0L) {
    script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script_path), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

workstream_b_benchmark_session_lines <- function() {
  capture.output(sessionInfo())
}

.workstream_b_iterations <- function(n) {
  if (n <= 1e3L) {
    return(20L)
  }
  if (n <= 1e5L) {
    return(10L)
  }
  3L
}

.workstream_b_measure <- function(fn, iterations) {
  microbenchmark::microbenchmark(fn(), times = iterations)$time / 1e9
}

.workstream_b_single_inputs <- function(n, seed) {
  set.seed(seed)
  obs <- stats::rnorm(n, mean = 50, sd = 12)
  sim <- obs + stats::rnorm(n, mean = 0, sd = 4)
  list(sim = sim, obs = obs)
}

.workstream_b_matrix_inputs <- function(n, seed, cols = 3L) {
  set.seed(seed)
  obs_base <- stats::rnorm(n, mean = 50, sd = 12)
  obs <- vapply(seq_len(cols), function(i) {
    obs_base + stats::rnorm(n, mean = 0, sd = 0.5 * i)
  }, numeric(n))
  sim <- vapply(seq_len(cols), function(i) {
    obs[, i] + stats::rnorm(n, mean = 0, sd = 4 + i)
  }, numeric(n))
  colnames(obs) <- paste0("series", seq_len(cols))
  colnames(sim) <- paste0("series", seq_len(cols))
  list(sim = sim, obs = obs)
}

run_workstream_b_benchmark_suite <- function(project_root = get_workstream_b_benchmark_repo_root(),
                                             output_dir = file.path(project_root, "inst", "benchmarks")) {
  if (!requireNamespace("microbenchmark", quietly = TRUE)) {
    stop("The 'microbenchmark' package is required for the Workstream B benchmark baseline.", call. = FALSE)
  }

  project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  if (requireNamespace("devtools", quietly = TRUE)) {
    devtools::load_all(path = project_root, quiet = TRUE)
  } else {
    suppressPackageStartupMessages(library(hydroMetrics))
  }

  nseff <- get("NSeff", envir = asNamespace("hydroMetrics"), inherits = FALSE)
  gof_fn <- get("gof", envir = asNamespace("hydroMetrics"), inherits = FALSE)

  generated_at <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
  sizes <- c(1e3L, 1e5L, 1e6L)
  results <- list()

  for (i in seq_along(sizes)) {
    n <- sizes[[i]]
    iterations <- .workstream_b_iterations(n)
    single <- .workstream_b_single_inputs(n, seed = 20260315L + i)
    matrix_inputs <- .workstream_b_matrix_inputs(n, seed = 20261315L + i, cols = 3L)

    target_times <- list(
      NSeff = .workstream_b_measure(function() nseff(single$sim, single$obs), iterations),
      gof_nse = .workstream_b_measure(function() gof_fn(single$sim, single$obs, methods = "nse"), iterations),
      gof_default_compat10 = .workstream_b_measure(function() gof_fn(single$sim, single$obs), iterations),
      gof_matrix_nse_rmse = .workstream_b_measure(function() {
        gof_fn(matrix_inputs$sim, matrix_inputs$obs, methods = c("nse", "rmse"))
      }, iterations)
    )

    nseff_mean <- mean(target_times$NSeff)
    nseff_median <- stats::median(target_times$NSeff)

    results[[length(results) + 1L]] <- data.frame(
      generated_at = generated_at,
      target = "NSeff",
      input_size = n,
      series_shape = "single",
      iterations = iterations,
      mean_elapsed_sec = nseff_mean,
      median_elapsed_sec = nseff_median,
      relative_overhead_vs_nseff_mean = 1,
      relative_overhead_vs_nseff_median = 1,
      stringsAsFactors = FALSE
    )
    results[[length(results) + 1L]] <- data.frame(
      generated_at = generated_at,
      target = "gof_nse",
      input_size = n,
      series_shape = "single",
      iterations = iterations,
      mean_elapsed_sec = mean(target_times$gof_nse),
      median_elapsed_sec = stats::median(target_times$gof_nse),
      relative_overhead_vs_nseff_mean = mean(target_times$gof_nse) / nseff_mean,
      relative_overhead_vs_nseff_median = stats::median(target_times$gof_nse) / nseff_median,
      stringsAsFactors = FALSE
    )
    results[[length(results) + 1L]] <- data.frame(
      generated_at = generated_at,
      target = "gof_default_compat10",
      input_size = n,
      series_shape = "single",
      iterations = iterations,
      mean_elapsed_sec = mean(target_times$gof_default_compat10),
      median_elapsed_sec = stats::median(target_times$gof_default_compat10),
      relative_overhead_vs_nseff_mean = mean(target_times$gof_default_compat10) / nseff_mean,
      relative_overhead_vs_nseff_median = stats::median(target_times$gof_default_compat10) / nseff_median,
      stringsAsFactors = FALSE
    )
    results[[length(results) + 1L]] <- data.frame(
      generated_at = generated_at,
      target = "gof_matrix_nse_rmse",
      input_size = n,
      series_shape = "matrix_3col",
      iterations = iterations,
      mean_elapsed_sec = mean(target_times$gof_matrix_nse_rmse),
      median_elapsed_sec = stats::median(target_times$gof_matrix_nse_rmse),
      relative_overhead_vs_nseff_mean = NA_real_,
      relative_overhead_vs_nseff_median = NA_real_,
      stringsAsFactors = FALSE
    )
  }

  results_df <- do.call(rbind, results)
  results_path <- file.path(output_dir, "workstream_b_benchmark_results.csv")
  utils::write.csv(results_df, results_path, row.names = FALSE)

  table_header <- "| target | shape | n | iterations | mean_sec | median_sec | rel_mean_vs_NSeff | rel_median_vs_NSeff |"
  table_rule <- "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |"
  table_lines <- apply(results_df, 1, function(row) {
    rel_mean <- if (is.na(as.numeric(row[["relative_overhead_vs_nseff_mean"]]))) "NA" else sprintf("%.6f", as.numeric(row[["relative_overhead_vs_nseff_mean"]]))
    rel_median <- if (is.na(as.numeric(row[["relative_overhead_vs_nseff_median"]]))) "NA" else sprintf("%.6f", as.numeric(row[["relative_overhead_vs_nseff_median"]]))
    sprintf(
      "| `%s` | `%s` | %s | %s | %.6f | %.6f | %s | %s |",
      row[["target"]],
      row[["series_shape"]],
      format(as.integer(row[["input_size"]]), scientific = FALSE),
      row[["iterations"]],
      as.numeric(row[["mean_elapsed_sec"]]),
      as.numeric(row[["median_elapsed_sec"]]),
      rel_mean,
      rel_median
    )
  })

  summary_lines <- c(
    "# Workstream B Benchmark Summary",
    "",
    paste0("- Generated: ", generated_at),
    "- Status: active current benchmark baseline for the remediated `0.3.1` development line.",
    "- Methodology: benchmark current public-facing orchestration paths rather than internal metric functions or retired uppercase wrapper calls.",
    "- Targets: `NSeff(sim, obs)`, `gof(sim, obs, methods = \"nse\")`, `gof(sim, obs)`, and `gof(sim_matrix, obs_matrix, methods = c(\"nse\", \"rmse\"))`.",
    "- Input scales: `1e3`, `1e5`, and `1e6` rows; the multi-series path uses `3` aligned columns.",
    "- Timing backend: `microbenchmark` nanosecond timer. This baseline requires `microbenchmark` rather than silently changing timing methodology.",
    "- Repetitions: `20` at `1e3`, `10` at `1e5`, and `3` at `1e6`.",
    "- Assumptions: deterministic seeded Gaussian-style numeric inputs, no missing values, and no preprocessing-sensitive options.",
    "- Intended usage: local/manual reproducible baseline first; optional CI summary generation later, but not a gating performance budget.",
    "- Relative overhead is reported against `NSeff` at the same scale for the single-series paths; the matrix path is reported directly and left `NA` for that comparison.",
    "",
    "## Results",
    "",
    table_header,
    table_rule,
    table_lines,
    "",
    "## Session Info",
    "",
    workstream_b_benchmark_session_lines()
  )

  summary_path <- file.path(output_dir, "workstream_b_benchmark_summary.md")
  writeLines(summary_lines, summary_path, useBytes = TRUE)

  list(
    results = results_df,
    results_path = results_path,
    summary_path = summary_path
  )
}
