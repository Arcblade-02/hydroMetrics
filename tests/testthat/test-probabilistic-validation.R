test_that("quantile_loss at tau = 0.5 equals half the mean absolute error", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2)

  expected <- 0.5 * mean(abs(obs - sim))

  expect_equal(quantile_loss(sim, obs, tau = 0.5), expected)
})
