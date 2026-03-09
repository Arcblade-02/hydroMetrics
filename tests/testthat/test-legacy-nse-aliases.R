test_that("legacy NSE aliases match underlying metric ids on simple vectors", {
  sim <- c(1, 2, 4)
  obs <- c(1, 2, 3)

  expect_equal(NSeff(sim, obs), as.numeric(gof(sim, obs, methods = "nse")[[1]]))
  expect_equal(mNSeff(sim, obs), as.numeric(gof(sim, obs, methods = "mnse")[[1]]))
  expect_equal(rNSeff(sim, obs), as.numeric(gof(sim, obs, methods = "rnse")[[1]]))
  expect_equal(wsNSeff(sim, obs), as.numeric(gof(sim, obs, methods = "wsnse")[[1]]))
})

test_that("legacy NSE aliases return deterministic values for a fixed example", {
  sim <- c(1, 2, 4)
  obs <- c(1, 2, 3)

  expect_equal(NSeff(sim, obs), 0.5)
  expect_equal(mNSeff(sim, obs), 0.5)
  expect_equal(rNSeff(sim, obs), 0.9)
  expect_equal(wsNSeff(sim, obs), 0.1)
})

test_that("legacy NSE aliases follow underlying denominator and length guard behavior", {
  expect_error(NSeff(c(1), c(1)), "non-missing numeric scalar")
  expect_error(mNSeff(c(1), c(1)), "denominator is 0")
  expect_error(rNSeff(c(1), c(1)), "denominator is 0")
  expect_error(wsNSeff(c(1), c(1)), "denominator is 0")

  expect_error(mNSeff(c(1, 2, 3), c(2, 2, 2)), "denominator is 0")
  expect_error(rNSeff(c(1, 2, 3), c(2, 2, 2)), "denominator is 0")
  expect_error(wsNSeff(c(1, 2, 3), c(2, 2, 2)), "denominator is 0")
})

test_that("rNSeff preserves zero-observation policy from rnse", {
  expect_error(rNSeff(c(1, 2, 3), c(1, 0, 2)), "obs contains zero")
})

test_that("wsNSeff remains a strict alias and does not support external weight injection", {
  expect_error(
    wsNSeff(
      c(1, 2, 4),
      c(1, 2, 3),
      metric_params = list(wsnse = list(w = c(1, -1, 1)))
    ),
    "unused argument"
  )
})
