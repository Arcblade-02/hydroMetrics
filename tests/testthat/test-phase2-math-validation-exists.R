test_that("Phase 2 math validation artifacts are archived and removed from production", {
  script_path <- phase2_archive_repo_path("tools", "phase2_math_validation.R")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      phase2_archive_branch_exists(),
    "Phase 2 math validation archive validation is unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_false(dir.exists(phase2_archive_repo_path("notes", "math-validation")))
  expect_true(phase2_archive_has_path("notes/math-validation/metric_inventory.csv"))
  expect_true(phase2_archive_has_path("notes/math-validation/formula_provenance_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/math-validation/duplicate_metric_scan.csv"))
  expect_true(phase2_archive_has_path("notes/math-validation/edge_case_behavior_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/math-validation/multi_column_behavior_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/math-validation/scientific_defect_register.csv"))
  expect_true(phase2_archive_has_path("notes/math-validation/math_validation_summary.md"))
})
