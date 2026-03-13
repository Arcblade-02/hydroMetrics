root_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

repo_path <- function(...) {
  file.path(root_dir, ...)
}

read_lines <- function(path) {
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

require_file <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("Missing required artifact: %s", path), call. = FALSE)
  }
  info <- file.info(path)
  if (is.na(info$size) || info$size <= 0) {
    stop(sprintf("Artifact exists but is empty: %s", path), call. = FALSE)
  }
}

extract_backtick <- function(lines, field) {
  pattern <- sprintf("^- %s: `(.+)`$", gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", field))
  hit <- grep(pattern, lines, value = TRUE)
  if (length(hit) == 0L) {
    stop(sprintf("Missing field '%s'.", field), call. = FALSE)
  }
  sub(pattern, "\\1", hit[[1]])
}

notes_dir <- repo_path("notes", "finalize-phase2-baseline")
required <- c(
  "cleanup_report.md",
  "merge_and_validation_report.md",
  "tag_release_report.md",
  "final_baseline_summary.md"
)

if (!dir.exists(notes_dir)) {
  stop(sprintf("Missing required directory: %s", notes_dir), call. = FALSE)
}

invisible(lapply(file.path(notes_dir, required), require_file))

desc <- as.list(read.dcf(repo_path("DESCRIPTION"))[1, ])
version <- desc[["Version"]]
if (!identical(version, "0.2.0")) {
  stop(sprintf("Expected Version 0.2.0, found %s.", version), call. = FALSE)
}

memo_path <- repo_path("docs", "PHASE2_EXIT_MEMO.md")
if (!file.exists(memo_path)) {
  stop("Missing docs/PHASE2_EXIT_MEMO.md.", call. = FALSE)
}

cleanup_lines <- read_lines(file.path(notes_dir, "cleanup_report.md"))
merge_lines <- read_lines(file.path(notes_dir, "merge_and_validation_report.md"))
tag_lines <- read_lines(file.path(notes_dir, "tag_release_report.md"))
summary_lines <- read_lines(file.path(notes_dir, "final_baseline_summary.md"))

cleanup_status <- extract_backtick(cleanup_lines, "Cleanup status")
test_status <- extract_backtick(merge_lines, "devtools::test status")
build_status <- extract_backtick(merge_lines, "R CMD build status")
check_status <- extract_backtick(merge_lines, "R CMD check --no-manual status")
tag_status <- extract_backtick(summary_lines, "Tag status")
final_status <- extract_backtick(summary_lines, "Final Phase 2 baseline status")

cat("Phase 2 baseline finalization summary\n")
cat(sprintf("- cleanup status: %s\n", cleanup_status))
cat(sprintf("- final version: %s\n", version))
cat(sprintf("- test status: %s\n", test_status))
cat(sprintf("- build/check status: %s/%s\n", build_status, check_status))
cat(sprintf("- tag status: %s\n", tag_status))
cat(sprintf("- final readiness for Phase 3: %s\n", final_status))
