root_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

path_in_repo <- function(...) {
  file.path(root_dir, ...)
}

read_text <- function(path) {
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

require_populated_file <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("Missing required artifact: %s", path), call. = FALSE)
  }

  info <- file.info(path)
  if (is.na(info$size) || info$size <= 0) {
    stop(sprintf("Artifact exists but is empty: %s", path), call. = FALSE)
  }

  invisible(path)
}

extract_backtick_value <- function(lines, field) {
  pattern <- sprintf("^- %s: `(.+)`$", gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", field))
  hit <- grep(pattern, lines, value = TRUE)
  if (length(hit) == 0L) {
    stop(sprintf("Missing field '%s' in evidence artifacts.", field), call. = FALSE)
  }
  sub(pattern, "\\1", hit[[1]])
}

notes_dir <- path_in_repo("notes", "final-cran-evidence")
required_files <- c(
  "nonbroken_environment_report.md",
  "devtools_check_results.txt",
  "devtools_check_cran_results.txt",
  "live_ci_status_report.md",
  "final_cran_evidence_summary.md"
)

if (!dir.exists(notes_dir)) {
  stop(sprintf("Missing required directory: %s", notes_dir), call. = FALSE)
}

invisible(lapply(file.path(notes_dir, required_files), require_populated_file))

desc <- as.list(read.dcf(path_in_repo("DESCRIPTION"))[1, ])
baseline_version <- desc[["Version"]]
if (!identical(baseline_version, "0.2.0")) {
  stop(sprintf("Expected baseline version 0.2.0 but found %s.", baseline_version), call. = FALSE)
}

env_lines <- read_text(file.path(notes_dir, "nonbroken_environment_report.md"))
check_lines <- read_text(file.path(notes_dir, "devtools_check_results.txt"))
check_cran_lines <- read_text(file.path(notes_dir, "devtools_check_cran_results.txt"))
ci_lines <- read_text(file.path(notes_dir, "live_ci_status_report.md"))
summary_lines <- read_text(file.path(notes_dir, "final_cran_evidence_summary.md"))

environment_classification <- extract_backtick_value(env_lines, "Environment classification")
check_status <- extract_backtick_value(check_lines, "Final result classification")
check_cran_status <- extract_backtick_value(check_cran_lines, "Final result classification")
ci_green_count <- extract_backtick_value(ci_lines, "CI nodes verified green count")
final_recommendation <- extract_backtick_value(summary_lines, "Final recommendation")

session_block_present <- any(grepl("^## sessionInfo\\(\\)$", env_lines))
if (!session_block_present) {
  stop("Environment evidence does not include sessionInfo().", call. = FALSE)
}

cat("Final CRAN evidence summary\n")
cat(sprintf("- baseline version: %s\n", baseline_version))
cat(sprintf("- environment classification: %s\n", environment_classification))
cat(sprintf("- devtools::check status: %s\n", check_status))
cat(sprintf("- devtools::check(cran = TRUE) status: %s\n", check_cran_status))
cat(sprintf("- CI nodes verified green count: %s\n", ci_green_count))
cat(sprintf("- final recommendation: %s\n", final_recommendation))
