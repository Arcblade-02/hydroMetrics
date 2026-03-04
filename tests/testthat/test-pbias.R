test_that("pbias matches hand calculation on simple vector", {
  obs <- c(1, 2, 3)
  sim <- c(1, 2, 4)
  expected <- 100 * 1 / 6

  expect_equal(pbias(sim, obs), expected)

  out <- evaluate_metrics(sim, obs, "pbias")
  expect_equal(out$value[[1]], expected)
})

test_that("pbias errors when sum(obs) is zero", {
  expect_error(
    pbias(c(1, 2), c(-1, 1)),
    "sum\\(obs\\) is zero; PBIAS undefined"
  )
})

test_that("pbias returns negative values for underestimation", {
  obs <- c(2, 2, 2)
  sim <- c(1, 1, 1)
  expect_equal(pbias(sim, obs), -50)
})

test_that("pbias wrapper uses preprocessing pipeline NA removal", {
  sim <- c(1, NA, 4)
  obs <- c(1, 2, 3)

  # After NA removal, paired vectors are sim=c(1,4), obs=c(1,3)
  expect_equal(pbias(sim, obs, na.rm = TRUE), 25)
})
