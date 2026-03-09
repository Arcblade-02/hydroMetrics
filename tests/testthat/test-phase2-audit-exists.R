test_that("phase 2 audit artifacts are generated", {
  repo_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = TRUE)
  script_path <- file.path(repo_root, "tools", "phase2_baseline_audit.R")

  testthat::skip_if_not(
    file.exists(file.path(repo_root, "DESCRIPTION")) &&
      file.exists(script_path) &&
      dir.exists(file.path(repo_root, "notes", "audit")),
    "Source-tree validation only."
  )

  expect_true(file.exists(script_path))
  expect_true(dir.exists(file.path(repo_root, "notes", "audit")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "repository_inventory.md")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "phase2_compliance_matrix.csv")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "defect_risk_register.csv")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "dynamic_verification_plan.md")))
})
