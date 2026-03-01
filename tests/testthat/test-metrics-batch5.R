test_that("batch5 metrics return expected hm_result structure and ids", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("rnse", "mnse", "wnse", "wsnse", "ubrmse", "ssq")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("rnse", "mnse", "wnse", "wsnse", "ubrmse", "ssq"))
})

test_that("batch5 perfect-fit values are correct", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 3)
  out <- evaluate_metrics(sim, obs, c("rnse", "mnse", "wnse", "wsnse", "ubrmse", "ssq"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["rnse"]], 1)
  expect_equal(values[["mnse"]], 1)
  expect_equal(values[["wnse"]], 1)
  expect_equal(values[["wsnse"]], 1)
  expect_equal(values[["ubrmse"]], 0)
  expect_equal(values[["ssq"]], 0)
})

test_that("batch5 metrics match deterministic inline formulas", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  obs_mean <- mean(obs)

  rnse_expected <- 1 - sum(((sim - obs) / obs)^2) / sum(((obs - obs_mean) / obs)^2)
  mnse_expected <- 1 - sum(abs(sim - obs)) / sum(abs(obs - obs_mean))
  wnse_expected <- 1 - sum(obs * (sim - obs)^2) / sum(obs * (obs - obs_mean)^2)
  wsnse_expected <- 1 - sum((obs^2) * (sim - obs)^2) / sum((obs^2) * (obs - obs_mean)^2)
  ubrmse_expected <- sqrt(mean(((sim - mean(sim)) - (obs - mean(obs)))^2))
  ssq_expected <- sum((sim - obs)^2)

  out <- evaluate_metrics(sim, obs, c("rnse", "mnse", "wnse", "wsnse", "ubrmse", "ssq"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["rnse"]], rnse_expected)
  expect_equal(values[["mnse"]], mnse_expected)
  expect_equal(values[["wnse"]], wnse_expected)
  expect_equal(values[["wsnse"]], wsnse_expected)
  expect_equal(values[["ubrmse"]], ubrmse_expected)
  expect_equal(values[["ssq"]], ssq_expected)
})

test_that("rnse errors when obs contains zero", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, 0, 2), "rnse"),
    "obs contains zero"
  )
})

test_that("wnse and wsnse error when obs contains negative values", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, -2, 3), "wnse"),
    "negative"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, -2, 3), "wsnse"),
    "negative"
  )
})

test_that("mnse errors when denominator is zero for constant obs", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "mnse"),
    "denominator is 0"
  )
})

test_that("wnse and wsnse error when denominator is zero for constant obs", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "wnse"),
    "denominator is 0"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "wsnse"),
    "denominator is 0"
  )
})

test_that("ubrmse is defined for equal constant series", {
  out <- evaluate_metrics(c(5, 5, 5), c(5, 5, 5), "ubrmse")
  expect_equal(out$value[[1]], 0)
})
