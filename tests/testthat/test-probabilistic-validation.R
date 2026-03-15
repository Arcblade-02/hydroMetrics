test_that("crps matches the degenerate-ensemble absolute-error identity", {
  point_forecast <- c(1.5, 2.5, 4.0)
  obs <- c(1.0, 3.0, 3.5)
  ens <- cbind(point_forecast, point_forecast)

  expected <- mean(abs(point_forecast - obs))

  expect_equal(crps(ens, obs), expected)
})

test_that("quantile_loss at tau = 0.5 equals half the mean absolute error", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2)

  expected <- 0.5 * mean(abs(obs - sim))

  expect_equal(quantile_loss(sim, obs, tau = 0.5), expected)
})

test_that("crps matches scoringRules::crps_sample when available", {
  skip_if_not_installed("scoringRules")

  ens <- matrix(
    c(
      1.0, 1.2, 0.8,
      2.0, 2.2, 1.8,
      3.0, 3.2, 2.8
    ),
    nrow = 3,
    byrow = TRUE
  )
  obs <- c(1.1, 2.1, 3.1)

  expected <- mean(scoringRules::crps_sample(y = obs, dat = ens, method = "edf"))

  expect_equal(crps(ens, obs), expected, tolerance = sqrt(.Machine$double.eps))
})
