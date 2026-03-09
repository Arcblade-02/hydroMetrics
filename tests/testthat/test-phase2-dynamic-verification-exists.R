repo_path <- function(...) {
  testthat::test_path("..", "..", ...)
}

test_that("Phase 2 dynamic verification artifacts exist after generation", {
  script_path <- repo_path("tools", "phase2_dynamic_verification.R")
  artifacts_dir <- repo_path("notes", "dynamic-verification")

  testthat::skip_if_not(
    file.exists(script_path) && dir.exists(artifacts_dir),
    "Phase 2 dynamic verification source artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(repo_path("notes", "dynamic-verification", "load_all_results.txt")))
  expect_true(file.exists(repo_path("notes", "dynamic-verification", "testthat_results.txt")))
  expect_true(file.exists(repo_path("notes", "dynamic-verification", "check_results.txt")))
  expect_true(file.exists(repo_path("notes", "dynamic-verification", "install_results.txt")))
  expect_true(file.exists(repo_path("notes", "dynamic-verification", "namespace_export_results.txt")))
  expect_true(file.exists(repo_path("notes", "dynamic-verification", "runtime_summary.md")))
})
