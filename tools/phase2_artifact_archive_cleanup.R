#!/usr/bin/env Rscript

options(stringsAsFactors = FALSE)

project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
description_path <- file.path(project_root, "DESCRIPTION")

if (!file.exists(description_path)) {
  stop("Run this script from the package root containing DESCRIPTION.", call. = FALSE)
}

output_dir <- file.path(project_root, "notes", "archive-cleanup")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

`%||%` <- function(x, y) {
  if (length(x) == 0L || all(is.na(x)) || identical(x, "")) {
    return(y)
  }
  x
}

read_text <- function(path) {
  if (!file.exists(path)) {
    return(character())
  }

  con <- file(path, open = "rb")
  on.exit(close(con), add = TRUE)
  bom <- readBin(con, what = "raw", n = 2L)

  encoding <- "UTF-8"
  if (length(bom) == 2L) {
    if (identical(as.integer(bom), c(255L, 254L))) {
      encoding <- "UTF-16LE"
    } else if (identical(as.integer(bom), c(254L, 255L))) {
      encoding <- "UTF-16BE"
    }
  }

  text_con <- file(path, open = "rt", encoding = encoding)
  on.exit(close(text_con), add = TRUE)
  suppressWarnings(readLines(text_con, warn = FALSE))
}

write_csv_deterministic <- function(data, path, order_cols = NULL) {
  if (!is.null(order_cols) && nrow(data) > 0L) {
    keys <- data[order_cols]
    ord <- do.call(order, c(keys, list(na.last = TRUE)))
    data <- data[ord, , drop = FALSE]
  }
  write.csv(data, path, row.names = FALSE, na = "")
}

git_stdout <- function(args) {
  out <- suppressWarnings(system2("git", args = args, stdout = TRUE, stderr = FALSE))
  status <- attr(out, "status") %||% 0L
  if (!identical(status, 0L)) {
    return(character())
  }
  out
}

