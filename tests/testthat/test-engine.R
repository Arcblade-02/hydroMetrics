test_that("cannot register duplicate metric id", {
  expect_error(
    register_metric(
      id = "mse",
      fun = function(sim, obs) mean((sim - obs)^2),
      name = "Duplicate MSE",
      description = "Duplicate registration test"
    ),
    "already registered"
  )
})

test_that("registry spec validation errors on missing required fields", {
  registry <- hydroMetrics:::MetricRegistry$new()

  expect_error(
    registry$register(list(
      id = "bad_metric",
      fun = function(sim, obs) 0,
      name = "Bad Metric"
    )),
    "Missing required field"
  )
})

test_that("engine errors on unequal vector lengths", {
  expect_error(
    evaluate_metrics(sim = c(1, 2, 3), obs = c(1, 2), metrics = "mse"),
    "same length"
  )
})

test_that("engine returns expected output structure", {
  out <- evaluate_metrics(sim = c(1, 2, 3), obs = c(1, 2, 1), metrics = "mse")

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric[[1]], "mse")
})

test_that("mse placeholder computes textbook formula", {
  out <- evaluate_metrics(sim = c(1, 2, 3), obs = c(1, 2, 1), metrics = "mse")
  expect_equal(out$value[[1]], 4 / 3)
})
