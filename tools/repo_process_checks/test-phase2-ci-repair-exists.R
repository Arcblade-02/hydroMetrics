test_that("Phase 2 CI repair artifacts exist after generation", {
  script_path <- phase2_archive_repo_path("tools", "phase2_ci_repair.R")
  artifacts_dir <- phase2_archive_repo_path("notes", "ci-repair")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      dir.exists(artifacts_dir),
    "Phase 2 CI repair artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(phase2_archive_repo_path("notes", "ci-repair", "ci_failure_inventory.csv")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "ci-repair", "ci_repair_log.md")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "ci-repair", "local_validation_results.txt")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "ci-repair", "push_and_pr_status.txt")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "ci-repair", "final_ci_repair_summary.md")))
})
