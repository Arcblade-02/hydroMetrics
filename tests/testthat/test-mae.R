test_that("mae matches hand calculation on simple vector", {
  obs <- c(1, 2, 3)
  sim <- c(1, 2, 4)
  expected <- 1 / 3

  expect_equal(mae(sim, obs), expected)

  out <- evaluate_metrics(sim, obs, "mae")
  expect_equal(out$value[[1]], expected)
})

test_that("mae supports single-value input", {
  expect_equal(mae(c(4), c(1)), 3)
})

test_that("mae errors on zero-length input when called through engine", {
  expect_error(
    evaluate_metrics(numeric(0), numeric(0), "mae"),
    "MAE requires at least 1 value"
  )
})

test_that("mae wrapper uses preprocessing pipeline NA removal", {
  sim <- c(1, NA, 4)
  obs <- c(1, 2, 3)

  # After NA removal, paired vectors are sim=c(1,4), obs=c(1,3)
  expect_equal(mae(sim, obs, na.rm = TRUE), 0.5)
})
