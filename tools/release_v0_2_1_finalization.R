notes_dir <- file.path("notes", "release-v0.2.1")
required_files <- c(
  file.path(notes_dir, "release_merge_report.md"),
  file.path(notes_dir, "version_bump_report.md"),
  file.path(notes_dir, "validation_results.txt"),
  file.path(notes_dir, "tag_and_push_report.md"),
  file.path(notes_dir, "final_release_summary.md")
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0L) {
  stop(
    sprintf(
      "Missing required v0.2.1 finalization artifact(s): %s",
      paste(missing_files, collapse = ", ")
    ),
    call. = FALSE
  )
}

description_lines <- readLines("DESCRIPTION", warn = FALSE)
if (!any(grepl("^Version:\\s*0\\.2\\.1\\s*$", description_lines))) {
  stop("DESCRIPTION does not contain Version: 0.2.1", call. = FALSE)
}

news_lines <- readLines("NEWS.md", warn = FALSE)
if (!any(grepl("^##\\s+0\\.2\\.1\\s*$", news_lines))) {
  stop("NEWS.md does not contain a 0.2.1 release entry", call. = FALSE)
}

namespace_lines <- readLines("NAMESPACE", warn = FALSE)
namespace_exports <- sub("^export\\((.+)\\)$", "\\1", grep("^export\\(", namespace_lines, value = TRUE))
required_exports <- c("NSE", "KGE", "RMSE", "R2", "NRMSE", "PBIAS", "gof", "ggof", "preproc", "valindex")
missing_exports <- setdiff(required_exports, namespace_exports)
if (length(missing_exports) > 0L) {
  stop(
    sprintf(
      "Finalized release is missing wrapper export(s): %s",
      paste(missing_exports, collapse = ", ")
    ),
    call. = FALSE
  )
}

validation_lines <- readLines(file.path(notes_dir, "validation_results.txt"), warn = FALSE)
tag_lines <- readLines(file.path(notes_dir, "tag_and_push_report.md"), warn = FALSE)
summary_lines <- readLines(file.path(notes_dir, "final_release_summary.md"), warn = FALSE)

extract_line <- function(prefix, lines) {
  hit <- grep(paste0("^", prefix), lines, value = TRUE)
  if (length(hit) == 0L) {
    return("not recorded")
  }
  hit[[1]]
}

cat("release v0.2.1 finalization summary\n")
cat("final version: 0.2.1\n")
cat(sprintf(
  "wrapper/export closure retained: %s\n",
  if (length(missing_exports) == 0L) "yes" else "no"
))
cat(sprintf("test status: %s\n", extract_line("devtools::test\\(\\):", validation_lines)))
cat(sprintf("build/check status: %s\n", extract_line("R CMD build/check:", validation_lines)))
cat(sprintf("tag status: %s\n", extract_line("Tag creation result:", tag_lines)))
cat(sprintf("final readiness for Phase 3: %s\n", extract_line("Status:", summary_lines)))
