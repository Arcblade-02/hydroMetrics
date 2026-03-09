phase2_make_metric_spec <- function(...) {
  utils::modifyList(
    list(
      id = "phase2_metric",
      fun = function(sim, obs) 0,
      name = "Phase 2 Metric",
      description = "Phase 2 coverage helper metric",
      category = "other",
      perfect = 0,
      range = NULL,
      references = "Phase 2 reference",
      version_added = "0.1.0",
      tags = character()
    ),
    list(...)
  )
}

test_that("Phase 2 error-handling covers validation helpers", {
  expect_true(hydroMetrics:::validate_numeric_vector(c(1, 2), "sim"))
  expect_error(hydroMetrics:::validate_numeric_vector(c(1, 2), ""), "`name`")
  expect_error(hydroMetrics:::validate_numeric_vector("x", "sim"), "numeric vector")
  expect_error(hydroMetrics:::validate_numeric_vector(c(1, NA), "sim"), "must not contain NA")

  expect_true(hydroMetrics:::validate_equal_length(1:2, 3:4))
  expect_error(hydroMetrics:::validate_equal_length(1:2, 1:3), "same length")

  expect_true(hydroMetrics:::validate_finite(c(1, 2), c(3, 4)))
  expect_error(hydroMetrics:::validate_finite(c(NaN, 2), c(3, 4)), "must not contain NaN")
  expect_error(hydroMetrics:::validate_finite(c(Inf, 2), c(3, 4)), "must not contain infinite values")
  expect_true(hydroMetrics:::validate_finite(c(Inf, 2), c(3, 4), allow_inf = TRUE))
})

test_that("Phase 2 error-handling covers MetricRegistry branches", {
  registry <- hydroMetrics:::MetricRegistry$new()

  expect_true(is.data.frame(registry$list()))
  expect_equal(nrow(registry$list()), 0L)
  expect_error(registry$exists(""), "non-empty character scalar")
  expect_error(registry$get("missing"), "Unknown metric id")
  expect_error(registry$register("bad"), "must be a list")
  expect_error(registry$register(phase2_make_metric_spec(fun = "bad")), "must be a function")
  expect_error(registry$register(phase2_make_metric_spec(name = "")), "spec\\$name")
  expect_error(registry$register(phase2_make_metric_spec(description = "")), "spec\\$description")
  expect_error(registry$register(phase2_make_metric_spec(category = "bad")), "must be one of")
  expect_error(registry$register(phase2_make_metric_spec(perfect = NA_real_)), "spec\\$perfect")
  expect_error(registry$register(phase2_make_metric_spec(range = 1)), "spec\\$range")
  expect_error(registry$register(phase2_make_metric_spec(references = "")), "spec\\$references")
  expect_error(registry$register(phase2_make_metric_spec(version_added = "1")), "SemVer-like")
  expect_error(registry$register(phase2_make_metric_spec(tags = 1)), "spec\\$tags")

  spec_no_tags <- phase2_make_metric_spec(id = "phase2_no_tags", tags = NULL)
  validated <- registry$validate_spec(spec_no_tags)
  expect_identical(validated$tags, character())

  expect_invisible(registry$register(phase2_make_metric_spec(id = "phase2_ok")))
  expect_true(registry$exists("phase2_ok"))
  expect_equal(registry$get("phase2_ok")$name, "Phase 2 Metric")
  expect_gt(nrow(registry$list()), 0L)
  expect_error(registry$register(phase2_make_metric_spec(id = "phase2_ok")), "already registered")
})

test_that("Phase 2 error-handling covers HydroEngine and registry accessors", {
  registry <- hydroMetrics:::MetricRegistry$new()
  registry$register(phase2_make_metric_spec(id = "phase2_ok"))

  expect_error(hydroMetrics:::HydroEngine$new(list()), "MetricRegistry instance")

  engine <- hydroMetrics:::HydroEngine$new(registry)
  expect_true(engine$validate_inputs(c(1, 2), c(1, 2)))
  expect_equal(engine$normalize_metrics("phase2_ok")[[1]]$id, "phase2_ok")
  expect_error(engine$normalize_metrics(character()), "non-empty character vector")
  expect_error(engine$normalize_metrics(1), "non-empty character vector or metric-call list")
  expect_error(engine$normalize_metrics(list("bad")), "Each metric call must be a list")
  expect_error(engine$normalize_metrics(list(list(params = list()))), "non-empty character `id`")
  expect_error(engine$normalize_metrics(list(list(id = "phase2_ok", params = 1))), "must be a list")

  bad_registry <- hydroMetrics:::MetricRegistry$new()
  bad_registry$register(phase2_make_metric_spec(id = "phase2_bad", fun = function(sim, obs) NA_real_))
  bad_engine <- hydroMetrics:::HydroEngine$new(bad_registry)
  expect_error(bad_engine$evaluate(c(1, 2), c(1, 2), "phase2_bad"), "must return a non-missing numeric scalar")

  expect_error(hydroMetrics:::register_core_metrics(list()), "MetricRegistry instance")
  expect_s3_class(hydroMetrics:::.get_registry(), "MetricRegistry")
  expect_true("nse" %in% hydroMetrics:::list_metrics()$id)
  expect_equal(hydroMetrics:::get_metric("nse")$id, "nse")

  env <- getNamespace("hydroMetrics")
  rm(list = intersect(ls(envir = hydroMetrics:::.hm_state, all.names = TRUE), c("registry", "engine")), envir = hydroMetrics:::.hm_state)
  expect_s3_class(hydroMetrics:::.onLoad("", "hydroMetrics"), "MetricRegistry")
  expect_true(exists("registry", envir = hydroMetrics:::.hm_state, inherits = FALSE))
  expect_true(is.environment(env))
})

