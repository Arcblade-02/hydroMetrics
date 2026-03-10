test_that("wrapper export contract includes the intended Phase 2 surface", {
  exports <- getNamespaceExports("hydroMetrics")
  expected <- c(
    "NSE", "KGE", "MAE", "RMSE", "PBIAS", "R2", "NRMSE",
    "gof", "ggof", "preproc", "valindex"
  )

  expect_true(all(expected %in% exports))
})

test_that("wrapper export closure artifacts are present", {
  notes_root <- test_path("..", "..", "notes", "wrapper-export-closure")
  if (!dir.exists(notes_root)) {
    skip("source-tree wrapper export closure notes are excluded from built package checks")
  }

  files <- c(
    "notes/wrapper-export-closure/wrapper_gap_inventory.csv",
    "notes/wrapper-export-closure/wrapper_export_decisions.md",
    "notes/wrapper-export-closure/wrapper_runtime_verification.md",
    "notes/wrapper-export-closure/naming_policy_verification.md",
    "notes/wrapper-export-closure/validation_results.txt",
    "notes/wrapper-export-closure/release_patch_recommendation.md"
  )

  for (path in files) {
    expect_true(file.exists(test_path("..", "..", path)), info = path)
  }
})

test_that("direct wrappers return deterministic Phase 2 values", {
  sim <- c(1, 2, 3, 5)
  obs <- c(1, 2, 2, 4)

  expect_equal(NSE(sim, obs), 0.5789473684210527, tolerance = 1e-12)
  expect_equal(RMSE(sim, obs), sqrt(0.5), tolerance = 1e-12)
  expect_equal(R2(sim, obs), 0.9398496240601504, tolerance = 1e-12)
  expect_equal(NRMSE(sim, obs, norm = "mean"), 0.31426968052735443, tolerance = 1e-12)
  expect_equal(PBIAS(sim, obs), 22.22222222222222, tolerance = 1e-12)

  expect_equal(
    KGE(sim, obs),
    unname(gof(sim, obs, methods = "KGE")$KGE),
    tolerance = 1e-12
  )
})
