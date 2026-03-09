root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
notes_dir <- file.path(root, "notes", "merge-sync")
dir.create(notes_dir, recursive = TRUE, showWarnings = FALSE)

description_path <- file.path(root, "DESCRIPTION")
validation_path <- file.path(notes_dir, "validation_results.txt")
summary_path <- file.path(notes_dir, "final_merge_sync_summary.md")

read_lines <- function(path) {
  if (!file.exists(path)) return(character())
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

description_lines <- read_lines(description_path)
merge_markers_present <- any(grepl("<<<<<<<|=======|>>>>>>>", description_lines))
package_version <- if (file.exists(description_path)) {
  as.list(read.dcf(description_path)[1, ])[["Version"]]
} else {
  NA_character_
}

baseline_files <- c(
  "README.md",
  "NEWS.md",
  "vignettes/getting-started.Rmd",
  "notes/release-readiness",
  "tools/release_readiness/run_release_readiness_pipeline.R",
  ".github/workflows/R-CMD-check.yml",
  ".github/workflows/coverage.yml"
)
baseline_present <- file.exists(file.path(root, baseline_files)) | dir.exists(file.path(root, baseline_files))
baseline_count <- sum(baseline_present)

validation_lines <- read_lines(validation_path)
test_status <- if (any(grepl("\\[ FAIL 0 \\| WARN 0", validation_lines, fixed = FALSE))) "PASS" else "UNKNOWN"
build_status <- if (any(grepl("* building 'hydroMetrics_0.2.0.tar.gz'", validation_lines, fixed = TRUE))) "PASS" else "UNKNOWN"
check_status <- if (any(grepl("Status: OK", validation_lines, fixed = TRUE))) "PASS" else "UNKNOWN"
ready <- !merge_markers_present &&
  identical(package_version, "0.2.0") &&
  baseline_count == length(baseline_files) &&
  test_status == "PASS" &&
  build_status == "PASS" &&
  check_status == "PASS"

summary_lines <- c(
  "# Final Merge Sync Summary",
  "",
  sprintf("- Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("- Merge markers present: `%s`", if (merge_markers_present) "YES" else "NO"),
  sprintf("- Final package version: `%s`", if (is.na(package_version)) "missing" else package_version),
  sprintf("- Baseline files present count: `%s/%s`", baseline_count, length(baseline_files)),
  sprintf("- Test status: `%s`", test_status),
  sprintf("- Build status: `%s`", build_status),
  sprintf("- Check status: `%s`", check_status),
  sprintf("- Branch readiness for release-readiness rerun: `%s`", if (ready) "READY" else "NOT READY"),
  "",
  "## Baseline file inventory",
  ""
)

for (i in seq_along(baseline_files)) {
  summary_lines <- c(
    summary_lines,
    sprintf("- `%s`: `%s`", baseline_files[[i]], if (baseline_present[[i]]) "present" else "missing")
  )
}

writeLines(summary_lines, summary_path, useBytes = TRUE)

cat("merge markers:", if (merge_markers_present) "present" else "absent", "\n")
cat("final package version:", if (is.na(package_version)) "missing" else package_version, "\n")
cat("baseline files present:", sprintf("%s/%s", baseline_count, length(baseline_files)), "\n")
cat("test status:", test_status, "\n")
cat("build/check status:", paste(build_status, check_status, sep = "/"), "\n")
cat("branch readiness:", if (ready) "READY" else "NOT READY", "\n")
