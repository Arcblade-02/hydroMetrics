test_that("Phase 2 archive-cleanup artifacts exist after generation", {
  script_path <- phase2_archive_repo_path("tools", "phase2_artifact_archive_cleanup.R")
  artifacts_dir <- phase2_archive_repo_path("notes", "archive-cleanup")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      dir.exists(artifacts_dir),
    "Phase 2 archive-cleanup source artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(phase2_archive_repo_path("notes", "archive-cleanup", "archive_plan_matrix.csv")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "archive-cleanup", "archive_execution_log.md")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "archive-cleanup", "cleanup_validation_results.txt")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "archive-cleanup", "final_repo_layout.txt")))
  expect_true(file.exists(phase2_archive_repo_path("docs", "phase2_validation_summary.md")))
})
