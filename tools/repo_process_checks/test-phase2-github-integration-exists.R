test_that("Phase 2 GitHub integration artifacts exist after verification", {
  repo_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = TRUE)
  script_path <- file.path(repo_root, "tools", "phase2_github_integration.R")
  artifacts_dir <- file.path(repo_root, "notes", "github-integration")

  testthat::skip_if_not(
    file.exists(file.path(repo_root, "DESCRIPTION")) &&
      file.exists(script_path) &&
      dir.exists(artifacts_dir),
    "Phase 2 GitHub integration source artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(file.path(artifacts_dir, "integration_plan_matrix.csv")))
  expect_true(file.exists(file.path(artifacts_dir, "branch_validation_results.txt")))
  expect_true(file.exists(file.path(artifacts_dir, "merge_results.txt")))
  expect_true(file.exists(file.path(artifacts_dir, "push_results.txt")))
  expect_true(file.exists(file.path(artifacts_dir, "remote_verification.txt")))
  expect_true(file.exists(file.path(artifacts_dir, "final_integration_summary.md")))
})
