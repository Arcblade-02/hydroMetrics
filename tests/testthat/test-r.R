test_that("r returns 1 for perfect positive correlation", {
  obs <- c(1, 2, 3)
  sim <- c(2, 4, 6)

  expect_equal(r(sim, obs), 1)

  out <- evaluate_metrics(sim, obs, "r")
  expect_equal(out$value[[1]], 1)
})

test_that("r returns -1 for perfect negative correlation", {
  obs <- c(1, 2, 3)
  sim <- c(3, 2, 1)

  expect_equal(r(sim, obs), -1)
})

test_that("r errors when any series has zero variance", {
  expect_error(
    r(c(1, 1, 1), c(1, 2, 3)),
    "zero variance; correlation undefined"
  )
  expect_error(
    r(c(1, 2, 3), c(2, 2, 2)),
    "zero variance; correlation undefined"
  )
})

test_that("r errors when fewer than 2 values are available", {
  expect_error(
    r(c(1), c(1)),
    "r requires at least 2 values"
  )
})

test_that("r wrapper uses preprocessing pipeline NA removal", {
  sim <- c(2, NA, 6)
  obs <- c(1, 2, 3)

  # After NA removal, paired vectors are sim=c(2,6), obs=c(1,3)
  expect_equal(r(sim, obs, na.rm = TRUE), 1)
})
