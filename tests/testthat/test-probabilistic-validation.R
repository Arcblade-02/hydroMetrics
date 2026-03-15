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

test_that("crps matches scoringRules::crps_sample within the recorded tolerance rule", {
  skip_if_not_installed("scoringRules")

  cases <- list(
    list(
      ens = matrix(
        c(
          1.0, 1.2, 0.8,
          2.0, 2.2, 1.8,
          3.0, 3.2, 2.8
        ),
        nrow = 3,
        byrow = TRUE
      ),
      obs = c(1.1, 2.1, 3.1)
    ),
    list(
      ens = matrix(
        c(
          0.0, 0.5, 1.0, 1.5, 2.0, 2.5,
          1.0, 1.5, 2.0, 2.5, 3.0, 3.5,
          2.0, 2.0, 2.5, 3.0, 3.5, 4.0,
          4.0, 4.5, 5.0, 5.5, 6.0, 6.5
        ),
        nrow = 4,
        byrow = TRUE
      ),
      obs = c(0.7, 2.1, 3.1, 5.2)
    ),
    list(
      ens = matrix(
        c(
          1.5, 1.5, 1.5, 1.5,
          2.5, 2.5, 2.5, 2.5,
          4.0, 4.0, 4.0, 4.0
        ),
        nrow = 3,
        byrow = TRUE
      ),
      obs = c(1.0, 3.0, 3.5)
    )
  )

  tolerance <- sqrt(.Machine$double.eps)

  for (case in cases) {
    expected <- mean(scoringRules::crps_sample(
      y = case$obs,
      dat = case$ens,
      method = "edf"
    ))

    expect_equal(crps(case$ens, case$obs), expected, tolerance = tolerance)
  }
})
