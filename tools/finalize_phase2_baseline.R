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

notes_dir <- repo_path("notes")
required <- c(
  "PHASE2_HISTORY.md",
  file.path("finalize-phase2-baseline", "merge_and_validation_report.md")
)

invisible(lapply(file.path(notes_dir, required), require_file))

desc <- as.list(read.dcf(repo_path("DESCRIPTION"))[1, ])
version <- desc[["Version"]]
if (!identical(version, "0.2.0")) {
  stop(sprintf("Expected Version 0.2.0, found %s.", version), call. = FALSE)
}

history_path <- file.path(notes_dir, "PHASE2_HISTORY.md")
merge_report_path <- file.path(notes_dir, "finalize-phase2-baseline", "merge_and_validation_report.md")
history_lines <- read_lines(history_path)
merge_lines <- read_lines(merge_report_path)

history_present <- any(grepl("^# Phase 2 History$", history_lines))
merge_report_present <- any(grepl("^# Merge And Validation Report$", merge_lines))

cat("Phase 2 baseline finalization summary\n")
cat(sprintf("- final version: %s\n", version))
cat(sprintf("- consolidated phase 2 history present: %s\n", history_present))
cat(sprintf("- detailed merge/validation report present: %s\n", merge_report_present))
cat(sprintf("- retained exit memo present: %s\n", file.exists(repo_path("docs", "PHASE2_EXIT_MEMO.md"))))
