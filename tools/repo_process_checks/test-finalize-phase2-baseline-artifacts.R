find_finalize_phase2_root <- function() {
  candidates <- unique(c(
    normalizePath(getwd(), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", "..", ".."), winslash = "/", mustWork = FALSE)
  ))

  for (candidate in candidates) {
    if (file.exists(file.path(candidate, "DESCRIPTION")) &&
        dir.exists(file.path(candidate, "notes", "finalize-phase2-baseline"))) {
      return(candidate)
    }
  }

  NA_character_
}

test_that("finalize phase2 baseline artifacts exist", {
  root <- find_finalize_phase2_root()
  if (is.na(root)) {
    skip("Phase 2 baseline finalization artifacts are source-tree only and are not bundled into installed-package tests.")
  }

  notes_dir <- file.path(root, "notes", "finalize-phase2-baseline")
  expect_true(dir.exists(notes_dir))
  expect_true(file.exists(file.path(notes_dir, "cleanup_report.md")))
  expect_true(file.exists(file.path(notes_dir, "merge_and_validation_report.md")))
  expect_true(file.exists(file.path(notes_dir, "tag_release_report.md")))
  expect_true(file.exists(file.path(notes_dir, "final_baseline_summary.md")))

  desc <- as.list(read.dcf(file.path(root, "DESCRIPTION"))[1, ])
  expect_true(desc[["Version"]] %in% c("0.2.0", "0.2.1", "0.3.0"))
})
