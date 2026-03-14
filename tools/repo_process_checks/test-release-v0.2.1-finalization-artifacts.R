find_release_v0_2_1_root <- function() {
  candidates <- unique(c(
    normalizePath(getwd(), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = FALSE),
    normalizePath(file.path(testthat::test_path(), "..", "..", ".."), winslash = "/", mustWork = FALSE)
  ))

  for (candidate in candidates) {
    if (file.exists(file.path(candidate, "DESCRIPTION")) &&
        dir.exists(file.path(candidate, "notes", "release-v0.2.1"))) {
      return(candidate)
    }
  }

  NA_character_
}

test_that("v0.2.1 release finalization artifacts are present in the source tree", {
  root <- find_release_v0_2_1_root()
  if (is.na(root)) {
    skip("source-tree release finalization notes are excluded from built package checks")
  }
  notes_root <- file.path(root, "notes", "release-v0.2.1")

  files <- c(
    "release_merge_report.md",
    "version_bump_report.md",
    "validation_results.txt",
    "tag_and_push_report.md",
    "final_release_summary.md"
  )

  for (path in files) {
    expect_true(file.exists(file.path(notes_root, path)), info = path)
  }
})

test_that("v0.2.1 release finalization metadata is preserved alongside the current package state", {
  root <- find_release_v0_2_1_root()
  if (is.na(root)) {
    skip("source-tree release finalization metadata checks are excluded from built package checks")
  }

  description_path <- file.path(root, "DESCRIPTION")
  news_path <- file.path(root, "NEWS.md")
  description_text <- paste(readLines(description_path, warn = FALSE), collapse = "\n")
  news_text <- paste(readLines(news_path, warn = FALSE), collapse = "\n")

  expect_true(file.exists(description_path))
  expect_true(file.exists(news_path))
  expect_match(description_text, "(?m)^Version:\\s*0\\.3\\.0\\s*$", perl = TRUE)
  expect_match(news_text, "(?m)^##\\s+0\\.2\\.1\\s*$", perl = TRUE)
})
