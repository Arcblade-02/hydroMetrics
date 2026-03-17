get_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) == 0L) {
    stop("Script path not available from commandArgs().", call. = FALSE)
  }
  normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE)
}

script_path <- get_script_path()
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
suite_path <- file.path(repo_root, "inst", "benchmarks", "workstream_b_benchmark_suite.R")

if (!file.exists(suite_path)) {
  stop("Benchmark baseline suite not found at inst/benchmarks/workstream_b_benchmark_suite.R", call. = FALSE)
}

source(suite_path, chdir = FALSE)

result <- run_workstream_b_benchmark_suite(project_root = repo_root)

cat("Workstream B benchmark baseline results:\n")
print(result$results, row.names = FALSE)
cat("\nSummary written to:\n")
cat(result$summary_path, "\n", sep = "")
