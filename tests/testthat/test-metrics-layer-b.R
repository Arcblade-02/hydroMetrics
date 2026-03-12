if (!exists("gof", mode = "function")) {
  find_pkg_root <- function(path = getwd()) {
    current <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(current, "DESCRIPTION"))) {
        return(current)
      }

      parent <- dirname(current)
      if (identical(parent, current)) {
        stop("Could not locate package root for standalone Layer B tests.", call. = FALSE)
      }
      current <- parent
    }
  }

  pkg_root <- find_pkg_root()
  file_env <- environment()
  for (path in list.files(file.path(pkg_root, "R"), pattern = "\\.[Rr]$", full.names = TRUE)) {
    sys.source(path, envir = file_env)
  }
}

.test_b1_union_support <- function(sim, obs) {
  sort(unique(c(sim, obs)))
}

test_that("layer B batch B1 registry ids are present", {
  ids <- list_metrics()$id
  target <- c(
    "ks_statistic",
    "cdf_rmse",
    "quantile_deviation",
    "fdc_shape_distance",
    "anderson_darling_stat",
    "wasserstein_distance"
  )

  expect_true(all(target %in% ids))
})

test_that("layer B batch B2 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("sqrt_nse", "seasonal_nse", "weighted_kge", "quantile_kge")

  expect_true(all(target %in% ids))
})

test_that("ks_statistic matches the two-sample empirical KS gap", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  grid <- .test_b1_union_support(sim, obs)
  expected <- max(abs(stats::ecdf(sim)(grid) - stats::ecdf(obs)(grid)))

  expect_equal(ks_statistic(sim, obs), expected)
  expect_equal(metric_ks_statistic(sim, obs), expected)
  expect_equal(ks_statistic(sim, obs), as.numeric(stats::ks.test(sim, obs)$statistic))
})

test_that("cdf_rmse matches pooled-support empirical CDF RMSE", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  grid <- .test_b1_union_support(sim, obs)
  expected <- sqrt(mean((stats::ecdf(sim)(grid) - stats::ecdf(obs)(grid))^2))

  expect_equal(cdf_rmse(sim, obs), expected)
  expect_equal(metric_cdf_rmse(sim, obs), expected)
})

test_that("quantile_deviation matches fixed-grid quantile RMSE", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1, 2, 4, 5, 6)
  probs <- seq(0.1, 0.9, by = 0.1)
  expected <- sqrt(mean((
    stats::quantile(sim, probs = probs, type = 7, names = FALSE) -
      stats::quantile(obs, probs = probs, type = 7, names = FALSE)
  )^2))

  expect_equal(quantile_deviation(sim, obs), expected)
  expect_equal(metric_quantile_deviation(sim, obs), expected)
})

test_that("fdc_shape_distance matches range-normalized descending FDC RMSE", {
  sim <- c(1, 2, 4, 6, 8)
  obs <- c(2, 3, 5, 7, 9)
  sim_norm <- (sort(sim, decreasing = TRUE) - min(sim)) / diff(range(sim))
  obs_norm <- (sort(obs, decreasing = TRUE) - min(obs)) / diff(range(obs))
  expected <- sqrt(mean((sim_norm - obs_norm)^2))

  expect_equal(fdc_shape_distance(sim, obs), expected)
  expect_equal(metric_fdc_shape_distance(sim, obs), expected)
})

test_that("anderson_darling_stat matches pooled-grid tail-weighted EDF distance", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  grid <- .test_b1_union_support(sim, obs)
  sim_cdf <- stats::ecdf(sim)(grid)
  obs_cdf <- stats::ecdf(obs)(grid)
  pooled_counts <- vapply(grid, function(value) {
    sum(sim == value) + sum(obs == value)
  }, numeric(1))
  dH <- pooled_counts / (length(sim) + length(obs))
  H <- (length(sim) * sim_cdf + length(obs) * obs_cdf) / (length(sim) + length(obs))
  valid <- H > 0 & H < 1
  expected <- sum(((sim_cdf[valid] - obs_cdf[valid])^2 / (H[valid] * (1 - H[valid]))) * dH[valid])

  expect_equal(anderson_darling_stat(sim, obs), expected)
  expect_equal(metric_anderson_darling_stat(sim, obs), expected)
})

