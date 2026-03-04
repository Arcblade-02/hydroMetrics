test_that("gof returns hydro_metrics object for single series", {
  out <- gof(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = c("NSE", "rmse", "rPearson")
  )

  expect_s3_class(out, "hydro_metrics")
  expect_true(is.numeric(out$metrics))
  expect_true(all(c("NSE", "rmse", "rPearson") %in% names(out$metrics)))
  expect_identical(out$NSE, out$metrics[["NSE"]])
  expect_equal(as.numeric(out), as.numeric(out$metrics))
})

test_that("gof supports zoo alignment and method subsets", {
  skip_if_not_installed("zoo")

  sim <- zoo::zoo(c(1, 2, 3), order.by = as.Date("2020-01-01") + 0:2)
  obs <- zoo::zoo(c(1, 2, 4), order.by = as.Date("2020-01-02") + 0:2)

  out <- gof(sim = sim, obs = obs, methods = c("NSE", "rmse"), na_strategy = "fail")
  expect_equal(names(out$metrics), c("NSE", "rmse"))
  expect_identical(out$n_obs, 2L)
})

test_that("gof returns method x model metrics matrix for multi-series input", {
  sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs <- cbind(a = c(1, 2, 1), b = c(2, 2, 3))

  out <- gof(sim = sim, obs = obs, methods = c("rmse", "pbias"))

  expect_true(is.matrix(out$metrics))
  expect_identical(rownames(out$metrics), c("rmse", "pbias"))
  expect_identical(colnames(out$metrics), c("a", "b"))
  expect_true(is.numeric(out$rmse))
  expect_equal(length(out$n_obs), 2L)
})

test_that("gof errors for unknown method names with available list hint", {
  expect_error(
    gof(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = "not_a_metric"),
    "available"
  )
})

test_that("gof stores orchestration meta fields", {
  out <- gof(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = "rmse",
    components = TRUE,
    na_strategy = "remove",
    transform = "none",
    epsilon_mode = "constant"
  )

  expect_identical(out$meta$na_strategy, "remove")
  expect_identical(out$meta$transform, "none")
  expect_identical(out$meta$epsilon_mode, "constant")
  expect_identical(out$meta$components, TRUE)
})