test_that("Phase 2 error-handling covers gof/preproc compatibility branches", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 2, 4)

  expect_error(gof(sim, obs, methods = "does_not_exist"), "Unknown metric")
  defaults <- gof(sim, obs, methods = "")
  expect_s3_class(defaults, "hydro_metrics")
  expect_true(all(c("NSE", "KGE", "rmse", "pbias", "mae", "mse", "R2", "VE", "rsr", "nrmse") %in% names(defaults$metrics)))
  expect_error(gof(sim, obs, methods = "NSE", metric_params = "bad"), "`metric_params` must be a list")
  expect_error(gof(sim, obs, methods = "NSE", metric_params = list(NSE = "bad")), "must be a list")
  expect_equal(gof(sim, obs, methods = "pfactor", metric_params = list(tol = 0.25))$pfactor, pfactor(sim, obs, tol = 0.25))
  expect_equal(gof(sim, obs, methods = "pfactor", metric_params = list(PFACTOR = list(tol = 0.25)))$pfactor, pfactor(sim, obs, tol = 0.25))
  expect_error(gof(sim, cbind(obs, obs), methods = "NSE"), "must both be single-series or both be matrix-like")
  expect_error(gof(cbind(sim, sim), cbind(obs, obs, obs), methods = "NSE"), "same dimensions")

  expect_error(preproc(sim, obs, na.rm = NA), "TRUE or FALSE")
  expect_error(preproc(sim, obs, keep = "bad"), "'arg' should be one of")
  expect_equal(preproc(c(1, NA, 3), c(1, 2, 3), keep = "complete")$n_removed_na, 1L)
  expect_equal(preproc(c(1, NA, 3), c(1, 2, 3), keep = "pairwise")$n_removed_na, 1L)
})

test_that("Phase 2 error-handling covers remaining metric error branches", {
  expect_error(hydroMetrics:::compute_rfactor(numeric(), numeric()), "requires at least 1 paired value")
  expect_error(hydroMetrics:::compute_rfactor(c(1, 2), c(0, 0)), "undefined")
  expect_error(hydroMetrics:::compute_pfactor(c(1, 2), c(1, 2), tol = -1), "non-negative numeric scalar")
  expect_error(hydroMetrics:::compute_pfactor(numeric(), numeric(), tol = 0.1), "requires at least 1 paired value")

  expect_error(hydroMetrics:::metric_beta(numeric(), numeric()), "beta requires at least 1 value")
  expect_error(hydroMetrics:::metric_kge(c(1, 1, 1), c(2, 2, 2)), "sd\\(obs\\) == 0")
  expect_error(hydroMetrics:::metric_rd(c(1, 2), c(0, 2)), "obs contains zero")
  expect_error(hydroMetrics:::metric_dr(c(1, 2), c(0, 2)), "obs contains zero")
  expect_error(hydroMetrics:::metric_br2(c(1, 1, 1), c(2, 2, 2)), "br2 undefined")
  expect_error(hydroMetrics:::metric_kgekm(c(1, 2), c(0, 0)), "KGEkm undefined")
  expect_error(hydroMetrics:::metric_kgelf(c(-1, 2), c(1, 2)), "negative values")
  expect_type(hydroMetrics:::metric_kgenp(c(1, 2, 3), c(1, 2, 4)), "double")
  expect_error(hydroMetrics:::metric_skge(c(1, 2, 3), c(1, 2, 3)), "monthly frequency")
  expect_type(hydroMetrics:::metric_pbiasfdc(c(1, 2, 3), c(1, 2, 4)), "double")

  skip_if_not_installed("zoo")
  idx <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
  sim <- c(12, 18, 33, 35)
  obs <- c(10, 20, 30, 40)
  expect_type(hydroMetrics:::metric_apfb(sim, obs, index = idx), "double")
  expect_type(hydroMetrics:::metric_hfb(sim, obs, threshold_prob = 0.25), "double")
})
