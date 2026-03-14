test_that("Phase 2 merge-resolution artifacts exist after generation", {
  script_path <- phase2_archive_repo_path("tools", "phase2_merge_conflict_resolution.R")
  artifacts_dir <- phase2_archive_repo_path("notes", "merge-resolution")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      dir.exists(artifacts_dir),
    "Phase 2 merge-resolution artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(phase2_archive_repo_path("notes", "merge-resolution", "conflict_inventory.csv")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "merge-resolution", "resolution_log.md")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "merge-resolution", "validation_results.txt")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "merge-resolution", "final_merge_summary.md")))
})
