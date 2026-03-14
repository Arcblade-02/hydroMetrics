test_that("Phase 2 compatibility audit artifacts are archived and removed from production", {
  script_path <- phase2_archive_repo_path("tools", "phase2_compatibility_audit.R")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      phase2_archive_branch_exists(),
    "Phase 2 compatibility audit archive validation is unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_false(dir.exists(phase2_archive_repo_path("notes", "compatibility")))
  expect_true(phase2_archive_has_path("notes/compatibility/public_api_inventory.csv"))
  expect_true(phase2_archive_has_path("notes/compatibility/wrapper_signature_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/compatibility/return_behavior_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/compatibility/input_shape_behavior_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/compatibility/compatibility_scorecard.csv"))
  expect_true(phase2_archive_has_path("notes/compatibility/compatibility_divergence_register.csv"))
  expect_true(phase2_archive_has_path("notes/compatibility/compatibility_summary.md"))
})
