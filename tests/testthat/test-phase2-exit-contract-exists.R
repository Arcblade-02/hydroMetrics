test_that("Phase 2 exit-contract artifacts exist after generation", {
  root <- phase2_archive_repo_root()
  artifacts_dir <- file.path(root, "notes", "phase2-exit")

  testthat::skip_if_not(
    phase2_archive_source_repo_available() &&
      dir.exists(artifacts_dir),
    "Phase 2 exit-contract artifacts are unavailable in this test context."
  )

  expect_true(dir.exists(artifacts_dir))
  expect_true(file.exists(file.path(root, "notes", "phase2-exit", "wrapper_inventory.csv")))
  expect_true(file.exists(file.path(root, "notes", "phase2-exit", "wrapper_signature_matrix.csv")))
  expect_true(file.exists(file.path(root, "notes", "phase2-exit", "cran_preflight_checklist.csv")))
  expect_true(file.exists(file.path(root, "notes", "phase2-exit", "edge_case_matrix.csv")))
  expect_true(file.exists(file.path(root, "notes", "phase2-exit", "indexed_input_public_api_matrix.csv")))
  expect_true(file.exists(file.path(root, "docs", "DEVIATION_REGISTER.md")))
  expect_true(file.exists(file.path(root, "docs", "PHASE2_EXIT_MEMO.md")))
  expect_true(file.exists(file.path(root, "inst", "benchmarks", "benchmark_results.csv")))
  expect_true(file.exists(file.path(root, "inst", "benchmarks", "benchmark_summary.md")))
  expect_true(file.exists(file.path(root, "DECISIONS.md")))
})
