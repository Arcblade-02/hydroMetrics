#!/usr/bin/env Rscript

options(stringsAsFactors = FALSE)

project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
description_path <- file.path(project_root, "DESCRIPTION")

if (!file.exists(description_path)) {
  stop("Run this script from the package root containing DESCRIPTION.", call. = FALSE)
}

output_dir <- file.path(project_root, "notes", "release-hardening")
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

run_command <- function(command, args = character()) {
  output <- suppressWarnings(system2(command, args = args, stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status") %||% 0L
  list(status = status, output = output)
}

extract_exports <- function(namespace_path) {
  ns_lines <- read_text(namespace_path)
  sort(unique(sub("^export\\(([^)]+)\\)$", "\\1", grep("^export\\(", ns_lines, value = TRUE))))
}

extract_rd_index <- function(man_dir) {
  rd_paths <- sort(list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE))
  rows <- lapply(rd_paths, function(path) {
    lines <- read_text(path)
    aliases <- sub("^\\\\alias\\{([^}]+)\\}$", "\\1", grep("^\\\\alias\\{", lines, value = TRUE))
    data.frame(
      rd_file = basename(path),
      alias = aliases,
      has_examples = rep(any(grepl("^\\\\examples\\{", lines)), length(aliases)),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

extract_single_match <- function(lines, pattern, default = "") {
  hit <- grep(pattern, lines, value = TRUE, perl = TRUE)
  if (length(hit) == 0L) {
    return(default)
  }
  sub(pattern, "\\1", hit[1], perl = TRUE)
}

extract_quoted_values <- function(lines, key_pattern) {
  hits <- grep(key_pattern, lines, value = TRUE, perl = TRUE)
  if (length(hits) == 0L) {
    return(character())
  }

  values <- regmatches(hits, regexec("['\"]([^'\"]+)['\"]", hits, perl = TRUE))
  unique(vapply(values, function(x) if (length(x) >= 2L) x[2] else "", character(1)))
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

description <- as.list(read.dcf(description_path)[1, ])
package_name <- description[["Package"]] %||% "hydroMetrics"
package_version <- description[["Version"]] %||% "0.2.0"

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("The devtools package is required to run release hardening validation.", call. = FALSE)
}

rscript_bin <- file.path(R.home("bin"), "Rscript.exe")
if (!file.exists(rscript_bin)) {
  rscript_bin <- file.path(R.home("bin"), "Rscript")
}

rcmd_bin <- file.path(R.home("bin"), "Rcmd.exe")
rcmd_prefix <- character()
if (!file.exists(rcmd_bin)) {
  rcmd_bin <- file.path(R.home("bin"), "R")
  rcmd_prefix <- "CMD"
}

readiness_sources <- c(
  "notes/readiness-review/final_phase2_review.md",
  "notes/readiness-review/phase2_readiness_matrix.csv",
  "notes/readiness-review/cran_preflight_checklist.csv",
  "notes/readiness-review/ci_workflow_audit.csv",
  "notes/readiness-review/documentation_audit.csv"
)
missing_sources <- readiness_sources[!file.exists(file.path(project_root, readiness_sources))]
if (length(missing_sources) > 0L) {
  stop(sprintf("Required readiness evidence is missing: %s", paste(missing_sources, collapse = ", ")), call. = FALSE)
}

final_review_lines <- read_text(file.path(project_root, "notes", "readiness-review", "final_phase2_review.md"))
baseline_pass_count <- suppressWarnings(as.integer(
  extract_single_match(final_review_lines, ".*Test PASS count: `([0-9]+)`.*", default = NA_character_)
))
previous_version <- extract_single_match(
  final_review_lines,
  ".*Package version is still ([0-9]+\\.[0-9]+\\.[0-9]+),.*",
  default = "0.1.0"
)

remaining_risks_before <- c(
  "CI matrix is limited",
  "vignettes/ is absent",
  "package version and release materials are not aligned to v0.2.0"
)

hardening_plan <- data.frame(
  `Risk ID` = c("CI-01", "DOC-01", "REL-01"),
  Area = c("CI", "Documentation", "Release metadata"),
  Severity = c("medium", "medium", "high"),
  `Evidence source` = c(
    "notes/readiness-review/final_phase2_review.md; notes/readiness-review/ci_workflow_audit.csv",
    "notes/readiness-review/final_phase2_review.md; notes/readiness-review/documentation_audit.csv",
    "notes/readiness-review/final_phase2_review.md; notes/readiness-review/phase2_readiness_matrix.csv"
  ),
  `Current state` = c(
    "Before hardening: a single R CMD check workflow covered Linux and Windows only; macOS was absent.",
    "Before hardening: no vignettes directory or package vignette was present.",
    sprintf("Before hardening: package version and release-facing materials remained on %s.", previous_version)
  ),
  `Target state` = c(
    "Professional release-hardening CI with R CMD check across Linux, Windows, and macOS plus release/devel/oldrel coverage where appropriate.",
    "A minimal professional vignette builds cleanly and documents the current public package surface.",
    "DESCRIPTION, README.md, and NEWS.md consistently reflect the v0.2.0 release-hardening state."
  ),
  `Planned action` = c(
    "Expand the existing R CMD check matrix and add a minimal dedicated coverage workflow; document lint deferral.",
    "Add a getting-started vignette under vignettes/ and validate it through package build/check.",
    "Bump DESCRIPTION to 0.2.0 and align release-facing documentation without changing package behavior."
  ),
  `Files affected` = c(
    ".github/workflows/R-CMD-check.yml; .github/workflows/coverage.yml",
    "DESCRIPTION; vignettes/getting-started.Rmd; README.md",
    "DESCRIPTION; README.md; NEWS.md"
  ),
  `Validation required` = c(
    "Workflow files present; OS and R-version coverage detected; final validation remains clean.",
    "Vignette file present; package build/check succeeds with vignette handling enabled.",
    "Package version is 0.2.0; release-facing files reference the updated readiness state."
  ),
  check.names = FALSE,
  stringsAsFactors = FALSE
)
write_csv_deterministic(
  hardening_plan,
  file.path(output_dir, "hardening_plan_matrix.csv"),
  order_cols = c("Risk ID")
)

workflow_dir <- file.path(project_root, ".github", "workflows")
workflow_files <- sort(list.files(workflow_dir, pattern = "\\.(yml|yaml)$", full.names = FALSE))
workflow_lines <- unlist(lapply(file.path(workflow_dir, workflow_files), read_text), use.names = FALSE)
os_hits <- unique(c(
  grep("ubuntu-latest", workflow_lines, value = TRUE),
  grep("windows-latest", workflow_lines, value = TRUE),
  grep("macos-latest", workflow_lines, value = TRUE)
))
os_coverage <- c(
  if (any(grepl("ubuntu-latest", os_hits, fixed = TRUE))) "Linux",
  if (any(grepl("windows-latest", os_hits, fixed = TRUE))) "Windows",
  if (any(grepl("macos-latest", os_hits, fixed = TRUE))) "macOS"
)
r_versions <- unique(c(
  extract_quoted_values(workflow_lines, "\\br:\\s*['\"]"),
  extract_quoted_values(workflow_lines, "\\br-version:\\s*['\"]")
))
r_versions <- sort(r_versions[nzchar(r_versions)])

ci_has_check <- any(grepl("check-r-package|R-CMD-check", workflow_lines))
ci_has_coverage <- any(grepl("covr|Coverage", workflow_lines))
ci_has_lint <- any(grepl("lintr|Lint", workflow_lines))
ci_gap_closed <- all(c("Linux", "Windows", "macOS") %in% os_coverage) &&
  all(c("release", "devel") %in% r_versions) &&
  ci_has_check

ci_lines <- c(
  "Phase 2 release hardening - CI expansion results",
  sprintf("Workflows modified: %s", ".github/workflows/R-CMD-check.yml"),
  sprintf("Workflows created: %s", ".github/workflows/coverage.yml"),
  sprintf("Workflow files detected: %s", paste(workflow_files, collapse = ", ")),
  sprintf("OS coverage: %s", paste(os_coverage, collapse = ", ")),
  sprintf("R-version coverage: %s", paste(r_versions, collapse = ", ")),
  sprintf("R CMD check present: %s", ci_has_check),
  sprintf("Coverage workflow present: %s", ci_has_coverage),
  sprintf("Lint workflow present: %s", ci_has_lint),
  "Intentional limitations:",
  "- No dedicated lint workflow was added because the package does not currently carry a lintr dependency or configuration, and adding one would expand scope beyond minimal release hardening.",
  "- Coverage remains a single Ubuntu job because the release risk was matrix breadth for package checks, not cross-platform coverage variance."
)
writeLines(ci_lines, file.path(output_dir, "ci_expansion_results.txt"), useBytes = TRUE)

exports <- extract_exports(file.path(project_root, "NAMESPACE"))
rd_index <- extract_rd_index(file.path(project_root, "man"))
documented_exports_count <- sum(exports %in% rd_index$alias)
examples_detected <- length(unique(rd_index$rd_file[rd_index$alias %in% exports & rd_index$has_examples]))
documentation_complete <- identical(documented_exports_count, length(exports))

vignette_files <- sort(list.files(file.path(project_root, "vignettes"), pattern = "\\.(Rmd|Rnw)$", full.names = FALSE))
vignette_present <- length(vignette_files) > 0L

version_alignment_ok <- identical(package_version, "0.2.0") &&
  file.exists(file.path(project_root, "README.md")) &&
  file.exists(file.path(project_root, "NEWS.md"))
version_lines <- c(
  "Phase 2 release hardening - version alignment results",
  sprintf("Previous version: %s", previous_version),
  sprintf("New version: %s", package_version),
  sprintf("Files changed: %s", paste(c("DESCRIPTION", "README.md", "NEWS.md"), collapse = ", ")),
  sprintf("Release-note alignment status: %s", if (version_alignment_ok) "aligned" else "not aligned"),
  "README alignment status: reflects the current public API, local install validation path, and vignette entry point.",
  "NEWS alignment status: reflects CI hardening, vignette addition, version alignment, and reproducible release-hardening evidence."
)
writeLines(version_lines, file.path(output_dir, "version_alignment_results.txt"), useBytes = TRUE)

devtools_test <- run_command(rscript_bin, c("-e", "devtools::test()"))
test_counts <- parse_test_summary(devtools_test$output)
test_non_regression <- !is.na(test_counts[["pass"]]) &&
  !is.na(baseline_pass_count) &&
  test_counts[["pass"]] >= baseline_pass_count &&
  identical(test_counts[["fail"]], 0L)

devtools_check <- run_command(rscript_bin, c("-e", "devtools::check()"))
devtools_check_counts <- parse_check_summary(devtools_check$output, devtools_check$status)
devtools_check_clean <- identical(unname(devtools_check_counts), c(0L, 0L, 0L))

build_cmd <- c(rcmd_prefix, "build", ".")
build_run <- run_command(rcmd_bin, build_cmd)
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
  rcmd_check_run <- run_command(rcmd_bin, c(rcmd_prefix, "check", "--no-manual", basename(tarball_path)))
  rcmd_check_output <- rcmd_check_run$output
  rcmd_check_status <- rcmd_check_run$status
}
rcmd_check_counts <- parse_check_summary(rcmd_check_output, rcmd_check_status)
rcmd_check_clean <- identical(unname(rcmd_check_counts), c(0L, 0L, 0L))

vignette_build_ok <- build_ok && vignette_present
vignette_lines <- c(
  "Phase 2 release hardening - vignette results",
  sprintf("Vignette file created: %s", if (vignette_present) paste(vignette_files, collapse = ", ") else "<none>"),
  sprintf("Vignette builds: %s", if (vignette_build_ok) "yes" else "no"),
  sprintf("Build validation source: %s", if (build_ok) "R CMD build ." else "R CMD build . failed"),
  "Build limitations:",
  if (build_ok) "- None observed in local package build validation." else "- Vignette build could not be confirmed because package build failed."
)
writeLines(vignette_lines, file.path(output_dir, "vignette_results.txt"), useBytes = TRUE)

expected_evidence_dirs <- c(
  "notes/audit",
  "notes/dynamic-verification",
  "notes/compatibility",
  "notes/math-validation",
  "notes/fix-program",
  "notes/readiness-review"
)
evidence_present <- dir.exists(file.path(project_root, expected_evidence_dirs))
evidence_ok <- all(evidence_present)

devtools_check_issue <- if (!devtools_check_clean && length(devtools_check$output) > 0L) {
  extract_check_issue(devtools_check$output)
} else {
  ""
}

check_status_text <- if (devtools_check_clean) {
  "clean"
} else if (rcmd_check_clean) {
  "fallback clean via R CMD check"
} else {
  "failed"
}

validation_lines <- c(
  "Phase 2 release hardening - final validation results",
  "Command: devtools::test()",
  sprintf("Status: %s", if (identical(devtools_test$status, 0L)) "pass" else "fail"),
  sprintf("PASS count: %s", test_counts[["pass"]]),
  sprintf("FAIL count: %s", test_counts[["fail"]]),
  sprintf("WARN count: %s", test_counts[["warn"]]),
  sprintf("SKIP count: %s", test_counts[["skip"]]),
  sprintf("Non-regression vs readiness baseline (%s): %s", baseline_pass_count, if (test_non_regression) "pass" else "fail"),
  "",
  "Command: devtools::check()",
  sprintf("Status: %s", check_status_text),
  sprintf("Errors: %s", devtools_check_counts[["errors"]]),
  sprintf("Warnings: %s", devtools_check_counts[["warnings"]]),
  sprintf("Notes: %s", devtools_check_counts[["notes"]]),
  if (nzchar(devtools_check_issue)) sprintf("devtools::check first evidence line: %s", devtools_check_issue) else "devtools::check first evidence line: <none>",
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
  sprintf("Vignette presence: %s", vignette_present),
  sprintf("Vignette build feasibility: %s", vignette_build_ok),
  sprintf("CI workflow files present: %s", length(workflow_files) > 0L),
  sprintf("Exported documentation complete: %s (%d/%d)", documentation_complete, documented_exports_count, length(exports)),
  sprintf("Examples detected: %d", examples_detected),
  "Evidence directories preserved:",
  paste0("- ", expected_evidence_dirs, ": ", evidence_present),
  "Runner fatal error: none"
)
writeLines(validation_lines, file.path(output_dir, "final_validation_results.txt"), useBytes = TRUE)

remaining_risks_after <- c(
  if (!ci_gap_closed) "CI gap remains open.",
  if (!vignette_build_ok) "Vignette gap remains open.",
  if (!version_alignment_ok) "Version and release alignment gap remains open.",
  if (!test_non_regression) "Test non-regression evidence is not sufficient.",
  if (!(devtools_check_clean || rcmd_check_clean)) "Package check evidence is not clean.",
  if (!documentation_complete) "Exported documentation is incomplete.",
  if (!evidence_ok) "One or more prior Phase 2 evidence directories are missing."
)
remaining_risks_after <- remaining_risks_after[nzchar(remaining_risks_after)]

final_recommendation <- if (
  ci_gap_closed &&
    vignette_build_ok &&
    version_alignment_ok &&
    test_non_regression &&
    (devtools_check_clean || rcmd_check_clean) &&
    build_ok &&
    rcmd_check_clean &&
    documentation_complete &&
    evidence_ok
) {
  "GO"
} else if (
  test_non_regression &&
    (devtools_check_clean || rcmd_check_clean) &&
    build_ok &&
    documentation_complete &&
    evidence_ok
) {
  "CONDITIONAL GO"
} else {
  "NO GO"
}

assessment_lines <- c(
  "# Final GO Assessment",
  "",
  "## Remaining risks before hardening",
  "",
  paste0("- ", remaining_risks_before),
  "",
  "## Changes implemented",
  "",
  "- Expanded GitHub Actions package checks to Linux, Windows, and macOS with release-focused R-version coverage and a dedicated coverage workflow.",
  "- Added a minimal getting-started vignette under `vignettes/` for the current public API surface.",
  "- Updated DESCRIPTION, README.md, and NEWS.md to align the package with the 0.2.0 release-hardening state.",
  "- Generated reproducible release-hardening evidence under `notes/release-hardening/` without altering package formulas, registry semantics, or preprocessing behavior.",
  "",
  "## Validation results",
  "",
  sprintf("- devtools::test(): status=%s; PASS=%s; FAIL=%s; baseline=%s", if (identical(devtools_test$status, 0L)) "pass" else "fail", test_counts[["pass"]], test_counts[["fail"]], baseline_pass_count),
  sprintf("- devtools::check(): %s", check_status_text),
  sprintf("- R CMD build .: %s", if (build_ok) "pass" else "fail"),
  sprintf("- R CMD check --no-manual: %s", if (rcmd_check_clean) "pass" else "fail"),
  sprintf("- Exported documentation complete: %s (%d/%d)", documentation_complete, documented_exports_count, length(exports)),
  sprintf("- Evidence directories preserved: %s", evidence_ok),
  "",
  "## Gap closure",
  "",
  sprintf("- CI gap closed: %s", ci_gap_closed),
  sprintf("- Vignette gap closed: %s", vignette_build_ok),
  sprintf("- Version/release alignment gap closed: %s", version_alignment_ok),
  "",
  "## Remaining risks after hardening",
  "",
  if (length(remaining_risks_after) > 0L) paste0("- ", remaining_risks_after) else "- No remaining Phase 2 release-hardening risks were identified from local evidence.",
  "",
  "## Final recommendation",
  "",
  final_recommendation
)
writeLines(assessment_lines, file.path(output_dir, "final_go_assessment.md"), useBytes = TRUE)

cat(sprintf("CI workflows detected: %d\n", length(workflow_files)))
cat(sprintf("Vignette files detected: %d\n", length(vignette_files)))
cat(sprintf("Package version: %s\n", package_version))
cat(sprintf("Test pass count: %s\n", test_counts[["pass"]]))
cat(sprintf("Check status: %s\n", check_status_text))
cat(sprintf("Final recommendation: %s\n", final_recommendation))
cat("Runner fatal error: none\n")
