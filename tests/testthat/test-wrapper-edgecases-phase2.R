test_that("Phase 2 wrapper edge cases cover numeric, matrix, zoo, and xts inputs", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 2, 4)
  sim_mat <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs_mat <- cbind(a = c(1, 2, 2), b = c(2, 2, 3))

  expect_type(NSE(sim, obs), "double")
  expect_type(KGE(sim, obs), "double")
  expect_type(RMSE(sim, obs), "double")
  expect_type(MAE(sim, obs), "double")
  expect_type(PBIAS(sim, obs), "double")
  expect_type(R2(sim, obs), "double")
  expect_type(NRMSE(sim, obs, norm = "mean"), "double")

  expect_true(is.numeric(NSE(sim_mat, obs_mat)))
  expect_true(is.numeric(KGE(sim_mat, obs_mat)))
  expect_true(is.numeric(RMSE(sim_mat, obs_mat)))
  expect_true(is.numeric(MAE(sim_mat, obs_mat)))
  expect_true(is.numeric(PBIAS(sim_mat, obs_mat)))
  expect_true(is.numeric(R2(sim_mat, obs_mat)))
  expect_true(is.numeric(NRMSE(sim_mat, obs_mat, norm = "mean")))

  skip_if_not_installed("zoo")
  idx <- as.Date("2021-01-01") + 0:3
  zoo_sim <- zoo::zoo(sim, order.by = idx)
  zoo_obs <- zoo::zoo(obs, order.by = idx)

  expect_type(NSE(zoo_sim, zoo_obs), "double")
  expect_type(KGE(zoo_sim, zoo_obs), "double")
  expect_type(RMSE(zoo_sim, zoo_obs), "double")
  expect_type(MAE(zoo_sim, zoo_obs), "double")
  expect_type(PBIAS(zoo_sim, zoo_obs), "double")
  expect_type(R2(zoo_sim, zoo_obs), "double")
  expect_type(NRMSE(zoo_sim, zoo_obs, norm = "mean"), "double")

  skip_if_not_installed("xts")
  xts_sim <- xts::xts(sim, order.by = idx)
  xts_obs <- xts::xts(obs, order.by = idx)

  expect_type(NSE(xts_sim, xts_obs), "double")
  expect_type(KGE(xts_sim, xts_obs), "double")
  expect_type(RMSE(xts_sim, xts_obs), "double")
  expect_type(MAE(xts_sim, xts_obs), "double")
  expect_type(PBIAS(xts_sim, xts_obs), "double")
  expect_type(R2(xts_sim, xts_obs), "double")
  expect_type(NRMSE(xts_sim, xts_obs, norm = "mean"), "double")
})

test_that("Phase 2 wrapper edge cases exercise lowercase compatibility wrappers", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 2, 4)

  expect_type(alpha(sim, obs), "double")
  expect_type(beta(sim, obs), "double")
  expect_type(mae(sim, obs), "double")
  expect_type(pbias(sim, obs), "double")
  expect_type(r(sim, obs), "double")
  expect_type(rsr(sim, obs), "double")
  expect_type(NSeff(sim, obs), "double")
  expect_type(mNSeff(sim, obs), "double")
  expect_type(rNSeff(c(1, 2, 4), c(1, 2, 3)), "double")
  expect_type(wsNSeff(c(1, 2, 4), c(1, 2, 3)), "double")
  expect_type(pfactor(sim, obs), "double")
  expect_type(rfactor(sim, obs), "double")
})

test_that("Phase 2 wrapper edge cases cover indexed wrappers and error contracts", {
  expect_error(APFB(1:4, 1:4), "requires zoo/xts inputs")
  expect_error(HFB(1:4, 1:4, threshold_prob = 1), "must be a numeric scalar")

  skip_if_not_installed("zoo")
  idx <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
  zoo_sim <- zoo::zoo(c(12, 18, 33, 35), order.by = idx)
  zoo_obs <- zoo::zoo(c(10, 20, 30, 40), order.by = idx)

  expect_s3_class(APFB(zoo_sim, zoo_obs), "hydro_metric_scalar")
  expect_s3_class(HFB(c(2, 4, 6, 8, 10), c(1, 3, 5, 7, 9), threshold_prob = 0.5), "hydro_metric_scalar")
})

test_that("Phase 2 wrapper edge cases cover NA removal and mismatched lengths", {
  sim <- c(1, NA, 3, 4)
  obs <- c(1, 2, 3, 4)

  expect_equal(NSE(sim, obs, na.rm = TRUE), 1)
  expect_equal(RMSE(sim, obs, na.rm = TRUE), 0)
  expect_equal(MAE(sim, obs, na.rm = TRUE), 0)
  expect_equal(PBIAS(sim, obs, na.rm = TRUE), 0)

  expect_error(NSE(c(1, 2, 3), c(1, 2)), "same length")
  expect_error(KGE(c(1, 2, 3), c(1, 2)), "same length")
  expect_error(RMSE(c(1, 2, 3), c(1, 2)), "same length")
  expect_error(MAE(c(1, 2, 3), c(1, 2)), "same length")
  expect_error(PBIAS(c(1, 2, 3), c(1, 2)), "same length")
  expect_error(R2(c(1, 2, 3), c(1, 2)), "same length")
  expect_error(NRMSE(c(1, 2, 3), c(1, 2), norm = "mean"), "same length")
})
