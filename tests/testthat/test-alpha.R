test_that("alpha matches hand calculation on simple vector", {
  obs <- c(1, 2, 3)
  sim <- c(2, 4, 6)

  expect_equal(alpha(sim, obs), 2)

  out <- evaluate_metrics(sim, obs, "alpha")
  expect_equal(out$value[[1]], 2)
})

test_that("alpha errors when sd(obs) is zero", {
  expect_error(
    alpha(c(1, 2, 3), c(2, 2, 2)),
    "sd\\(obs\\) is zero; alpha undefined"
  )
})

test_that("alpha errors when fewer than 2 values are available", {
  expect_error(
    alpha(c(1), c(1)),
    "alpha requires at least 2 values"
  )
})

test_that("alpha wrapper uses preprocessing pipeline NA removal", {
  sim <- c(2, NA, 6)
  obs <- c(1, 2, 3)

  # After NA removal, paired vectors are sim=c(2,6), obs=c(1,3)
  expect_equal(alpha(sim, obs, na.rm = TRUE), sqrt(8) / sqrt(2))
})
