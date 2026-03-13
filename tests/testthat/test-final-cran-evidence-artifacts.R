find_final_cran_evidence_root <- function() {
  candidates <- unique(c(
    normalizePath(getwd(), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", "..", ".."), winslash = "/", mustWork = FALSE)
  ))

  for (candidate in candidates) {
    if (file.exists(file.path(candidate, "DESCRIPTION")) &&
        dir.exists(file.path(candidate, "notes", "final-cran-evidence"))) {
      return(candidate)
    }
  }

  NA_character_
}

test_that("final CRAN evidence artifacts exist and are populated", {
  root <- find_final_cran_evidence_root()
  if (is.na(root)) {
    skip("Final CRAN evidence artifacts are source-tree only and are not bundled into installed-package tests.")
  }

  dir_path <- file.path(root, "notes", "final-cran-evidence")
  expect_true(dir.exists(dir_path))

  required <- c(
    "nonbroken_environment_report.md",
    "devtools_check_results.txt",
    "devtools_check_cran_results.txt",
    "live_ci_status_report.md",
    "final_cran_evidence_summary.md"
  )

  for (artifact in required) {
    artifact_path <- file.path(dir_path, artifact)
    expect_true(file.exists(artifact_path), info = artifact)
    expect_true(file.info(artifact_path)$size > 0, info = artifact)
  }
})
