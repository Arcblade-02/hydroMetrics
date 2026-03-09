test_that("Phase 2 release-hardening artifacts are archived and removed from production", {
  script_path <- phase2_archive_repo_path("tools", "phase2_release_hardening.R")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      phase2_archive_branch_exists(),
    "Phase 2 release-hardening archive validation is unavailable in this test context."
  )

  expect_true(file.exists(script_path))
  expect_false(dir.exists(phase2_archive_repo_path("notes", "release-hardening")))
  expect_true(phase2_archive_has_path("notes/release-hardening/hardening_plan_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/release-hardening/ci_expansion_results.txt"))
  expect_true(phase2_archive_has_path("notes/release-hardening/vignette_results.txt"))
  expect_true(phase2_archive_has_path("notes/release-hardening/version_alignment_results.txt"))
  expect_true(phase2_archive_has_path("notes/release-hardening/final_validation_results.txt"))
  expect_true(phase2_archive_has_path("notes/release-hardening/final_go_assessment.md"))
})
