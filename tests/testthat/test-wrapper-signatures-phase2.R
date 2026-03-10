test_that("Phase 2 wrapper signatures and defaults stay fixed", {
  expect_identical(names(formals(NSE)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(KGE)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(RMSE)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(R2)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(PBIAS)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(NRMSE)), c("sim", "obs", "norm", "na.rm", "..."))

  expect_null(eval(formals(NSE)$na.rm))
  expect_null(eval(formals(KGE)$na.rm))
  expect_null(eval(formals(RMSE)$na.rm))
  expect_null(eval(formals(R2)$na.rm))
  expect_null(eval(formals(PBIAS)$na.rm))
  expect_identical(eval(formals(NRMSE)$norm), "mean")
  expect_null(eval(formals(NRMSE)$na.rm))
})

test_that("Phase 2 wrappers honor na.rm and return numeric vectors for multi-series inputs", {
  sim <- c(1, NA, 3, 4)
  obs <- c(1, 2, 2, 4)
  sim_complete <- c(1, 3, 4)
  obs_complete <- c(1, 2, 4)

  expect_equal(NSE(sim, obs, na.rm = TRUE), NSE(sim_complete, obs_complete), tolerance = 1e-12)
  expect_equal(KGE(sim, obs, na.rm = TRUE), KGE(sim_complete, obs_complete), tolerance = 1e-12)
  expect_equal(RMSE(sim, obs, na.rm = TRUE), RMSE(sim_complete, obs_complete), tolerance = 1e-12)
  expect_equal(R2(sim, obs, na.rm = TRUE), R2(sim_complete, obs_complete), tolerance = 1e-12)
  expect_equal(NRMSE(sim, obs, norm = "mean", na.rm = TRUE), NRMSE(sim_complete, obs_complete, norm = "mean"), tolerance = 1e-12)
  expect_equal(PBIAS(sim, obs, na.rm = TRUE), PBIAS(sim_complete, obs_complete), tolerance = 1e-12)

  sim_mat <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs_mat <- cbind(a = c(1, 2, 2), b = c(2, 2, 3))

  expect_type(NSE(sim_mat, obs_mat), "double")
  expect_length(NSE(sim_mat, obs_mat), 2L)
  expect_type(RMSE(sim_mat, obs_mat), "double")
  expect_length(PBIAS(sim_mat, obs_mat), 2L)
})

test_that("R2, NSE, and NRMSE retain the documented Phase 2 behavior", {
  sim_biased <- c(2, 4, 6, 8)
  obs_biased <- c(1, 2, 3, 4)

  expect_equal(R2(sim_biased, obs_biased), 1, tolerance = 1e-12)
  expect_false(isTRUE(all.equal(R2(sim_biased, obs_biased), NSE(sim_biased, obs_biased))))

  expect_error(
    NRMSE(c(1, 2, 3), c(1, 2, 2), norm = "sd"),
    "supports `NRMSE\\(norm = 'mean'\\)` only"
  )
})
