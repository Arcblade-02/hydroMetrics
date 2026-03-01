test_that("registry schema validation fails on missing required fields", {
  registry <- hydroMetrics:::MetricRegistry$new()

  expect_error(
    registry$register(list(
      id = "bad",
      fun = function(sim, obs) 0,
      name = "Bad Metric"
    )),
    "Missing required field"
  )
})

test_that("registry schema validation fails on invalid category", {
  registry <- hydroMetrics:::MetricRegistry$new()

  bad_spec <- list(
    id = "bad_category",
    fun = function(sim, obs) 0,
    name = "Bad Category",
    description = "Invalid category test",
    category = "invalid",
    perfect = 0,
    range = NULL,
    references = "Test reference",
    version_added = "0.1.0",
    tags = character()
  )

  expect_error(registry$register(bad_spec), "must be one of")
})

test_that("cannot register duplicate metric id", {
  expect_error(
    register_metric(
      id = "nse",
      fun = function(sim, obs) 0,
      name = "Duplicate NSE",
      description = "Duplicate registration test"
    ),
    "already registered"
  )
})

test_that("engine errors on unequal vector lengths", {
  expect_error(
    evaluate_metrics(sim = c(1, 2, 3), obs = c(1, 2), metrics = "nse"),
    "same length"
  )
})

test_that("engine returns expected hm_result structure", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("nse", "rmse", "pbias")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("nse", "rmse", "pbias"))
})

test_that("perfect-case values are correct for core metrics", {
  out <- evaluate_metrics(
    sim = c(2, 4, 6),
    obs = c(2, 4, 6),
    metrics = c("nse", "rmse", "pbias")
  )
  values <- setNames(out$value, out$metric)

  expect_equal(values[["nse"]], 1)
  expect_equal(values[["rmse"]], 0)
  expect_equal(values[["pbias"]], 0)
})

test_that("core metrics return expected values on simple vectors", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("nse", "rmse", "pbias")
  )
  values <- setNames(out$value, out$metric)

  expect_equal(values[["nse"]], -5)
  expect_equal(values[["rmse"]], sqrt(4 / 3))
  expect_equal(values[["pbias"]], 50)
})
