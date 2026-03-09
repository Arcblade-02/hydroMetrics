test_that("R2 is distinct from NSE under biased predictions", {
  sim <- c(2, 4, 6, 8)
  obs <- c(1, 2, 3, 4)

  r2_value <- R2(sim, obs)
  nse_value <- NSE(sim, obs)

  expect_equal(r2_value, 1)
  expect_false(isTRUE(all.equal(r2_value, nse_value)))
})

test_that("NRMSE supports Phase 2 mean normalization as CV-RMSE", {
  sim <- c(1, 2, 3, 5)
  obs <- c(1, 2, 2, 4)
  expected <- sqrt(mean((sim - obs)^2)) / mean(obs)

  expect_identical(names(formals(NRMSE)), c("sim", "obs", "norm", "na.rm", "..."))
  expect_equal(NRMSE(sim, obs, norm = "mean"), expected)
})

test_that("NRMSE rejects unsupported normalization modes in Phase 2", {
  expect_error(
    NRMSE(c(1, 2, 3), c(1, 2, 2), norm = "sd"),
    "supports `NRMSE\\(norm = 'mean'\\)` only"
  )
})
