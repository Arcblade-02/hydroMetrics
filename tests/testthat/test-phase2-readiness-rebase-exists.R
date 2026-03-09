test_that("phase2 readiness rebase artifacts are archived and removed from production", {
  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      dir.exists(phase2_archive_repo_path("tools")) &&
      phase2_archive_branch_exists(),
    "Source-tree archive validation only."
  )

  expect_false(dir.exists(phase2_archive_repo_path("notes", "readiness-review")))
  expect_true(phase2_archive_has_path("notes/readiness-review/baseline_validation.md"))
  expect_true(phase2_archive_has_path("notes/readiness-review/documentation_audit.csv"))
  expect_true(phase2_archive_has_path("notes/readiness-review/cran_preflight_checklist.csv"))
  expect_true(phase2_archive_has_path("notes/readiness-review/phase2_readiness_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/readiness-review/final_phase2_review.md"))
})
