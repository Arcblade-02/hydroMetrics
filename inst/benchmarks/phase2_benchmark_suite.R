get_phase2_benchmark_repo_root <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0L) {
    script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE)
    return(normalizePath(file.path(dirname(script_path), "..", ".."), winslash = "/", mustWork = TRUE))
  }
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

phase2_benchmark_session_lines <- function() {
  capture.output(sessionInfo())
}

run_phase2_benchmark_suite <- function(project_root = get_phase2_benchmark_repo_root(),
                                       output_dir = file.path(project_root, "inst", "benchmarks")) {
  project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  if (requireNamespace("devtools", quietly = TRUE)) {
    devtools::load_all(path = project_root, quiet = TRUE)
  } else {
    suppressPackageStartupMessages(library(hydroMetrics))
  }

  metric_nse <- get("metric_nse", envir = asNamespace("hydroMetrics"), inherits = FALSE)
  nse_wrapper <- get("NSE", envir = asNamespace("hydroMetrics"), inherits = FALSE)
  gof_wrapper <- get("gof", envir = asNamespace("hydroMetrics"), inherits = FALSE)

  benchmark_rows <- list()
  sizes <- c(1e3L, 1e4L, 1e5L, 1e6L)
  generated_at <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")
  use_microbenchmark <- requireNamespace("microbenchmark", quietly = TRUE)

  for (n in sizes) {
    set.seed(20260309L + as.integer(log10(n)))
    sim <- stats::rnorm(n, mean = 50, sd = 12)
    obs <- sim + stats::rnorm(n, mean = 0, sd = 4)

    iterations <- if (n >= 1e6L) 3L else 10L
    if (use_microbenchmark) {
      direct_times <- microbenchmark::microbenchmark(metric_nse(sim, obs), times = iterations)$time / 1e9
      wrapper_times <- microbenchmark::microbenchmark(nse_wrapper(sim, obs), times = iterations)$time / 1e9
      gof_times <- microbenchmark::microbenchmark(gof_wrapper(sim, obs, methods = "NSE"), times = iterations)$time / 1e9
    } else {
      direct_times <- numeric()
      wrapper_times <- numeric()
      gof_times <- numeric()

      for (i in seq_len(iterations)) {
        direct_times[[i]] <- as.numeric(system.time(metric_nse(sim, obs))[["elapsed"]])
        wrapper_times[[i]] <- as.numeric(system.time(nse_wrapper(sim, obs))[["elapsed"]])
        gof_times[[i]] <- as.numeric(system.time(gof_wrapper(sim, obs, methods = "NSE"))[["elapsed"]])
      }
    }

    direct_baseline <- mean(direct_times)
    relative_to_baseline <- function(x) {
      if (!is.finite(direct_baseline) || direct_baseline <= 0) {
        rep(NA_real_, length(x))
      } else {
        x / direct_baseline
      }
    }
    benchmark_rows[[length(benchmark_rows) + 1L]] <- data.frame(
      path = "direct_metric_nse",
      input_size = n,
      iteration = seq_along(direct_times),
      elapsed_sec = direct_times,
      relative_overhead = rep(1, length(direct_times)),
      stringsAsFactors = FALSE
    )
    benchmark_rows[[length(benchmark_rows) + 1L]] <- data.frame(
      path = "NSE_wrapper",
      input_size = n,
      iteration = seq_along(wrapper_times),
      elapsed_sec = wrapper_times,
      relative_overhead = relative_to_baseline(wrapper_times),
      stringsAsFactors = FALSE
    )
    benchmark_rows[[length(benchmark_rows) + 1L]] <- data.frame(
      path = "gof_NSE",
      input_size = n,
      iteration = seq_along(gof_times),
      elapsed_sec = gof_times,
      relative_overhead = relative_to_baseline(gof_times),
      stringsAsFactors = FALSE
    )
  }

  benchmark_df <- do.call(rbind, benchmark_rows)
  benchmark_path <- file.path(output_dir, "benchmark_results.csv")
  utils::write.csv(benchmark_df, benchmark_path, row.names = FALSE)

  summary_df <- stats::aggregate(
    cbind(elapsed_sec, relative_overhead) ~ path + input_size,
    data = benchmark_df,
    FUN = function(x) c(mean = mean(x, na.rm = TRUE), median = stats::median(x, na.rm = TRUE))
  )

  summary_lines <- c(
    "# Phase 2 Benchmark Summary",
    "",
    paste0("- Generated: ", generated_at),
    "- Methodology: compare direct `metric_nse()` execution, the `NSE()` compatibility wrapper, and `gof(methods = \"NSE\")` on identical numeric inputs.",
    "- Input sizes: 1e3, 1e4, 1e5, and 1e6.",
    paste0("- Timing backend: ", if (use_microbenchmark) "`microbenchmark` nanosecond timer." else "`system.time()` elapsed seconds fallback."),
    "- Repetitions: 10 iterations for sizes below 1e6; 3 iterations at 1e6 for feasibility.",
    "- Reproducibility: deterministic random seed per input size; results written to `inst/benchmarks/benchmark_results.csv`.",
    "",
    "## Aggregated Results",
    ""
  )

  for (i in seq_len(nrow(summary_df))) {
    summary_lines <- c(
      summary_lines,
      sprintf(
        "- `%s`, n=%s: mean elapsed %.6fs, median elapsed %.6fs, mean relative overhead %.6fx, median relative overhead %.6fx",
        summary_df$path[[i]],
        format(summary_df$input_size[[i]], scientific = FALSE),
        summary_df$elapsed_sec[i, "mean"],
        summary_df$elapsed_sec[i, "median"],
        summary_df$relative_overhead[i, "mean"],
        summary_df$relative_overhead[i, "median"]
      )
    )
  }

  summary_lines <- c(
    summary_lines,
    "",
    "## Session Info",
    "",
    phase2_benchmark_session_lines()
  )

  summary_path <- file.path(output_dir, "benchmark_summary.md")
  writeLines(summary_lines, summary_path, useBytes = TRUE)

  list(
    results = benchmark_df,
    summary = summary_df,
    results_path = benchmark_path,
    summary_path = summary_path
  )
}
