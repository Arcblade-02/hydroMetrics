repo_path <- function(...) {
  testthat::test_path("..", "..", ...)
}

test_that("Phase 2 release-hardening artifacts exist after generation", {
  script_path <- repo_path("tools", "phase2_release_hardening.R")
  artifacts_dir <- repo_path("notes", "release-hardening")

  testthat::skip_if_not(
    file.exists(script_path) && dir.exists(artifacts_dir),
    "Phase 2 release-hardening source artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(repo_path("notes", "release-hardening", "hardening_plan_matrix.csv")))
  expect_true(file.exists(repo_path("notes", "release-hardening", "ci_expansion_results.txt")))
  expect_true(file.exists(repo_path("notes", "release-hardening", "vignette_results.txt")))
  expect_true(file.exists(repo_path("notes", "release-hardening", "version_alignment_results.txt")))
  expect_true(file.exists(repo_path("notes", "release-hardening", "final_validation_results.txt")))
  expect_true(file.exists(repo_path("notes", "release-hardening", "final_go_assessment.md")))
})
