test_that("batch4 metrics return expected hm_result structure and ids", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("me", "d", "md", "rd", "dr", "br2")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("me", "d", "md", "rd", "dr", "br2"))
})

test_that("batch4 perfect-fit values are correct", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 3)
  out <- evaluate_metrics(sim, obs, c("me", "d", "md", "rd", "dr", "br2"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["me"]], 0)
  expect_equal(values[["d"]], 1)
  expect_equal(values[["md"]], 1)
  expect_equal(values[["rd"]], 1)
  expect_equal(values[["dr"]], 1)
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
  dr_denom <- sum(abs(sim - obs_mean) / abs(obs) + abs(obs - obs_mean) / abs(obs))

  rd_rel_err <- (sim - obs) / obs
  dr_rel_abs <- abs(sim - obs) / abs(obs)

  r <- stats::cor(sim, obs)
  sd_penalty <- min(stats::sd(sim), stats::sd(obs)) / max(stats::sd(sim), stats::sd(obs))
  mean_penalty <- min(mean(sim), mean(obs)) / max(mean(sim), mean(obs))
  br2_expected <- (r^2) * (sd_penalty^2) * (mean_penalty^2)

  out <- evaluate_metrics(sim, obs, c("me", "d", "md", "rd", "dr", "br2"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["me"]], me_expected)
  expect_equal(values[["d"]], 1 - sum((sim - obs)^2) / d_denom)
  expect_equal(values[["md"]], 1 - sum(abs(sim - obs)) / md_denom)
  expect_equal(values[["rd"]], 1 - sum(rd_rel_err^2) / rd_denom)
  expect_equal(values[["dr"]], 1 - sum(dr_rel_abs) / dr_denom)
  expect_equal(values[["br2"]], br2_expected)
})

test_that("rd and dr error when obs contains zero", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, 0, 2), "rd"),
    "obs contains zero"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, 0, 2), "dr"),
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
    "sd == 0"
  )
})
