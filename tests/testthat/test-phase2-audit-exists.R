test_that("phase 2 audit artifacts are archived and removed from production", {
  script_path <- phase2_archive_repo_path("tools", "phase2_baseline_audit.R")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      file.exists(script_path) &&
      phase2_archive_branch_exists(),
    "Source-tree archive validation only."
  )

  expect_true(file.exists(script_path))
  expect_false(dir.exists(phase2_archive_repo_path("notes", "audit")))
  expect_true(phase2_archive_has_path("notes/audit/repository_inventory.md"))
  expect_true(phase2_archive_has_path("notes/audit/phase2_compliance_matrix.csv"))
  expect_true(phase2_archive_has_path("notes/audit/defect_risk_register.csv"))
  expect_true(phase2_archive_has_path("notes/audit/dynamic_verification_plan.md"))
})
