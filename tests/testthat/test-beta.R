test_that("beta matches hand calculation on simple vector", {
  obs <- c(1, 2, 3)
  sim <- c(2, 4, 6)

  expect_equal(beta(sim, obs), 2)

  out <- evaluate_metrics(sim, obs, "beta")
  expect_equal(out$value[[1]], 2)
})

test_that("beta errors when mean(obs) is zero", {
  expect_error(
    beta(c(-1, 1), c(-1, 1)),
    "mean\\(obs\\) is zero; beta undefined"
  )
})

test_that("beta supports single-value case", {
  expect_equal(beta(c(4), c(2)), 2)
})

test_that("beta wrapper uses preprocessing pipeline NA removal", {
  sim <- c(2, NA, 6)
  obs <- c(1, 2, 3)

  # After NA removal, paired vectors are sim=c(2,6), obs=c(1,3)
  expect_equal(beta(sim, obs, na.rm = TRUE), 2)
})
