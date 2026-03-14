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

test_that("selected exported hydroGOF-overlap wrappers match hydroGOF references", {
  skip_if_not_installed("hydroGOF")

  sim <- c(1.1, 2.2, 2.8, 4.1, 5.2)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  tol <- sqrt(.Machine$double.eps)

  expect_equal(NSeff(sim, obs), hydroGOF::NSE(sim, obs), tolerance = tol)
  expect_equal(mNSeff(sim, obs), hydroGOF::mNSE(sim, obs), tolerance = tol)
  expect_equal(mae(sim, obs), hydroGOF::mae(sim, obs), tolerance = tol)
  expect_equal(rsr(sim, obs), hydroGOF::rsr(sim, obs), tolerance = tol)
})
