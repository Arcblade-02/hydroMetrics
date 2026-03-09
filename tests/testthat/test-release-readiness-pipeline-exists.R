find_release_readiness_root <- function() {
  candidates <- unique(c(
    normalizePath(getwd(), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", "..", ".."), winslash = "/", mustWork = FALSE)
  ))

  for (candidate in candidates) {
    if (file.exists(file.path(candidate, "DESCRIPTION")) &&
        dir.exists(file.path(candidate, "tools", "release_readiness"))) {
      return(candidate)
    }
  }

  NA_character_
}

test_that("release readiness pipeline structure exists", {
  root <- find_release_readiness_root()
  if (is.na(root)) {
    skip("Release-readiness artifacts are source-tree only and are not bundled into installed-package tests.")
  }

  expect_true(file.exists(file.path(root, "tools", "release_readiness", "run_release_readiness_pipeline.R")))
  expect_true(file.exists(file.path(root, "tools", "release_readiness", "clean_install_check.R")))
  expect_true(file.exists(file.path(root, "tools", "release_readiness", "public_api_check.R")))
  expect_true(file.exists(file.path(root, "tools", "release_readiness", "behavior_matrix_check.R")))
  expect_true(file.exists(file.path(root, "tools", "release_readiness", "math_contract_check.R")))
  expect_true(file.exists(file.path(root, "tools", "release_readiness", "test_and_coverage_check.R")))
  expect_true(file.exists(file.path(root, "tools", "release_readiness", "docs_and_vignette_check.R")))
  expect_true(file.exists(file.path(root, "tools", "release_readiness", "checks_and_ci_check.R")))

  expect_true(file.exists(file.path(root, "notes", "release-readiness", "clean_install_report.md")))
  expect_true(file.exists(file.path(root, "notes", "release-readiness", "public_api_inventory.csv")))
  expect_true(file.exists(file.path(root, "notes", "release-readiness", "edge_case_behavior_matrix.csv")))
  expect_true(file.exists(file.path(root, "notes", "release-readiness", "cran_preflight_report.md")))
  expect_true(file.exists(file.path(root, "notes", "release-readiness", "minimal_acceptance_checklist.csv")))

  expect_true(file.exists(file.path(root, "docs", "DEVIATION_REGISTER.md")))
  expect_true(file.exists(file.path(root, "docs", "PHASE2_EXIT_MEMO.md")))
})
