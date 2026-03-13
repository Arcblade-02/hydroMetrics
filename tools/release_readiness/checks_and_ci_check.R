run_checks_and_ci_check <- function(context) {
  check_results_path <- file.path(context$notes_dir, "check_results.txt")
  check_cran_path <- file.path(context$notes_dir, "check_cran_results.txt")
  ci_review_path <- file.path(context$notes_dir, "ci_consistency_review.md")

  build_run <- rr_run_command(rr_r_cmd(), c("build", "."), wd = context$root)
  tarball <- rr_extract_latest_tarball()
  check_run <- if (!is.na(tarball)) {
    rr_run_command(rr_r_cmd(), c("check", "--no-manual", basename(tarball)), wd = context$root)
  } else {
    list(status = 1L, combined = c("No tarball was produced by `R CMD build .`."), stdout = character(), stderr = character())
  }
  devtools_check_run <- rr_run_r_code(
    paste(
      "if (!requireNamespace('devtools', quietly = TRUE)) stop('devtools is not installed.', call. = FALSE)",
      "devtools::check()",
      sep = "\n"
    ),
    wd = context$root
  )
  devtools_check_cran_run <- rr_run_r_code(
    paste(
      "if (!requireNamespace('devtools', quietly = TRUE)) stop('devtools is not installed.', call. = FALSE)",
      "devtools::check(cran = TRUE)",
      sep = "\n"
    ),
    wd = context$root
  )

  rr_write_lines(
    check_results_path,
    c(
      sprintf("# Check results generated %s", rr_now()),
      "",
      "## `R CMD build .`",
      "",
      build_run$combined,
      "",
      "## `R CMD check --no-manual <built tarball>`",
      "",
      check_run$combined,
      "",
      "## `devtools::check()`",
      "",
      devtools_check_run$combined
    )
  )

  cran_classification <- rr_classify_check_failure(devtools_check_cran_run$combined, devtools_check_cran_run$status)
  rr_write_lines(
    check_cran_path,
    c(
      sprintf("# CRAN-style check results generated %s", rr_now()),
      "",
      sprintf("- Classification: `%s`", cran_classification),
      "",
      "## `devtools::check(cran = TRUE)`",
      "",
      devtools_check_cran_run$combined
    )
  )

  workflow_files <- Sys.glob(file.path(context$root, ".github", "workflows", "*.yml"))
  workflow_contents <- if (length(workflow_files) > 0L) lapply(workflow_files, rr_read_text_if_exists) else list()
  workflow_names <- basename(workflow_files)
  workflow_blob <- paste(unlist(workflow_contents), collapse = "\n")
  ci_remote <- rr_find_ci_status()

  rr_write_lines(
    ci_review_path,
    c(
      "# CI Consistency Review",
      "",
      sprintf("- Generated: %s", rr_now()),
      sprintf("- Workflow files discovered: `%s`", if (length(workflow_names) == 0L) "none" else paste(workflow_names, collapse = ", ")),
      sprintf("- Linux in matrix: `%s`", rr_bool(grepl("ubuntu", workflow_blob, ignore.case = TRUE))),
      sprintf("- Windows in matrix: `%s`", rr_bool(grepl("windows", workflow_blob, ignore.case = TRUE))),
      sprintf("- macOS in matrix: `%s`", rr_bool(grepl("macos|macOS", workflow_blob, ignore.case = TRUE))),
      sprintf("- Coverage workflow present: `%s`", rr_bool(any(grepl("coverage", workflow_names, ignore.case = TRUE)))),
      sprintf("- Vignettes intentionally skipped in CI: `%s`", rr_bool(grepl("--ignore-vignettes|--no-build-vignettes", workflow_blob, ignore.case = TRUE))),
      sprintf("- Current default-branch CI status: `%s`", ci_remote$status),
      "",
      "## Consistency findings",
      "",
      if (grepl("--ignore-vignettes|--no-build-vignettes", workflow_blob, ignore.case = TRUE)) {
        "- Repository CI intentionally skips vignette build/check paths, so local vignette evidence is broader than CI coverage."
      } else {
        "- Repository CI appears to exercise vignette paths."
      },
      if (!grepl("macos|macOS", workflow_blob, ignore.case = TRUE)) {
        "- No macOS runner was found in the checked-in workflow matrix."
      } else {
        "- macOS is represented in the checked-in workflow matrix."
      },
      if (!any(grepl("coverage", workflow_names, ignore.case = TRUE))) {
        "- No dedicated coverage workflow is present on this branch."
      } else {
        "- A dedicated coverage workflow is present."
      },
      sprintf("- Remote workflow status note: %s", ci_remote$details)
    )
  )

  local_checks_ok <- identical(build_run$status, 0L) &&
    identical(check_run$status, 0L) &&
    identical(devtools_check_run$status, 0L)
  ci_ok <- local_checks_ok &&
    grepl("ubuntu", workflow_blob, ignore.case = TRUE) &&
    grepl("windows", workflow_blob, ignore.case = TRUE) &&
    grepl("macos|macOS", workflow_blob, ignore.case = TRUE) &&
    any(grepl("coverage", workflow_names, ignore.case = TRUE))

  rr_result(
    stage = "checks and CI cross-check",
    status = rr_status_worst(c(
      if (local_checks_ok) "PASS" else "FAIL",
      if (identical(devtools_check_cran_run$status, 0L)) "PASS" else "WARN",
      if (ci_ok) "PASS" else "FAIL"
    )),
    summary = sprintf(
      "Build/check/devtools::check statuses: %s/%s/%s; devtools::check(cran=TRUE): %s (%s); CI remote status: %s.",
      if (identical(build_run$status, 0L)) "PASS" else "FAIL",
      if (identical(check_run$status, 0L)) "PASS" else "FAIL",
      if (identical(devtools_check_run$status, 0L)) "PASS" else "FAIL",
      if (identical(devtools_check_cran_run$status, 0L)) "PASS" else "FAIL",
      cran_classification,
      ci_remote$status
    ),
    fatal = FALSE,
    artifacts = c(check_results_path, check_cran_path, ci_review_path),
    details = list(
      build_status = build_run$status,
      rcmd_check_status = check_run$status,
      devtools_check_status = devtools_check_run$status,
      devtools_check_cran_status = devtools_check_cran_run$status,
      cran_classification = cran_classification,
      ci_remote_status = ci_remote$status
    )
  )
}
