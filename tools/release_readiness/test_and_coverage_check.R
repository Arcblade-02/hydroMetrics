run_test_and_coverage_check <- function(context) {
  tests_path <- file.path(context$notes_dir, "test_suite_results.txt")
  coverage_path <- file.path(context$notes_dir, "coverage_review.md")

  test_dir_run <- rr_run_r_code(
    paste(
      "if (!requireNamespace('testthat', quietly = TRUE)) stop('testthat is not installed.', call. = FALSE)",
      "testthat::test_dir('tests/testthat')",
      sep = "\n"
    ),
    wd = context$root
  )
  devtools_test_run <- rr_run_r_code(
    paste(
      "if (!requireNamespace('devtools', quietly = TRUE)) stop('devtools is not installed.', call. = FALSE)",
      "devtools::test()",
      sep = "\n"
    ),
    wd = context$root
  )

  rr_write_lines(
    tests_path,
    c(
      sprintf("# Test suite results generated %s", rr_now()),
      "",
      "## `testthat::test_dir(\"tests/testthat\")`",
      "",
      test_dir_run$combined,
      "",
      "## `devtools::test()`",
      "",
      devtools_test_run$combined
    )
  )

  coverage_run <- rr_run_r_code(
    paste(
      "if (!requireNamespace('covr', quietly = TRUE)) stop('covr is not installed.', call. = FALSE)",
      "cov <- covr::package_coverage()",
      "cat(sprintf('OVERALL==%0.2f\\n', covr::percent_coverage(cov)))",
      "cov_df <- tryCatch(as.data.frame(cov), error = function(e) data.frame())",
      "if (nrow(cov_df) > 0L && 'filename' %in% names(cov_df) && 'value' %in% names(cov_df)) {",
      "  cov_df$covered <- cov_df$value > 0",
      "  file_summary <- stats::aggregate(covered ~ filename, data = cov_df, FUN = mean)",
      "  for (i in seq_len(nrow(file_summary))) {",
      "    cat(sprintf('FILE==%s||%0.2f\\n', file_summary$filename[[i]], 100 * file_summary$covered[[i]]))",
      "  }",
      "}",
      sep = "\n"
    ),
    wd = context$root
  )

  coverage_output <- c(coverage_run$stdout, coverage_run$stderr)
  overall_line <- coverage_output[grepl("^OVERALL==", coverage_output)]
  overall_pct <- if (length(overall_line) > 0L) as.numeric(sub("^OVERALL==", "", overall_line[[1]])) else NA_real_
  file_lines <- sub("^FILE==", "", coverage_output[grepl("^FILE==", coverage_output)])
  public_matches <- file_lines[grepl("R[/\\\\](gof|ggof|preproc|valindex)\\.R", file_lines)]

  rr_write_lines(
    coverage_path,
    c(
      "# Coverage Review",
      "",
      sprintf("- Generated: %s", rr_now()),
      sprintf("- Overall coverage: `%s`", if (is.na(overall_pct)) "unavailable" else sprintf("%.2f%%", overall_pct)),
      sprintf("- Exported public surface under review: `%s`", paste(rr_required_api(), collapse = ", ")),
      sprintf("- Public preprocessing/export files observed in coverage output: `%s`", if (length(public_matches) == 0L) "none isolated" else paste(public_matches, collapse = "; ")),
      "",
      "## Interpretation",
      "",
      if (identical(test_dir_run$status, 0L) && identical(devtools_test_run$status, 0L)) {
        "- Both `testthat::test_dir()` and `devtools::test()` completed without a non-zero exit status."
      } else {
        "- One or both test commands failed; see the raw log for exact output."
      },
      "- Wrapper-specific coverage is constrained by the current exported surface and should be interpreted against the documented stable helper/compatibility mix on this snapshot.",
      "- Preprocessing coverage is reviewed through any `R/preproc.R` entries emitted by `covr`; absence of a file-level line item is recorded rather than inferred.",
      "- Edge-case branch coverage requires manual follow-up where `covr` does not expose branch-level detail in the current environment.",
      "",
      "## Raw coverage output",
      "",
      rr_md_code_block(coverage_run$combined)
    )
  )

  tests_ok <- identical(test_dir_run$status, 0L) && identical(devtools_test_run$status, 0L)
  coverage_ok <- identical(coverage_run$status, 0L) && !is.na(overall_pct)

  rr_result(
    stage = "tests and coverage",
    status = rr_status_worst(c(if (tests_ok) "PASS" else "FAIL", if (coverage_ok) "PASS" else "WARN")),
    summary = sprintf(
      "Test commands status: %s / %s; coverage overall: %s.",
      if (identical(test_dir_run$status, 0L)) "PASS" else "FAIL",
      if (identical(devtools_test_run$status, 0L)) "PASS" else "FAIL",
      if (is.na(overall_pct)) "unavailable" else sprintf("%.2f%%", overall_pct)
    ),
    fatal = FALSE,
    artifacts = c(tests_path, coverage_path),
    details = list(
      test_dir_status = test_dir_run$status,
      devtools_test_status = devtools_test_run$status,
      coverage_status = coverage_run$status,
      coverage_pct = overall_pct
    )
  )
}
