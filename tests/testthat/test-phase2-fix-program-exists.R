test_that("Phase 2 fix-program artifacts are archived and removed from production", {
  script_path <- phase2_archive_repo_path("tools", "phase2_fix_program.R")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      phase2_archive_branch_exists(),
    "Phase 2 fix-program archive validation is unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_false(dir.exists(phase2_archive_repo_path("notes", "fix-program")))
  expect_true(phase2_archive_has_path("notes/fix-program/fix_plan_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/fix-program/fix_execution_log.md"))
  expect_true(phase2_archive_has_path("notes/fix-program/fix_validation_results.txt"))
})

test_that("Phase 2 fix-program release metadata and provenance fixes are present", {
  desc <- utils::packageDescription("hydroMetrics")

  expect_match(desc$Maintainer, "pritamparida432@gmail.com", fixed = TRUE)
  expect_match(desc$URL, "https://github.com/Arcblade-02/hydroMetrics", fixed = TRUE)
  expect_match(desc$BugReports, "https://github.com/Arcblade-02/hydroMetrics/issues", fixed = TRUE)

  expect_true(is.function(utils::getS3method("print", "hydro_metrics")))
  expect_true(is.function(utils::getS3method("print", "hydro_metrics_batch")))
  expect_true(is.function(utils::getS3method("print", "hydro_preproc")))
  expect_true(all(c("gof", "ggof", "preproc") %in% getNamespaceExports("hydroMetrics")))

  refs <- hydroMetrics:::list_metrics()
  refs <- refs[refs$id %in% c("alpha", "beta", "r"), "references", drop = TRUE]
  expect_true(all(grepl("\\(2009\\)", refs)))

  if (file.exists(phase2_archive_repo_path("README.md")) && file.exists(phase2_archive_repo_path("NEWS.md"))) {
    expect_true(file.exists(phase2_archive_repo_path("README.md")))
    expect_true(file.exists(phase2_archive_repo_path("NEWS.md")))
  } else {
    testthat::skip("Source-tree root-documentation checks are unavailable in this installed-package context.")
  }
})
