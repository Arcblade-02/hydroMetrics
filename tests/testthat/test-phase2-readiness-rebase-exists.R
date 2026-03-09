test_that("phase2 readiness rebase artifacts exist after generator runs", {
  pkg_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION")) || !dir.exists(file.path(pkg_root, "tools"))) {
    testthat::skip("Source-tree validation only.")
  }

  base_dir <- file.path(pkg_root, "notes", "readiness-review")
  if (!dir.exists(base_dir)) {
    testthat::skip("Run phase2_readiness_rebase_review.R first.")
  }

  expected_files <- c(
    "baseline_validation.md",
    "documentation_audit.csv",
    "cran_preflight_checklist.csv",
    "phase2_readiness_matrix.csv",
    "final_phase2_review.md"
  )

  for (path in file.path(base_dir, expected_files)) {
    expect_true(file.exists(path), info = path)
  }
})
