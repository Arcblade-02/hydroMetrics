test_that("Phase 2 wrapper surface is exported with the planned signatures", {
  exports <- getNamespaceExports("hydroMetrics")
  expected_wrappers <- c("NSE", "KGE", "MAE", "RMSE", "PBIAS", "R2", "NRMSE", "gof", "ggof")

  expect_true(all(expected_wrappers %in% exports))

  expect_identical(names(formals(NSE)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(KGE)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(MAE)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(RMSE)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(PBIAS)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(R2)), c("sim", "obs", "na.rm", "..."))
  expect_identical(names(formals(NRMSE)), c("sim", "obs", "norm", "na.rm", "..."))
  expect_identical(eval(formals(NRMSE)$norm), "mean")
})

test_that("Phase 2 wrappers return numeric scalars or vectors and honor na.rm", {
  sim <- c(1, NA, 3, 4)
  obs <- c(1, 2, 2, 4)

  expect_type(NSE(sim, obs, na.rm = TRUE), "double")
  expect_type(KGE(sim, obs, na.rm = TRUE), "double")
  expect_type(MAE(sim, obs, na.rm = TRUE), "double")
  expect_type(RMSE(sim, obs, na.rm = TRUE), "double")
  expect_type(PBIAS(sim, obs, na.rm = TRUE), "double")
  expect_type(R2(sim, obs, na.rm = TRUE), "double")
  expect_type(NRMSE(sim, obs, norm = "mean", na.rm = TRUE), "double")

  sim_mat <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs_mat <- cbind(a = c(1, 2, 2), b = c(2, 2, 3))
  expect_true(is.numeric(NSE(sim_mat, obs_mat)))
  expect_length(NSE(sim_mat, obs_mat), 2L)
  expect_true(is.numeric(RMSE(sim_mat, obs_mat)))
  expect_length(PBIAS(sim_mat, obs_mat), 2L)
})

test_that("Phase 2 wrappers retain deterministic error behavior where relevant", {
  expect_error(
    PBIAS(c(1, 2, 3), c(0, 0, 0)),
    "PBIAS undefined"
  )

  expect_error(
    NRMSE(c(1, 2, 3), c(0, 0, 0), norm = "mean"),
    "mean\\(obs\\) is 0"
  )
})