test_that("wasserstein_distance matches equal-weight quantile coupling", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  expected <- mean(abs(sort(sim) - sort(obs)))

  expect_equal(wasserstein_distance(sim, obs), expected)
  expect_equal(metric_wasserstein_distance(sim, obs), expected)
})

test_that("layer B metrics return zero on identical samples where appropriate", {
  same <- c(2, 2, 2, 2, 2)

  expect_equal(ks_statistic(same, same), 0)
  expect_equal(cdf_rmse(same, same), 0)
  expect_equal(quantile_deviation(same, same), 0)
  expect_equal(anderson_darling_stat(same, same), 0)
  expect_equal(wasserstein_distance(same, same), 0)
})

test_that("fdc_shape_distance rejects zero-range series conservatively", {
  same <- c(2, 2, 2, 2, 2)

  expect_error(
    fdc_shape_distance(same, same),
    "range\\(sim\\) == 0"
  )
})

test_that("layer B wrappers integrate with gof for deterministic metrics", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1, 9.3, 10.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0, 9.0, 10.1)
  out <- gof(
    sim,
    obs,
    methods = c(
      "ks_statistic",
      "cdf_rmse",
      "quantile_deviation",
      "fdc_shape_distance",
      "anderson_darling_stat",
      "wasserstein_distance"
    )
  )

  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(
    names(out),
    c(
      "ks_statistic",
      "cdf_rmse",
      "quantile_deviation",
      "fdc_shape_distance",
      "anderson_darling_stat",
      "wasserstein_distance"
    )
  )
})

test_that("layer B metrics detect simple distribution shifts monotonically", {
  base <- c(1, 2, 3, 4, 5)
  shifted <- base + 1

  expect_gt(ks_statistic(base, shifted), 0)
  expect_gt(cdf_rmse(base, shifted), 0)
  expect_gt(quantile_deviation(base, shifted), 0)
  expect_gt(anderson_darling_stat(base, shifted), 0)
  expect_gt(wasserstein_distance(base, shifted), 0)
})

test_that("sqrt_nse matches NSE on square-root transformed series", {
  sim <- c(1, 4, 9, 16)
  obs <- c(1, 4, 16, 25)
  sim_sqrt <- sqrt(sim)
  obs_sqrt <- sqrt(obs)
  expected <- 1 - sum((sim_sqrt - obs_sqrt)^2) / sum((obs_sqrt - mean(obs_sqrt))^2)

  expect_equal(sqrt_nse(sim, obs), expected)
  expect_equal(metric_sqrt_nse(sim, obs), expected)
  expect_equal(sqrt_nse(obs, obs), 1)
})

test_that("sqrt_nse rejects negative inputs explicitly", {
  expect_error(
    sqrt_nse(c(-1, 2, 3), c(1, 2, 3)),
    "undefined for negative values"
  )
})

test_that("seasonal_nse matches NSE on monthly climatology means", {
  sim <- ts(
    c(10, 12, 9, 8, 7, 6, 5, 6, 7, 8, 9, 11,
      10, 12, 9, 8, 7, 6, 5, 6, 7, 8, 9, 11),
    frequency = 12
  )
  obs <- ts(
    c(9, 11, 10, 8, 6, 6, 5, 5, 8, 8, 10, 10,
      9, 11, 10, 8, 6, 6, 5, 5, 8, 8, 10, 10),
    frequency = 12
  )
  sim_month <- tapply(as.numeric(sim), stats::cycle(sim), mean)
  obs_month <- tapply(as.numeric(obs), stats::cycle(obs), mean)
  expected <- 1 - sum((sim_month - obs_month)^2) / sum((obs_month - mean(obs_month))^2)

  expect_equal(seasonal_nse(sim, obs), expected)
  expect_equal(metric_seasonal_nse(as.numeric(sim), as.numeric(obs), index = stats::time(obs)), expected)

  out <- gof(sim, obs, methods = "seasonal_nse")
  expect_equal(unname(out[["seasonal_nse"]]), expected)
})

