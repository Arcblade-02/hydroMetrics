.ensure_metric_params_fixture <- function() {
  metric_id <- "test_metric_params"
  if (.get_registry()$exists(metric_id)) {
    return(metric_id)
  }

  register_metric(
    id = metric_id,
    fun = function(sim, obs, w = 1, q = 0) {
      w * mean(sim - obs) + q
    },
    name = "Test Metric Params",
    description = "Test-only metric validating parameter injection."
  )

  metric_id
}

test_that("gof injects metric parameters via metric_params", {
  metric_id <- .ensure_metric_params_fixture()
  sim <- c(2, 4, 6)
  obs <- c(1, 2, 3)

  out <- gof(
    sim = sim,
    obs = obs,
    methods = metric_id,
    metric_params = list(
      test_metric_params = list(w = 2, q = 3)
    )
  )

  expect_equal(out[[metric_id]], 2 * mean(sim - obs) + 3)
})

test_that("engine supports normalized metric calls with params", {
  metric_id <- .ensure_metric_params_fixture()
  sim <- c(5, 7, 9)
  obs <- c(2, 4, 6)

  out <- .get_engine()$evaluate(
    sim = sim,
    obs = obs,
    metrics = list(
      list(id = metric_id, params = list(w = 0.5, q = 1))
    )
  )

  expect_equal(out$value[[1]], 0.5 * mean(sim - obs) + 1)
})

test_that("metrics without params are unaffected by metric call normalization", {
  sim <- c(1, 2, 3)
  obs <- c(1, 1, 2)

  out <- gof(
    sim = sim,
    obs = obs,
    methods = c("rmse", "nse"),
    metric_params = list(
      nse = list()
    )
  )

  ref <- evaluate_metrics(sim = sim, obs = obs, metrics = c("rmse", "nse"))
  expect_equal(out[["rmse"]], ref$value[[1]])
  expect_equal(out[["nse"]], ref$value[[2]])
})
