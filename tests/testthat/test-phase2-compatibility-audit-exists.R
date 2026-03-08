repo_path <- function(...) {
  testthat::test_path("..", "..", ...)
}

test_that("Phase 2 compatibility audit artifacts exist after generation", {
  script_path <- repo_path("tools", "phase2_compatibility_audit.R")
  artifacts_dir <- repo_path("notes", "compatibility")

  testthat::skip_if_not(
    file.exists(script_path) && dir.exists(artifacts_dir),
    "Phase 2 compatibility audit source artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(repo_path("notes", "compatibility", "public_api_inventory.csv")))
  expect_true(file.exists(repo_path("notes", "compatibility", "wrapper_signature_matrix.csv")))
  expect_true(file.exists(repo_path("notes", "compatibility", "return_behavior_matrix.csv")))
  expect_true(file.exists(repo_path("notes", "compatibility", "input_shape_behavior_matrix.csv")))
  expect_true(file.exists(repo_path("notes", "compatibility", "compatibility_scorecard.csv")))
  expect_true(file.exists(repo_path("notes", "compatibility", "compatibility_divergence_register.csv")))
  expect_true(file.exists(repo_path("notes", "compatibility", "compatibility_summary.md")))
})