test_that("seasonal_nse rejects unsupported seasonal structure", {
  expect_error(
    seasonal_nse(1:12, 1:12),
    "requires monthly ts input or an aligned date-like index"
  )
})

test_that("weighted_kge matches the explicit weighted KGE formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2)
  w_r <- 2
  w_alpha <- 0.5
  w_beta <- 1.5
  r <- metric_r(sim, obs)
  alpha <- metric_alpha(sim, obs)
  beta <- metric_beta(sim, obs)
  expected <- 1 - sqrt((w_r * (r - 1))^2 + (w_alpha * (alpha - 1))^2 + (w_beta * (beta - 1))^2)

  expect_equal(weighted_kge(sim, obs, w_r = w_r, w_alpha = w_alpha, w_beta = w_beta), expected)
  expect_equal(metric_weighted_kge(sim, obs, w_r = w_r, w_alpha = w_alpha, w_beta = w_beta), expected)
  expect_equal(weighted_kge(obs, obs), 1)
})

test_that("weighted_kge rejects invalid weights explicitly", {
  expect_error(
    weighted_kge(c(1, 2, 3), c(1, 2, 3), w_r = 0),
    "`w_r` must be a positive finite numeric scalar"
  )
  expect_error(
    weighted_kge(c(1, 2, 3), c(1, 2, 3), w_alpha = NA_real_),
    "`w_alpha` must be a positive finite numeric scalar"
  )
})

test_that("quantile_kge matches KGE on fixed-grid sample quantiles", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1, 9.3, 10.0, 10.8, 11.4)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0, 9.0, 10.1, 10.5, 11.0)
  probs <- seq(0.1, 0.9, by = 0.1)
  sim_q <- stats::quantile(sim, probs = probs, type = 7, names = FALSE)
  obs_q <- stats::quantile(obs, probs = probs, type = 7, names = FALSE)
  expected <- 1 - sqrt(
    (stats::cor(sim_q, obs_q) - 1)^2 +
      (stats::sd(sim_q) / stats::sd(obs_q) - 1)^2 +
      (mean(sim_q) / mean(obs_q) - 1)^2
  )

  expect_equal(quantile_kge(sim, obs), expected)
  expect_equal(metric_quantile_kge(sim, obs), expected)
  expect_equal(quantile_kge(obs, obs), 1)
})

test_that("quantile_kge rejects too-short or degenerate inputs", {
  expect_error(
    quantile_kge(c(1, 2), c(1, 2)),
    "requires at least 3 values"
  )
  expect_error(
    quantile_kge(c(1, 2, 3), c(2, 2, 2)),
    "quantile\\(obs\\) has zero variance"
  )
})

test_that("layer B batch B2 wrappers integrate with gof extended policy", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1, 9.3, 10.0, 10.8, 11.4)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0, 9.0, 10.1, 10.5, 11.0)
  out_plain <- gof(sim, obs, extended = TRUE)

  expect_true(all(c("sqrt_nse", "weighted_kge", "quantile_kge") %in% names(out_plain)))
  expect_false("seasonal_nse" %in% names(out_plain))

  sim_ts <- ts(
    c(10, 12, 9, 8, 7, 6, 5, 6, 7, 8, 9, 11,
      10, 12, 9, 8, 7, 6, 5, 6, 7, 8, 9, 11),
    frequency = 12
  )
  obs_ts <- ts(
    c(9, 11, 10, 8, 6, 6, 5, 5, 8, 8, 10, 10,
      9, 11, 10, 8, 6, 6, 5, 5, 8, 8, 10, 10),
    frequency = 12
  )
  out_ts <- gof(sim_ts, obs_ts, extended = TRUE)

  expect_true("seasonal_nse" %in% names(out_ts))
})

