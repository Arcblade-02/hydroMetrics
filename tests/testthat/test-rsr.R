test_that("rsr matches hand calculation on simple vector", {
  obs <- c(1, 2, 3)
  sim <- c(1, 2, 4)
  expected <- sqrt(1 / 3)

  expect_equal(rsr(sim, obs), expected)

  out <- evaluate_metrics(sim, obs, "rsr")
  expect_equal(out$value[[1]], expected)
})

test_that("rsr errors when sd(obs) is zero", {
  expect_error(
    rsr(c(1, 2, 3), c(2, 2, 2)),
    "sd\\(obs\\) is zero; RSR undefined"
  )
})

test_that("rsr errors when fewer than 2 values are available", {
  expect_error(
    rsr(c(1), c(1)),
    "RSR requires at least 2 values"
  )
})

test_that("rsr wrapper uses preprocessing pipeline NA removal", {
  sim <- c(1, NA, 4)
  obs <- c(1, 2, 3)

  # After NA removal, paired vectors are sim=c(1,4), obs=c(1,3)
  expect_equal(rsr(sim, obs, na.rm = TRUE), 0.5)
})
