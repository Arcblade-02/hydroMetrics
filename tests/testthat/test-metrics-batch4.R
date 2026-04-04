test_that("batch4 metrics return expected hm_result structure and ids", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("me", "d", "md", "rd", "br2")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("me", "d", "md", "rd", "br2"))
})

test_that("batch4 perfect-fit values are correct", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 3)
  out <- evaluate_metrics(sim, obs, c("me", "d", "md", "rd", "br2"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["me"]], 0)
  expect_equal(values[["d"]], 1)
  expect_equal(values[["md"]], 1)
  expect_equal(values[["rd"]], 1)
  expect_equal(values[["br2"]], 1)
})

test_that("batch4 deterministic numeric formulas match inline computations", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  obs_mean <- mean(obs)

  me_expected <- mean(sim - obs)
  d_denom <- sum((abs(sim - obs_mean) + abs(obs - obs_mean))^2)
  md_denom <- sum(abs(sim - obs_mean) + abs(obs - obs_mean))
  rd_denom <- sum((abs((sim - obs_mean) / obs) + abs((obs - obs_mean) / obs))^2)
  rd_rel_err <- (sim - obs) / obs

  br2_slope <- unname(stats::coef(stats::lm(sim ~ obs))[2])
  br2_expected <- unname(if (br2_slope <= 1) abs(br2_slope) * stats::cor(sim, obs)^2 else stats::cor(sim, obs)^2 / abs(br2_slope))

  out <- evaluate_metrics(sim, obs, c("me", "d", "md", "rd", "br2"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["me"]], me_expected)
  expect_equal(values[["d"]], 1 - sum((sim - obs)^2) / d_denom)
  expect_equal(values[["md"]], 1 - sum(abs(sim - obs)) / md_denom)
  expect_equal(values[["rd"]], 1 - sum(rd_rel_err^2) / rd_denom)
  expect_equal(values[["br2"]], br2_expected)
})

test_that("rd errors when obs contains zero", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, 0, 2), "rd"),
    "obs contains zero"
  )
})

test_that("d and md error on zero denominator constant-series case", {
  expect_error(
    evaluate_metrics(c(2, 2, 2), c(2, 2, 2), "d"),
    "denominator is 0"
  )
  expect_error(
    evaluate_metrics(c(2, 2, 2), c(2, 2, 2), "md"),
    "denominator is 0"
  )
})

test_that("br2 errors when sd(obs) is zero", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "br2"),
    "sd\\(obs\\) == 0"
  )
})
