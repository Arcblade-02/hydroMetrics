test_that("gof default usage matches v0.1.0 behavior", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 2, 4)

  out <- gof(sim = sim, obs = obs, methods = c("NSE", "rmse", "pbias"))
  ref <- evaluate_metrics(sim = sim, obs = obs, metrics = c("nse", "rmse", "pbias"))
  expected <- setNames(as.numeric(ref$value), c("NSE", "rmse", "pbias"))

  expect_equal(out$metrics, expected)
  expect_equal(out$NSE, expected[["NSE"]])
})

test_that("gof default NA behavior still fails when na.rm is not enabled", {
  expect_error(
    gof(
      sim = c(1, NA, 3),
      obs = c(1, 2, 3),
      methods = "rmse"
    ),
    "Missing values found"
  )
})

test_that("gof preserves na.rm compatibility mapping to na_strategy", {
  sim <- c(1, NA, 3, 4)
  obs <- c(1, 2, 3, 5)

  out_old <- gof(sim = sim, obs = obs, methods = "rmse", na.rm = TRUE)
  out_new <- gof(sim = sim, obs = obs, methods = "rmse", na_strategy = "remove")

  expect_equal(out_old$metrics, out_new$metrics)
})
