test_that("metric_nse matches hydroGOF::NSE", {
  skip_if_not_installed("hydroGOF")

  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  expect_equal(
    hydroMetrics:::metric_nse(sim, obs),
    hydroGOF::NSE(sim, obs),
    tolerance = sqrt(.Machine$double.eps)
  )
})