test_that("layer B batch B3 registry ids are present", {
  ids <- list_metrics()$id
  target <- c(
    "hydrograph_slope_error",
    "derivative_nse",
    "peak_timing_error",
    "rising_limb_error",
    "recession_constant",
    "baseflow_index_error"
  )

  expect_true(all(target %in% ids))
})

test_that("hydrograph_slope_error matches RMSE on ordered first differences", {
  sim <- c(1, 2, 4, 7, 6, 5, 4, 3, 2, 1)
  obs <- c(1, 2, 3, 6, 7, 6, 5, 4, 2, 1)
  expected <- sqrt(mean((diff(sim) - diff(obs))^2))

  expect_equal(hydrograph_slope_error(sim, obs), expected)
  expect_equal(metric_hydrograph_slope_error(sim, obs), expected)
  expect_equal(hydrograph_slope_error(obs, obs), 0)
})

test_that("derivative_nse matches NSE on first differences", {
  sim <- c(1, 2, 4, 7, 6)
  obs <- c(1, 2, 3, 6, 5)
  dsim <- diff(sim)
  dobs <- diff(obs)
  expected <- 1 - sum((dsim - dobs)^2) / sum((dobs - mean(dobs))^2)

  expect_equal(derivative_nse(sim, obs), expected)
  expect_equal(metric_derivative_nse(sim, obs), expected)
  expect_equal(derivative_nse(obs, obs), 1)
})

test_that("peak_timing_error uses the first peak occurrence deterministically", {
  sim <- c(1, 3, 5, 5, 4)
  obs <- c(1, 2, 4, 6, 6)

  expect_equal(peak_timing_error(sim, obs), 1)
  expect_equal(metric_peak_timing_error(sim, obs), 1)
  expect_equal(peak_timing_error(obs, obs), 0)
})

test_that("rising_limb_error matches RMSE on observed rising-limb intervals", {
  sim <- c(1, 2, 4, 7, 6, 5, 4, 3, 2, 1)
  obs <- c(1, 2, 3, 6, 7, 6, 5, 4, 2, 1)
  idx <- which(diff(obs)[seq_len(which.max(obs) - 1L)] > 0)
  expected <- sqrt(mean((diff(sim)[idx] - diff(obs)[idx])^2))

  expect_equal(rising_limb_error(sim, obs), expected)
  expect_equal(metric_rising_limb_error(sim, obs), expected)
  expect_equal(rising_limb_error(obs, obs), 0)
})

test_that("recession_constant matches the observed-segment log-recession fit difference", {
  sim <- c(1, 2, 4, 8, 6, 4, 2)
  obs <- c(1, 2, 4, 8, 5, 3, 2)
  idx <- 4:7
  time_idx <- seq_along(idx) - 1
  k_sim <- -coef(stats::lm(log(sim[idx]) ~ time_idx))[["time_idx"]]
  k_obs <- -coef(stats::lm(log(obs[idx]) ~ time_idx))[["time_idx"]]
  expected <- abs(k_sim - k_obs)

  expect_equal(recession_constant(sim, obs), expected)
  expect_equal(metric_recession_constant(sim, obs), expected)
  expect_equal(recession_constant(obs, obs), 0)
})

test_that("baseflow_index_error matches the fixed three-pass BFI proxy difference", {
  sim <- c(1, 2, 4, 8, 6, 4, 2)
  obs <- c(1, 2, 4, 8, 5, 3, 2)
  expected <- abs(
    .hm_b3_baseflow_index_proxy(sim, "baseflow_index_error") -
      .hm_b3_baseflow_index_proxy(obs, "baseflow_index_error")
  )

  expect_equal(baseflow_index_error(sim, obs), expected)
  expect_equal(metric_baseflow_index_error(sim, obs), expected)
  expect_equal(baseflow_index_error(obs, obs), 0)
})

