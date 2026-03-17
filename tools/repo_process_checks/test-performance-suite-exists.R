test_that("performance suite scripts exist", {
  pkg_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION")) || !dir.exists(file.path(pkg_root, "tools"))) {
    testthat::skip("Source-tree validation only.")
  }
  expect_true(file.exists(file.path(pkg_root, "inst", "benchmarks", "performance_suite.R")))
  expect_true(file.exists(file.path(pkg_root, "tools", "run_performance_suite.R")))
})

test_that("performance output directory exists", {
  pkg_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION")) || !dir.exists(file.path(pkg_root, "notes"))) {
    testthat::skip("Source-tree validation only.")
  }
  expect_true(dir.exists(file.path(pkg_root, "notes", "performance")))
})
