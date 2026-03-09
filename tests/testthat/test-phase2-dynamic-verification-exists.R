test_that("Phase 2 dynamic verification artifacts are archived and removed from production", {
  script_path <- phase2_archive_repo_path("tools", "phase2_dynamic_verification.R")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      phase2_archive_branch_exists(),
    "Phase 2 dynamic verification archive validation is unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_false(dir.exists(phase2_archive_repo_path("notes", "dynamic-verification")))
  expect_true(phase2_archive_has_path("notes/dynamic-verification/load_all_results.txt"))
  expect_true(phase2_archive_has_path("notes/dynamic-verification/testthat_results.txt"))
  expect_true(phase2_archive_has_path("notes/dynamic-verification/check_results.txt"))
  expect_true(phase2_archive_has_path("notes/dynamic-verification/install_results.txt"))
  expect_true(phase2_archive_has_path("notes/dynamic-verification/namespace_export_results.txt"))
  expect_true(phase2_archive_has_path("notes/dynamic-verification/runtime_summary.md"))
})
