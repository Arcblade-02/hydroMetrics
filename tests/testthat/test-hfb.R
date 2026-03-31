test_that("HFB computes expected high-flow bias for default threshold", {
  obs <- 1:30
  sim <- obs + 2

  out <- HFB(sim, obs)
  q90 <- as.numeric(stats::quantile(obs, probs = 0.9, type = 7, names = FALSE))
  idx <- which(obs >= q90)
  expected <- (sum(sim[idx] - obs[idx]) / sum(obs[idx])) * 100

  expect_s3_class(out, "hydro_metric_scalar")
  expect_s3_class(out, "numeric")
  expect_equal(as.numeric(out), expected)
})

test_that("HFB supports custom threshold probability", {
  obs <- 1:40
  sim <- obs + 1

  out <- HFB(sim, obs, threshold_prob = 0.8)
  q80 <- as.numeric(stats::quantile(obs, probs = 0.8, type = 7, names = FALSE))
  idx <- which(obs >= q80)
  expected <- (sum(sim[idx] - obs[idx]) / sum(obs[idx])) * 100

  expect_equal(as.numeric(out), expected)
  expect_identical(attr(out, "meta")$threshold_prob, 0.8)
  expect_identical(attr(out, "meta")$n_high, as.integer(length(idx)))
})

test_that("HFB errors when fewer than three points meet the high-flow threshold", {
  obs <- 1:10
  sim <- obs

  expect_error(
    HFB(sim, obs, threshold_prob = 0.95),
    "at least 3 points"
  )
})

test_that("HFB returns NA with warning when denominator is zero", {
  obs <- rep(0, 10)
  sim <- rep(1, 10)

  expect_warning(
    out <- HFB(sim, obs, threshold_prob = 0.5),
    "denominator is zero"
  )
  expect_true(is.na(as.numeric(out)))
})

test_that("HFB returns a numerically coercible scalar with required attributes", {
  obs <- 1:30
  sim <- obs

  out <- HFB(sim, obs)
  expect_type(as.numeric(out), "double")
  expect_length(as.numeric(out), 1L)
  expect_identical(attr(out, "metric"), "HFB")
  expect_identical(attr(out, "n_obs"), 30L)
  expect_identical(attr(out, "meta")$aligned, TRUE)
  expect_identical(attr(out, "meta")$na_method, "remove")
  expect_true(is.call(attr(out, "call")))
})
