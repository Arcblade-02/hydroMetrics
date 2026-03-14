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
