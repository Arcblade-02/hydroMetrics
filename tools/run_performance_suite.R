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
suite_path <- file.path(repo_root, "inst", "benchmarks", "performance_suite.R")

if (!file.exists(suite_path)) {
  stop("Benchmark suite not found at inst/benchmarks/performance_suite.R", call. = FALSE)
}

source(suite_path, chdir = FALSE)

result <- run_performance_suite(project_root = repo_root)

cat("Performance summary:\n")
print(result$summary, row.names = FALSE)

if (length(result$errors) > 0L) {
  cat("\nErrors detected:\n")
  for (msg in result$errors) {
    cat(" - ", msg, "\n", sep = "")
  }
  stop("Performance suite completed with errors.", call. = FALSE)
}

cat("\nPerformance suite completed without errors.\n")
