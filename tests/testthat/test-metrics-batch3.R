test_that("batch3 metrics return expected hm_result structure and ids", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("kge", "rsr", "mape", "mpe", "ve", "nrmse_sd")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("kge", "rsr", "mape", "mpe", "ve", "nrmse_sd"))
})

test_that("batch3 perfect-fit case returns expected values", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 3),
    metrics = c("kge", "rsr", "mape", "mpe", "ve", "nrmse_sd")
  )
  values <- setNames(out$value, out$metric)

  expect_equal(values[["kge"]], 1)
  expect_equal(values[["rsr"]], 0)
  expect_equal(values[["mape"]], 0)
  expect_equal(values[["mpe"]], 0)
  expect_equal(values[["ve"]], 1)
  expect_equal(values[["nrmse_sd"]], 0)
})

test_that("batch3 metrics match inline formula computations", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  rmse <- sqrt(mean((sim - obs)^2))
  r <- stats::cor(sim, obs)
  alpha <- stats::sd(sim) / stats::sd(obs)
  beta <- mean(sim) / mean(obs)

  out <- evaluate_metrics(sim, obs, c("kge", "rsr", "mape", "mpe", "ve", "nrmse_sd"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["kge"]], 1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2))
  expect_equal(values[["rsr"]], rmse / stats::sd(obs))
  expect_equal(values[["mape"]], 100 * mean(abs((sim - obs) / obs)))
  expect_equal(values[["mpe"]], 100 * mean((sim - obs) / obs))
  expect_equal(values[["ve"]], 1 - sum(abs(sim - obs)) / sum(obs))
  expect_equal(values[["nrmse_sd"]], rmse / stats::sd(obs))
})

test_that("mape and mpe error when obs contains zero", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, 0, 2), "mape"),
    "obs contains zero"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(1, 0, 2), "mpe"),
    "obs contains zero"
  )
})

test_that("kge errors on invalid observed moments", {
  expect_error(
    evaluate_metrics(c(1, 2), c(-1, 1), "kge"),
    "mean\\(obs\\) == 0"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "kge"),
    "sd\\(obs\\) == 0|constant"
  )
})

test_that("rsr and nrmse_sd error when sd(obs) is zero", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "rsr"),
    "sd\\(obs\\) is zero|sd\\(obs\\) == 0"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "nrmse_sd"),
    "sd\\(obs\\) == 0"
  )
})

test_that("ve errors when sum(obs) is zero", {
  expect_error(
    evaluate_metrics(c(1, 2), c(-1, 1), "ve"),
    "sum\\(obs\\) == 0"
  )
})
