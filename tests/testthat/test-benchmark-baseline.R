test_that("Workstream B benchmark baseline artifacts exist in the source tree", {
  pkg_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION")) || !dir.exists(file.path(pkg_root, "inst", "benchmarks"))) {
    testthat::skip("Source-tree validation only.")
  }

  expect_true(file.exists(file.path(pkg_root, "inst", "benchmarks", "README.md")))
  expect_true(file.exists(file.path(pkg_root, "inst", "benchmarks", "workstream_b_benchmark_suite.R")))
  expect_true(file.exists(file.path(pkg_root, "inst", "benchmarks", "workstream_b_benchmark_summary.md")))
  expect_true(file.exists(file.path(pkg_root, "inst", "benchmarks", "workstream_b_benchmark_results.csv")))
  expect_true(file.exists(file.path(pkg_root, "tools", "run_workstream_b_benchmark_baseline.R")))
})
