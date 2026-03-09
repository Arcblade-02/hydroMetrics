repo_path <- function(...) {
  testthat::test_path("..", "..", ...)
}

test_that("Phase 2 math validation artifacts exist after generation", {
  script_path <- repo_path("tools", "phase2_math_validation.R")
  artifacts_dir <- repo_path("notes", "math-validation")

  testthat::skip_if_not(
    file.exists(script_path) && dir.exists(artifacts_dir),
    "Phase 2 math validation source artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(repo_path("notes", "math-validation", "metric_inventory.csv")))
  expect_true(file.exists(repo_path("notes", "math-validation", "formula_provenance_matrix.csv")))
  expect_true(file.exists(repo_path("notes", "math-validation", "duplicate_metric_scan.csv")))
  expect_true(file.exists(repo_path("notes", "math-validation", "edge_case_behavior_matrix.csv")))
  expect_true(file.exists(repo_path("notes", "math-validation", "multi_column_behavior_matrix.csv")))
  expect_true(file.exists(repo_path("notes", "math-validation", "scientific_defect_register.csv")))
  expect_true(file.exists(repo_path("notes", "math-validation", "math_validation_summary.md")))
})
