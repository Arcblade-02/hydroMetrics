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

test_that("public wrappers and orchestration entry points expose compatibility formals", {
  wrapper_fns <- c("alpha", "APFB", "beta", "HFB", "mae", "mNSeff", "NSeff", "pbias", "r", "rNSeff", "rsr", "valindex", "wsNSeff")
  for (fn_name in wrapper_fns) {
    expect_true("na.rm" %in% names(formals(get(fn_name, envir = asNamespace("hydroMetrics")))))
  }

  expect_true(all(c("fun", "na.rm", "keep", "epsilon.type", "epsilon.value") %in% names(formals(gof))))
  expect_true(all(c("fun", "na.rm", "keep", "epsilon.type", "epsilon.value") %in% names(formals(ggof))))
  expect_true(all(c("na.rm", "keep", "epsilon.type", "epsilon.value") %in% names(formals(preproc))))
})

test_that("gof supports formal compatibility aliases without changing results", {
  sim <- c(0, 1, 2, 3)
  obs <- c(1, 2, 2, 4)

  out_alias <- gof(
    sim = sim,
    obs = obs,
    fun = "rmse",
    transform = "log",
    epsilon.type = "constant",
    epsilon.value = 0.5
  )
  out_native <- gof(
    sim = sim,
    obs = obs,
    methods = "rmse",
    transform = "log",
    epsilon_mode = "constant",
    epsilon = 0.5
  )

  expect_equal(out_alias$metrics, out_native$metrics)
  expect_identical(names(out_alias$metrics), "rmse")
})