test_that("layer B batch B3 metrics reject invalid temporal edge cases", {
  expect_error(
    hydrograph_slope_error(c(1), c(1)),
    "requires at least 2 values"
  )
  expect_error(
    derivative_nse(c(1, 1), c(1, 1)),
    "requires at least 3 values"
  )
  expect_error(
    rising_limb_error(c(5, 4, 3), c(5, 4, 3)),
    "first time step|no rising-limb intervals"
  )
  expect_error(
    recession_constant(c(1, 0, -1), c(1, 0, -1)),
    "positive points"
  )
  expect_error(
    baseflow_index_error(c(1, 1), c(1, 1)),
    "requires at least 3 values"
  )
})

test_that("layer B batch B3 wrappers integrate with gof for ordered series metrics", {
  sim <- c(1, 2, 4, 7, 6, 5, 4, 3, 2, 1)
  obs <- c(1, 2, 3, 6, 7, 6, 5, 4, 2, 1)
  out <- gof(
    sim,
    obs,
    methods = c(
      "hydrograph_slope_error",
      "derivative_nse",
      "peak_timing_error",
      "rising_limb_error",
      "recession_constant",
      "baseflow_index_error"
    )
  )

  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(
    names(out),
    c(
      "hydrograph_slope_error",
      "derivative_nse",
      "peak_timing_error",
      "rising_limb_error",
      "recession_constant",
      "baseflow_index_error"
    )
  )
})

test_that("layer B batch B4 registry id is present", {
  ids <- list_metrics()$id
  expect_true("event_nse" %in% ids)
})

test_that("event_nse matches NSE on pooled observed event windows", {
  obs <- c(1, 2, 5, 6, 2, 1, 1, 4, 5, 2, 1, 1)
  sim <- c(1, 2, 4, 7, 2, 1, 1, 3, 6, 2, 1, 1)
  idx <- c(3, 4, 9)
  expected <- 1 - sum((sim[idx] - obs[idx])^2) / sum((obs[idx] - mean(obs[idx]))^2)

  expect_equal(event_nse(sim, obs), expected)
  expect_equal(metric_event_nse(sim, obs), expected)
})

test_that("event_nse reaches the optimum on identical valid event windows", {
  obs <- c(1, 2, 5, 6, 2, 1, 1, 4, 5, 2, 1, 1)

  expect_equal(event_nse(obs, obs), 1)
})

test_that("event_nse rejects no-event, too-few-event, and degenerate cases", {
  expect_error(
    event_nse(c(1, 2, 3, 4), c(1, 1, 1, 1)),
    "no event windows"
  )
  expect_error(
    event_nse(c(1, 2, 5, 6, 2, 1), c(1, 2, 5, 6, 2, 1)),
    "at least 2 observed event windows"
  )
  expect_error(
    event_nse(c(1, 5, 1, 1, 1, 1, 1, 5, 1, 1), c(1, 5, 1, 1, 1, 1, 1, 5, 1, 1)),
    "at least 3 observations"
  )
  expect_error(
    event_nse(
      c(1, 5, 1, 1, 1, 1, 5, 1, 1, 1, 1, 5, 1, 1, 1),
      c(1, 5, 1, 1, 1, 1, 5, 1, 1, 1, 1, 5, 1, 1, 1)
    ),
    "zero variance"
  )
})

test_that("event_nse accepts ordered numeric vectors as time order", {
  obs <- c(1, 2, 5, 6, 2, 1, 1, 4, 5, 2, 1, 1)
  sim <- c(1, 2, 4, 7, 2, 1, 1, 3, 6, 2, 1, 1)

  expect_true(is.numeric(event_nse(sim, obs)))
  expect_length(event_nse(sim, obs), 1L)
})

test_that("event_nse integrates with gof when event windows are auto-applicable", {
  obs <- c(1, 2, 5, 6, 2, 1, 1, 4, 5, 2, 1, 1)
  sim <- c(1, 2, 4, 7, 2, 1, 1, 3, 6, 2, 1, 1)
  out <- gof(sim, obs, methods = "event_nse")

  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(names(out), "event_nse")
  expect_equal(unname(out[["event_nse"]]), event_nse(sim, obs))
})