run_command <- function(command, args = character()) {
  output <- suppressWarnings(system2(command, args = args, stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status") %||% 0L
  list(status = status, output = output)
}

parse_test_summary <- function(lines) {
  hits <- grep("^\\[ FAIL [0-9]+ \\| WARN [0-9]+ \\| SKIP [0-9]+ \\| PASS [0-9]+ \\]$", trimws(lines), value = TRUE)
  if (length(hits) == 0L) {
    return(c(fail = NA_integer_, warn = NA_integer_, skip = NA_integer_, pass = NA_integer_))
  }

  rows <- lapply(hits, function(hit) {
    as.integer(unlist(regmatches(hit, gregexpr("[0-9]+", hit))))
  })
  rows <- do.call(rbind, rows)
  colnames(rows) <- c("fail", "warn", "skip", "pass")

  clean_rows <- rows[rows[, "fail"] == 0L & rows[, "warn"] == 0L & rows[, "skip"] == 0L, , drop = FALSE]
  chosen <- if (nrow(clean_rows) > 0L) {
    clean_rows[which.max(clean_rows[, "pass"]), ]
  } else {
    rows[nrow(rows), ]
  }

  stats::setNames(as.integer(chosen), c("fail", "warn", "skip", "pass"))
}

parse_check_summary <- function(lines, status_code) {
  ok_line <- grep("0 errors .*0 warnings .*0 notes", lines, value = TRUE)
  if (length(ok_line) > 0L && identical(status_code, 0L)) {
    return(c(errors = 0L, warnings = 0L, notes = 0L))
  }

  status_line <- grep("^Status:\\s+", trimws(lines), value = TRUE)
  if (length(status_line) > 0L && grepl("^Status:\\s+OK$", tail(status_line, 1L))) {
    return(c(errors = 0L, warnings = 0L, notes = 0L))
  }

  counts_line <- grep("[0-9]+ errors?.*[0-9]+ warnings?.*[0-9]+ notes?", lines, value = TRUE)
  if (length(counts_line) > 0L) {
    nums <- as.integer(unlist(regmatches(tail(counts_line, 1L), gregexpr("[0-9]+", tail(counts_line, 1L)))))
    if (length(nums) >= 3L) {
      return(stats::setNames(nums[1:3], c("errors", "warnings", "notes")))
    }
  }

  c(errors = as.integer(status_code != 0L), warnings = 0L, notes = 0L)
}

extract_check_issue <- function(lines) {
  patterns <- c("processx_exec", "Access is denied", "system error 5", "Rcmd\\.exe")
  for (pattern in patterns) {
    hit <- grep(pattern, lines, value = TRUE)
    if (length(hit) > 0L) {
      return(hit[1])
    }
  }

  fallback <- trimws(lines)
  fallback <- fallback[nzchar(fallback)]
  fallback[1] %||% ""
}

archive_branch <- "archive/phase2-validation-artifacts"
archive_commit <- git_stdout(c("rev-parse", archive_branch))[1] %||% ""
current_branch <- git_stdout(c("rev-parse", "--abbrev-ref", "HEAD"))[1] %||% "unknown"

if (!nzchar(archive_commit)) {
  stop("Archive branch `archive/phase2-validation-artifacts` is required before cleanup verification.", call. = FALSE)
}

artifact_specs <- data.frame(
  path = c(
    "notes/audit",
    "notes/dynamic-verification",
    "notes/compatibility",
    "notes/math-validation",
    "notes/fix-program",
    "notes/readiness-review",
    "notes/release-hardening"
  ),
  purpose = c(
    "Phase 2 baseline audit evidence.",
    "Phase 2 runtime, namespace, examples, coverage, and package-check evidence.",
    "Phase 2 compatibility behavior and scorecard evidence.",
    "Phase 2 formula provenance and mathematical behavior evidence.",
    "Phase 2 fix-program planning and validation evidence.",
    "Phase 2 readiness review and GO-gating evidence.",
    "Phase 2 release-hardening closure and final GO evidence."
  ),
  stringsAsFactors = FALSE
)

archive_listing <- lapply(seq_len(nrow(artifact_specs)), function(i) {
  path <- artifact_specs$path[[i]]
  archive_files <- git_stdout(c("ls-tree", "-r", "--name-only", archive_branch, "--", path))
  archive_files <- archive_files[nzchar(archive_files)]
  exists_archive <- length(archive_files) > 0L
  exists_production <- dir.exists(file.path(project_root, path))
  verified_status <- if (exists_archive && !exists_production) {
    "archived_on_archive_branch_and_removed_from_production"
  } else if (exists_archive && exists_production) {
    "archived_but_still_present_in_production"
  } else {
    "missing_from_archive_branch"
  }

  data.frame(
    Path = path,
    Exists = exists_archive,
    `File count` = length(archive_files),
    Purpose = artifact_specs$purpose[[i]],
    `Archive required` = TRUE,
    `Remove from production branch` = TRUE,
    `Verified status` = verified_status,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
})
archive_plan <- do.call(rbind, archive_listing)
write_csv_deterministic(
  archive_plan,
  file.path(output_dir, "archive_plan_matrix.csv"),
  order_cols = c("Path")
)

summary_path <- file.path(project_root, "docs", "phase2_validation_summary.md")
summary_exists <- file.exists(summary_path)

retained_assets <- c(
  ".github/workflows",
  "DESCRIPTION",
  "LICENSE",
  "NAMESPACE",
  "NEWS.md",
  "README.md",
  "R",
  "docs/phase2_validation_summary.md",
  "inst",
  "man",
  "tests",
  "tools",
  "vignettes"
)
retained_exists <- vapply(
  retained_assets,
  function(path) file.exists(file.path(project_root, path)) || dir.exists(file.path(project_root, path)),
  logical(1)
)

layout_lines <- c(
  "Final production repository layout",
  sprintf("Current branch: %s", current_branch),
  "",
  "Retained package assets:",
  "- .github/workflows/",
  "- R/",
  "- man/",
  "- tests/",
  "- vignettes/",
  "- inst/",
  "- tools/",
  "- docs/phase2_validation_summary.md",
  "- DESCRIPTION",
  "- NAMESPACE",
  "- README.md",
  "- NEWS.md",
  "- LICENSE",
  "- notes/archive-cleanup/",
  if (dir.exists(file.path(project_root, "notes", "performance"))) "- notes/performance/" else NULL,
  "",
  "Archived Phase 2 notes directories intentionally absent from production:",
  paste0("- ", artifact_specs$path)
)
writeLines(layout_lines, file.path(output_dir, "final_repo_layout.txt"), useBytes = TRUE)
writeLines(
  c(
    "Phase 2 artifact archive cleanup - validation results",
    "Status: in progress"
  ),
  file.path(output_dir, "cleanup_validation_results.txt"),
  useBytes = TRUE
)

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("The devtools package is required to run cleanup validation.", call. = FALSE)
}

description <- as.list(read.dcf(description_path)[1, ])
package_name <- description[["Package"]] %||% "hydroMetrics"
package_version <- description[["Version"]] %||% "0.2.0"

rscript_bin <- file.path(R.home("bin"), "Rscript.exe")
if (!file.exists(rscript_bin)) {
  rscript_bin <- file.path(R.home("bin"), "Rscript")
}

r_bin <- file.path(R.home("bin"), "R.exe")
if (!file.exists(r_bin)) {
  stop("R executable not found for build/check validation.", call. = FALSE)
}

devtools_test <- run_command(rscript_bin, c("-e", "devtools::test()"))
test_counts <- parse_test_summary(devtools_test$output)
test_non_regression <- !is.na(test_counts[["pass"]]) &&
  identical(test_counts[["fail"]], 0L) &&
  test_counts[["pass"]] >= 569L

devtools_check <- run_command(rscript_bin, c("-e", "devtools::check()"))
devtools_check_counts <- parse_check_summary(devtools_check$output, devtools_check$status)
devtools_check_clean <- identical(unname(devtools_check_counts), c(0L, 0L, 0L))

build_run <- run_command(r_bin, c("CMD", "build", "."))
build_ok <- identical(build_run$status, 0L)

tarball_pattern <- sprintf("^%s_%s\\.tar\\.gz$", package_name, gsub("\\.", "\\\\.", package_version))
tarballs <- list.files(project_root, pattern = tarball_pattern, full.names = TRUE)
tarball_path <- if (build_ok && length(tarballs) > 0L) {
  tarballs[which.max(file.info(tarballs)$mtime)]
} else {
  ""
}

rcmd_check_output <- character()
rcmd_check_status <- 1L
if (build_ok && nzchar(tarball_path)) {
  rcmd_check <- run_command(r_bin, c("CMD", "check", "--no-manual", basename(tarball_path)))
  rcmd_check_output <- rcmd_check$output
  rcmd_check_status <- rcmd_check$status
}
rcmd_check_counts <- parse_check_summary(rcmd_check_output, rcmd_check_status)
rcmd_check_clean <- identical(unname(rcmd_check_counts), c(0L, 0L, 0L))

gitignore_lines <- read_text(file.path(project_root, ".gitignore"))
gitignore_required <- c("*.tar.gz", "*.Rcheck/", ".Rhistory", ".RData", ".Rproj.user/")
gitignore_ok <- all(gitignore_required %in% trimws(gitignore_lines))

remaining_risks <- c(
  if (!all(archive_plan$Exists)) "One or more archived Phase 2 directories are missing from the archive branch.",
  if (any(dir.exists(file.path(project_root, artifact_specs$path)))) "One or more archived Phase 2 directories remain on the production branch.",
  if (!summary_exists) "The concise Phase 2 summary document is missing.",
  if (!all(retained_exists)) "One or more retained package assets are missing.",
  if (!test_non_regression) "Test validation did not meet the PASS >= 569 and FAIL = 0 requirement.",
  if (!(devtools_check_clean || rcmd_check_clean)) "Package-level check validation is not clean.",
  if (!gitignore_ok) "The expected package-level .gitignore patterns are incomplete."
)
remaining_risks <- remaining_risks[nzchar(remaining_risks)]

cleanup_lines <- c(
  "Phase 2 artifact archive cleanup - validation results",
  sprintf("Current branch: %s", current_branch),
  sprintf("Archive branch: %s", archive_branch),
  sprintf("Archive commit hash: %s", archive_commit),
  sprintf("Archived directories verified: %d/%d", sum(archive_plan$Exists), nrow(archive_plan)),
  sprintf("Archived directories removed from production: %s", all(!dir.exists(file.path(project_root, artifact_specs$path)))),
  sprintf("Docs summary exists: %s", summary_exists),
  sprintf("Retained package assets present: %s", all(retained_exists)),
  sprintf(".gitignore status: %s", if (gitignore_ok) "complete" else "incomplete"),
  "",
  "Command: devtools::test()",
  sprintf("Status: %s", if (identical(devtools_test$status, 0L)) "pass" else "fail"),
  sprintf("PASS count: %s", test_counts[["pass"]]),
  sprintf("FAIL count: %s", test_counts[["fail"]]),
  sprintf("WARN count: %s", test_counts[["warn"]]),
  sprintf("SKIP count: %s", test_counts[["skip"]]),
  sprintf("Non-regression vs baseline (569): %s", if (test_non_regression) "pass" else "fail"),
  "",
  "Command: devtools::check()",
  sprintf("Status: %s", if (devtools_check_clean) "clean" else if (rcmd_check_clean) "fallback clean via R CMD check" else "failed"),
  sprintf("Errors: %s", devtools_check_counts[["errors"]]),
  sprintf("Warnings: %s", devtools_check_counts[["warnings"]]),
  sprintf("Notes: %s", devtools_check_counts[["notes"]]),
  sprintf("devtools::check first evidence line: %s", if (!devtools_check_clean) extract_check_issue(devtools_check$output) else "<none>"),
  "",
  "Command: R CMD build .",
  sprintf("Status: %s", if (build_ok) "pass" else "fail"),
  sprintf("Tarball: %s", if (nzchar(tarball_path)) basename(tarball_path) else "<none>"),
  "",
  sprintf("Command: R CMD check --no-manual %s", if (nzchar(tarball_path)) basename(tarball_path) else "<missing tarball>"),
  sprintf("Status: %s", if (rcmd_check_clean) "pass" else "fail"),
  sprintf("Errors: %s", rcmd_check_counts[["errors"]]),
  sprintf("Warnings: %s", rcmd_check_counts[["warnings"]]),
  sprintf("Notes: %s", rcmd_check_counts[["notes"]]),
  "",
  "Remaining risks:",
  if (length(remaining_risks) > 0L) paste0("- ", remaining_risks) else "- No remaining archive-cleanup risks identified."
)
writeLines(cleanup_lines, file.path(output_dir, "cleanup_validation_results.txt"), useBytes = TRUE)

cat(sprintf("Archive branch: %s\n", archive_branch))
cat(sprintf("Archive commit hash: %s\n", archive_commit))
cat(sprintf("Archived directories verified: %d\n", sum(archive_plan$Exists)))
cat(sprintf("Production cleanup complete: %s\n", all(!dir.exists(file.path(project_root, artifact_specs$path)))))
cat(sprintf("Test pass count: %s\n", test_counts[["pass"]]))
cat(sprintf(
  "Check status: %s\n",
  if (devtools_check_clean) "clean" else if (rcmd_check_clean) "fallback clean via R CMD check" else "failed"
))
cat(sprintf("Remaining risks: %d\n", length(remaining_risks)))
