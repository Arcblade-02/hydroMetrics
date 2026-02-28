test_that("cp matches hand-calculated persistence skill score", {
  obs <- c(1, 2, 3, 4)
  sim <- c(1, 2, 2, 4)

  obs_t <- obs[-1]
  sim_t <- sim[-1]
  obs_lag <- obs[-length(obs)]
  expected <- 1 - sum((obs_t - sim_t)^2) / sum((obs_t - obs_lag)^2)

  out <- evaluate_metrics(sim, obs, "cp")
  expect_equal(out$value[[1]], expected)

  cp_out <- cp(sim, obs)
  expect_equal(cp_out, expected)
})

test_that("cp errors when input length is less than 2", {
  expect_error(
    evaluate_metrics(sim = c(1), obs = c(1), metrics = "cp"),
    "at least 2 observations"
  )
})

test_that("cp errors when persistence denominator is zero", {
  expect_error(
    evaluate_metrics(sim = c(2, 2, 2), obs = c(2, 2, 2), metrics = "cp"),
    "persistence baseline variance is zero"
  )
})
