test_that("Phase 2 normalization paths verify NRMSE public contract", {
  sim <- c(1, 2, 4)
  obs <- c(1, 2, 3)

  expect_equal(
    NRMSE(sim, obs, norm = "mean"),
    sqrt(mean((sim - obs)^2)) / mean(obs)
  )
  expect_error(NRMSE(sim, obs, norm = "sd"), "Phase 2 supports")
  expect_error(NRMSE(sim, obs, norm = "range"), "Phase 2 supports")
})

test_that("Phase 2 normalization paths cover epsilon alias handling through preproc and gof", {
  log_out <- preproc(
    c(0, 2, 3),
    c(1, 2, 3),
    transform = "log",
    epsilon.type = "otherValue",
    epsilon.value = 0.5
  )
  rec_out <- preproc(
    c(0, 2, 4),
    c(1, 2, 4),
    transform = "reciprocal",
    epsilon.type = "otherFactor",
    epsilon.value = 0.5
  )
  gof_out <- gof(
    c(0, 2, 4),
    c(1, 2, 4),
    methods = "rmse",
    transform = "log",
    epsilon.type = "auto_min_positive",
    epsilon.value = 1
  )

  expect_true(all(is.finite(log_out$sim)))
  expect_true(log_out$epsilon_details$applied)
  expect_true(all(is.finite(rec_out$sim)))
  expect_equal(gof_out$meta$epsilon_mode, "auto_min_positive")

  expect_error(preproc(c(0, 2), c(1, 2), transform = "log", epsilon.value = NA_real_), "non-missing numeric scalar")
  expect_error(gof(c(1, 2), c(1, 2), methods = "NSE", epsilon.type = "invalid"), "must be one of")
  expect_error(gof(c(1, 2), c(1, 2), methods = "NSE", epsilon.type = "otherValue", epsilon_mode = "obs_mean_factor"), "conflicts")
  expect_error(gof(c(1, 2), c(1, 2), methods = "NSE", epsilon.type = "otherValue", epsilon = 1, epsilon.value = 2), "conflicts")
  expect_error(gof(c(1, 2), c(1, 2), methods = "NSE", epsilon.type = "otherFactor", epsilon_factor = 1, epsilon.value = 2), "conflicts")
})

test_that("Phase 2 normalization paths cover internal numeric conversion and transform helpers", {
  expect_equal(hydroMetrics:::.hm_as_numeric_vector(ts(c(1, 2, 3), frequency = 12), "sim"), c(1, 2, 3))
  expect_error(hydroMetrics:::.hm_as_numeric_vector(ts(cbind(1:3, 4:6), frequency = 12), "sim"), "univariate ts")
  expect_error(hydroMetrics:::.hm_as_numeric_vector(list(1, 2, 3), "sim"), "must be numeric, ts, zoo, or xts")

  skip_if_not_installed("zoo")
  bad_zoo <- zoo::zoo(as.character(c("a", "b")), order.by = as.Date("2021-01-01") + 0:1)
  multi_zoo <- zoo::zoo(cbind(1:2, 3:4), order.by = as.Date("2021-01-01") + 0:1)
  expect_error(hydroMetrics:::.hm_as_numeric_vector(bad_zoo, "sim"), "`sim` must be numeric")
  expect_error(hydroMetrics:::.hm_as_numeric_vector(multi_zoo, "sim"), "univariate zoo/xts")

  expect_equal(hydroMetrics:::.hm_compute_epsilon(c(1, 2), c(2, 3), "obs_mean_factor", NULL, 0.5), mean(c(2, 3)) * 0.5)
  expect_error(hydroMetrics:::.hm_compute_epsilon(c(1, 2), c(2, 3), "constant", NULL, 1), "must be provided")
  expect_error(hydroMetrics:::.hm_compute_epsilon(c(1, 2), c(2, 3), "constant", NA_real_, 1), "non-missing numeric scalar")
  expect_error(hydroMetrics:::.hm_compute_epsilon(c(-1, 0), c(-2, 0), "auto_min_positive", NULL, 1), "No positive values available")

  expect_equal(hydroMetrics:::.hm_apply_transform(c(1, 4), c(1, 9), "sqrt", "constant", NULL, 1)$obs, c(1, 3))
  expect_equal(hydroMetrics:::.hm_apply_transform(c(1, 2), c(2, 4), "reciprocal", "constant", NULL, 1)$sim, c(1, 0.5))
  expect_error(hydroMetrics:::.hm_apply_transform(c(-2, 2), c(2, 4), "sqrt", "constant", 1, 1), "sqrt transform requires")
  expect_error(hydroMetrics:::.hm_apply_transform(c(0, 2), c(2, 4), "log", "constant", NULL, 1), "`epsilon` must be provided")
  expect_error(hydroMetrics:::.hm_apply_transform(c(0, 2), c(2, 4), "reciprocal", "constant", Inf, 1), "must be finite")
})

test_that("Phase 2 normalization paths cover indexed alignment helpers", {
  skip_if_not_installed("zoo")

  date_keys <- as.Date("2021-01-01") + 0:1
  expect_equal(hydroMetrics:::.hm_index_key(date_keys), c("2021-01-01", "2021-01-02"))

  posix_keys <- as.POSIXct(c("2021-01-01 00:00:00", "2021-01-01 00:00:01"), tz = "UTC")
  expect_equal(length(hydroMetrics:::.hm_index_key(posix_keys)), 2L)

  sim <- zoo::zoo(c(1, 2), order.by = as.Date("2021-01-01") + 0:1)
  obs <- zoo::zoo(c(3, 4), order.by = as.Date("2021-02-01") + 0:1)
  out <- hydroMetrics:::.hm_align_indexed_series(sim, obs)
  expect_length(out$sim, 0)
  expect_length(out$index, 0)

  dup_sim <- suppressWarnings(zoo::zoo(c(1, 2), order.by = as.Date(c("2021-01-01", "2021-01-01"))))
  expect_error(hydroMetrics:::.hm_align_indexed_series(dup_sim, obs), "unique time index")
})
