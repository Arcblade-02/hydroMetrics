test_that("Phase 2 oldrel compatibility repair artifacts exist after generation", {
  script_path <- phase2_archive_repo_path("tools", "phase2_oldrel_compatibility_repair.R")
  artifacts_dir <- phase2_archive_repo_path("notes", "oldrel-compatibility-repair")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      dir.exists(artifacts_dir),
    "Phase 2 oldrel compatibility repair artifacts are unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(phase2_archive_repo_path("notes", "oldrel-compatibility-repair", "failure_inventory.csv")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "oldrel-compatibility-repair", "repair_log.md")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "oldrel-compatibility-repair", "local_validation_results.txt")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "oldrel-compatibility-repair", "push_and_pr_status.txt")))
  expect_true(file.exists(phase2_archive_repo_path("notes", "oldrel-compatibility-repair", "final_oldrel_repair_summary.md")))
})
