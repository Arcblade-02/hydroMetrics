find_merge_sync_root <- function() {
  candidates <- unique(c(
    normalizePath(getwd(), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", "..", ".."), winslash = "/", mustWork = FALSE)
  ))

  for (candidate in candidates) {
    if (file.exists(file.path(candidate, "DESCRIPTION")) &&
        dir.exists(file.path(candidate, "notes", "merge-sync"))) {
      return(candidate)
    }
  }

  NA_character_
}

test_that("DESCRIPTION merge-sync artifacts exist", {
  root <- find_merge_sync_root()
  if (is.na(root)) {
    skip("Merge-sync artifacts are source-tree only and are not bundled into installed-package tests.")
  }

  expect_true(dir.exists(file.path(root, "notes", "merge-sync")))
  expect_true(file.exists(file.path(root, "notes", "merge-sync", "description_merge_decision.md")))
  expect_true(file.exists(file.path(root, "notes", "merge-sync", "baseline_sync_report.md")))
  expect_true(file.exists(file.path(root, "notes", "merge-sync", "validation_results.txt")))
  expect_true(file.exists(file.path(root, "notes", "merge-sync", "final_merge_sync_summary.md")))

  description_lines <- readLines(file.path(root, "DESCRIPTION"), warn = FALSE, encoding = "UTF-8")
  expect_false(any(grepl("<<<<<<<|=======|>>>>>>>", description_lines)))
  expect_true(any(grepl("^Version:[[:space:]]+0\\.(2\\.0|2\\.1)$", description_lines)))
})
