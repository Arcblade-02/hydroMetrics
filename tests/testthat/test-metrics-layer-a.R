if (!exists("gof", mode = "function")) {
  find_pkg_root <- function(path = getwd()) {
    current <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(current, "DESCRIPTION"))) {
        return(current)
      }

      parent <- dirname(current)
      if (identical(parent, current)) {
        stop("Could not locate package root for standalone Layer A tests.", call. = FALSE)
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

test_that("layer A batch A1 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("mdae", "maxae", "rbias", "ccc", "e1", "rrmse")

  expect_true(all(target %in% ids))
})

test_that("mdae and maxae match absolute-error summaries", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  abs_err <- abs(sim - obs)

  expect_equal(mdae(sim, obs), stats::median(abs_err))
  expect_equal(maxae(sim, obs), max(abs_err))

  out <- evaluate_metrics(sim, obs, c("mdae", "maxae"))
  values <- setNames(out$value, out$metric)
  expect_equal(values[["mdae"]], stats::median(abs_err))
  expect_equal(values[["maxae"]], max(abs_err))
})

test_that("mdae and maxae require at least one paired value", {
  expect_error(mdae(numeric(), numeric()), "At least 1 paired value is required after alignment")
  expect_error(maxae(numeric(), numeric()), "At least 1 paired value is required after alignment")
})

test_that("rbias matches mean paired relative bias", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- mean((sim - obs) / obs)

  expect_equal(rbias(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "rbias")$value[[1]], expected)
})

test_that("rbias errors when observed values contain zero", {
  expect_error(
    rbias(c(1, 2, 3), c(1, 0, 3)),
    "obs contains zero"
  )
})

test_that("ccc matches Lin concordance formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- (2 * stats::cov(sim, obs)) /
    (stats::var(sim) + stats::var(obs) + (mean(sim) - mean(obs))^2)

  expect_equal(ccc(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "ccc")$value[[1]], expected)
})

test_that("ccc handles constant identical series and short inputs deterministically", {
  expect_equal(ccc(c(2, 2), c(2, 2)), 1)
  expect_error(ccc(1, 1), "at least 2 values")
})

test_that("e1 matches Legates-McCabe absolute-efficiency formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- 1 - sum(abs(sim - obs)) / sum(abs(obs - mean(obs)))

  expect_equal(e1(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "e1")$value[[1]], expected)
})

test_that("e1 errors when the observed baseline denominator is zero", {
  expect_error(
    e1(c(1, 2, 3), c(2, 2, 2)),
    "sum\\(abs\\(obs - mean\\(obs\\)\\)\\) == 0"
  )
})

test_that("rrmse matches root mean squared relative error", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- sqrt(mean(((sim - obs) / obs)^2))

  expect_equal(rrmse(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "rrmse")$value[[1]], expected)
})

test_that("rrmse errors when observed values contain zero", {
  expect_error(
    rrmse(c(1, 2, 3), c(1, 0, 3)),
    "obs contains zero"
  )
})

test_that("layer A wrappers integrate with gof output", {
  sim <- cbind(a = c(1.2, 1.8, 3.4, 3.9, 5.1), b = c(1.0, 2.1, 2.9, 4.2, 5.0))
  obs <- cbind(a = c(1.0, 2.0, 3.0, 4.0, 5.0), b = c(1.0, 2.0, 3.0, 4.0, 5.0))

  out <- gof(sim, obs, methods = c("mdae", "ccc", "rrmse"))
  expect_true(is.matrix(out))
  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(rownames(out), c("mdae", "ccc", "rrmse"))
  expect_identical(colnames(out), c("a", "b"))
})

test_that("layer A batch A2 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("smape", "mare", "mrb", "log_rmse", "msle", "log_nse")

  expect_true(all(target %in% ids))
})

test_that("smape matches the symmetric percentage formula and handles 0/0 pairs", {
  sim <- c(0, 1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(0, 1.0, 2.0, 3.0, 4.0, 5.0)
  denom <- abs(sim) + abs(obs)
  expected_terms <- ifelse(denom == 0, 0, 200 * abs(sim - obs) / denom)
  expected <- mean(expected_terms)

  expect_equal(smape(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "smape")$value[[1]], expected)
})

test_that("mare and mrb match paired relative-error formulas", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  rel_err <- (sim - obs) / obs

  expect_equal(mare(sim, obs), mean(abs(rel_err)))
  expect_equal(mrb(sim, obs), 100 * mean(rel_err))

  out <- evaluate_metrics(sim, obs, c("mare", "mrb"))
  values <- setNames(out$value, out$metric)
  expect_equal(values[["mare"]], mean(abs(rel_err)))
  expect_equal(values[["mrb"]], 100 * mean(rel_err))
})

test_that("mare and mrb error when observed values contain zero", {
  expect_error(mare(c(1, 2, 3), c(1, 0, 3)), "obs contains zero")
  expect_error(mrb(c(1, 2, 3), c(1, 0, 3)), "obs contains zero")
})

test_that("log_rmse matches RMSE on logged positive values", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- sqrt(mean((log(sim) - log(obs))^2))

  expect_equal(log_rmse(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "log_rmse")$value[[1]], expected)
})

test_that("msle matches the log1p squared-error formula", {
  sim <- c(0, 1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(0, 1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- mean((log1p(sim) - log1p(obs))^2)

  expect_equal(msle(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "msle")$value[[1]], expected)
})

test_that("log_nse matches NSE on logged positive values", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  log_sim <- log(sim)
  log_obs <- log(obs)
  expected <- 1 - sum((log_sim - log_obs)^2) / sum((log_obs - mean(log_obs))^2)

  expect_equal(log_nse(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "log_nse")$value[[1]], expected)
})

test_that("log-domain metrics reject invalid values conservatively", {
  expect_error(log_rmse(c(1, 2, 3), c(0, 1, 2)), "non-positive values")
  expect_error(log_rmse(c(1, 2, 3), c(-1, 1, 2)), "non-positive values")
  expect_error(msle(c(1, 2, 3), c(-1, 1, 2)), "negative values")
  expect_error(log_nse(c(1, 2, 3), c(0, 1, 2)), "non-positive values")
  expect_error(log_nse(c(1, 2, 3), c(-1, 1, 2)), "non-positive values")
})

test_that("log_nse errors when logged observed variance is zero", {
  expect_error(
    log_nse(c(2, 2, 2), c(1, 1, 1)),
    "log\\(obs\\) has zero variance"
  )
})

.test_a3_fdc_prepare <- function(x) {
  list(
    flow = sort(as.numeric(x), decreasing = TRUE),
    exceedance = seq_along(x) / (length(x) + 1)
  )
}

.test_a3_fdc_interp <- function(x, probs) {
  stats::approx(
    x = x$exceedance,
    y = x$flow,
    xout = probs,
    rule = 2,
    ties = "ordered"
  )$y
}

test_that("layer A batch A3 registry ids are present", {
  ids <- list_metrics()$id
  target <- c(
    "nrmse_range",
    "fdc_slope_error",
    "fdc_highflow_bias",
    "fdc_lowflow_bias",
    "log_fdc_rmse",
    "low_flow_bias",
    "seasonal_bias"
  )

  expect_true(all(target %in% ids))
})

test_that("nrmse_range matches RMSE normalized by observed range", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- sqrt(mean((sim - obs)^2)) / diff(range(obs))

  expect_equal(nrmse_range(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "nrmse_range")$value[[1]], expected)
})

test_that("nrmse_range errors when the observed range is zero", {
  expect_error(
    nrmse_range(c(1, 2, 3), c(2, 2, 2)),
    "range\\(obs\\) == 0"
  )
})

test_that("Batch A3 FDC metrics follow the shared descending Weibull convention", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1, 9.3, 10.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0, 9.0, 10.1)
  sim_fdc <- .test_a3_fdc_prepare(sim)
  obs_fdc <- .test_a3_fdc_prepare(obs)

  sim_q <- .test_a3_fdc_interp(sim_fdc, c(0.2, 0.7))
  obs_q <- .test_a3_fdc_interp(obs_fdc, c(0.2, 0.7))
  expected_slope <- abs(100 * (
    abs(log(sim_q[[1L]]) - log(sim_q[[2L]])) -
      abs(log(obs_q[[1L]]) - log(obs_q[[2L]]))
  ) / abs(log(obs_q[[1L]]) - log(obs_q[[2L]])))

  n_high <- max(1L, ceiling(length(obs) * 0.02))
  expected_high <- 100 * sum(head(sim_fdc$flow, n_high) - head(obs_fdc$flow, n_high)) /
    sum(head(obs_fdc$flow, n_high))

  n_low <- max(2L, ceiling(length(obs) * 0.30))
  sim_low <- tail(sim_fdc$flow, n_low)
  obs_low <- tail(obs_fdc$flow, n_low)
  expected_low <- -100 * (
    sum(log(sim_low) - log(sim_low[[n_low]])) -
      sum(log(obs_low) - log(obs_low[[n_low]]))
  ) / sum(log(obs_low) - log(obs_low[[n_low]]))

  expected_log_rmse <- sqrt(mean((log(sim_fdc$flow) - log(obs_fdc$flow))^2))

  expect_equal(fdc_slope_error(sim, obs), expected_slope)
  expect_equal(fdc_highflow_bias(sim, obs), expected_high)
  expect_equal(fdc_lowflow_bias(sim, obs), expected_low)
  expect_equal(log_fdc_rmse(sim, obs), expected_log_rmse)

  out <- evaluate_metrics(
    sim,
    obs,
    c("fdc_slope_error", "fdc_highflow_bias", "fdc_lowflow_bias", "log_fdc_rmse")
  )
  values <- setNames(out$value, out$metric)
  expect_equal(values[["fdc_slope_error"]], expected_slope)
  expect_equal(values[["fdc_highflow_bias"]], expected_high)
  expect_equal(values[["fdc_lowflow_bias"]], expected_low)
  expect_equal(values[["log_fdc_rmse"]], expected_log_rmse)
})

test_that("Batch A3 FDC metrics are permutation-invariant after FDC construction", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1, 9.3, 10.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0, 9.0, 10.1)
  perm <- c(10, 3, 6, 1, 8, 2, 9, 4, 5, 7)
  fns <- list(fdc_slope_error, fdc_highflow_bias, fdc_lowflow_bias, log_fdc_rmse)

  for (fn in fns) {
    expect_equal(fn(sim, obs), fn(sim[perm], obs[perm]))
  }
})

test_that("Batch A3 FDC metrics reject invalid short or non-positive inputs", {
  expect_error(fdc_slope_error(c(1, 2), c(1, 2)), "at least 3 values")
  expect_error(fdc_slope_error(c(1, 2, 3), c(0, 1, 2)), "non-positive values")
  expect_error(fdc_lowflow_bias(c(1, 2, 3), c(0, 1, 2)), "non-positive values")
  expect_error(log_fdc_rmse(c(1, 2, 3), c(0, 1, 2)), "non-positive values")
})

test_that("low_flow_bias matches paired low-flow subset bias", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1, 9.3, 10.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0, 9.0, 10.1)
  q_low <- as.numeric(stats::quantile(obs, probs = 0.3, type = 7, names = FALSE))
  idx <- which(obs <= q_low)
  expected <- 100 * sum(sim[idx] - obs[idx]) / sum(obs[idx])

  expect_equal(low_flow_bias(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "low_flow_bias")$value[[1]], expected)
})

test_that("low_flow_bias errors when the observed low-flow subset sums to zero", {
  expect_error(
    low_flow_bias(c(1, 2, 3), c(0, 0, 4)),
    "low-flow subset sums to zero"
  )
})

test_that("seasonal_bias matches monthly climatology bias on monthly ts input", {
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
  expected <- 100 * mean((sim_month - obs_month) / obs_month)

  expect_equal(seasonal_bias(sim, obs), expected)
  out <- gof(sim, obs, methods = "seasonal_bias")
  expect_equal(unname(out[["seasonal_bias"]]), expected)
})

test_that("seasonal_bias rejects unsupported or incomplete seasonal structure", {
  expect_error(
    seasonal_bias(1:12, 1:12),
    "requires monthly ts input or an aligned date-like index"
  )

  skip_if_not_installed("zoo")
  idx <- as.Date(c(
    "2000-01-01", "2000-02-01", "2000-03-01", "2000-04-01", "2000-05-01", "2000-06-01",
    "2001-01-01", "2001-02-01", "2001-03-01", "2001-04-01", "2001-05-01", "2001-06-01"
  ))
  partial_sim <- zoo::zoo(rep(c(10, 11, 12, 13, 14, 15), 2), order.by = idx)
  partial_obs <- zoo::zoo(rep(c(9, 10, 11, 12, 13, 14), 2), order.by = idx)
  expect_error(
    seasonal_bias(partial_sim, partial_obs),
    "requires monthly ts input or an aligned date-like index"
  )
})

test_that("layer A batch A4 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("huber_loss", "quantile_loss", "trimmed_rmse", "winsor_rmse")

  expect_true(all(target %in% ids))
})

test_that("huber_loss matches the mean Huber loss formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0)
  delta <- 1
  residuals <- sim - obs
  expected <- mean(ifelse(
    abs(residuals) <= delta,
    0.5 * residuals^2,
    delta * (abs(residuals) - 0.5 * delta)
  ))

  expect_equal(huber_loss(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "huber_loss")$value[[1]], expected)
  expect_equal(huber_loss(sim, obs, delta = 0.25), metric_huber_loss(sim, obs, delta = 0.25))
})

test_that("quantile_loss matches the pinball-loss formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0)
  tau <- 0.5
  residuals <- obs - sim
  expected <- mean(ifelse(residuals >= 0, tau * residuals, (tau - 1) * residuals))

  expect_equal(quantile_loss(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "quantile_loss")$value[[1]], expected)
  expect_equal(quantile_loss(sim, obs, tau = 0.25), metric_quantile_loss(sim, obs, tau = 0.25))
})

test_that("trimmed_rmse and winsor_rmse match deterministic robust residual rules", {
  sim <- c(0, 2, 4, 6, 20)
  obs <- c(1, 2, 3, 4, 5)
  residuals <- sort(sim - obs)
  trim <- 0.2
  winsor <- 0.2
  k_trim <- floor(trim * length(residuals))
  trimmed <- residuals[(k_trim + 1):(length(residuals) - k_trim)]
  expected_trimmed <- sqrt(mean(trimmed^2))

  k_winsor <- floor(winsor * length(residuals))
  lower <- residuals[[k_winsor + 1]]
  upper <- residuals[[length(residuals) - k_winsor]]
  wins <- pmin(pmax(residuals, lower), upper)
  expected_winsor <- sqrt(mean(wins^2))

  expect_equal(trimmed_rmse(sim, obs), expected_trimmed)
  expect_equal(winsor_rmse(sim, obs), expected_winsor)

  out <- evaluate_metrics(sim, obs, c("trimmed_rmse", "winsor_rmse"))
  values <- setNames(out$value, out$metric)
  expect_equal(values[["trimmed_rmse"]], expected_trimmed)
  expect_equal(values[["winsor_rmse"]], expected_winsor)
})

test_that("trimmed_rmse and winsor_rmse reduce to RMSE when trim fractions are zero", {
  sim <- c(0, 2, 4, 6, 20)
  obs <- c(1, 2, 3, 4, 5)
  expected <- sqrt(mean((sim - obs)^2))

  expect_equal(trimmed_rmse(sim, obs, trim = 0), expected)
  expect_equal(winsor_rmse(sim, obs, winsor = 0), expected)
})

test_that("Batch A4 parameter validation is explicit and conservative", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1, 2, 3, 4, 5)

  expect_error(huber_loss(sim, obs, delta = 0), "`delta` must be a positive")
  expect_error(quantile_loss(sim, obs, tau = 1), "`tau` must be a numeric scalar in \\(0, 1\\)")
  expect_error(trimmed_rmse(sim, obs, trim = 0.6), "`trim` must be a numeric scalar in \\[0, 0.5\\)")
  expect_error(winsor_rmse(sim, obs, winsor = -0.1), "`winsor` must be a numeric scalar in \\[0, 0.5\\)")
})

test_that("Batch A4 wrappers integrate with metric_params for multi-series input", {
  sim <- cbind(a = c(0, 2, 4, 6, 20), b = c(1, 2, 3, 4, 5))
  obs <- cbind(a = c(1, 2, 3, 4, 5), b = c(1, 2, 3, 4, 5))

  out <- huber_loss(sim, obs, delta = 0.5)
  expect_true(is.numeric(out))
  expect_identical(names(out), c("a", "b"))

  out_trim <- trimmed_rmse(sim, obs, trim = 0.2)
  expect_true(is.numeric(out_trim))
  expect_identical(names(out_trim), c("a", "b"))
})

test_that("layer A batch A5 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("crps", "picp", "mwpi", "skill_score")

  expect_true(all(target %in% ids))
})

test_that("crps matches the empirical ensemble formula", {
  ens <- matrix(
    c(
      1.0, 1.2, 0.8,
      2.0, 2.2, 1.8,
      3.0, 3.2, 2.8
    ),
    nrow = 3,
    byrow = TRUE
  )
  obs <- c(1.1, 2.1, 3.1)

  expected_case <- vapply(seq_len(nrow(ens)), function(i) {
    members <- ens[i, ]
    mean(abs(members - obs[[i]])) - sum(abs(outer(members, members, "-"))) / (2 * ncol(ens)^2)
  }, numeric(1))
  expected <- mean(expected_case)

  expect_equal(crps(ens, obs), expected)
  expect_equal(metric_crps(ens, obs), expected)
})

test_that("picp and mwpi match interval coverage and width definitions", {
  lower <- c(0.9, 1.9, 2.9)
  upper <- c(1.3, 2.3, 3.3)
  obs <- c(1.1, 2.4, 3.1)

  expect_equal(picp(lower, upper, obs), mean(obs >= lower & obs <= upper))
  expect_equal(mwpi(lower, upper), mean(upper - lower))
  expect_equal(metric_picp(lower, obs, upper = upper), mean(obs >= lower & obs <= upper))
  expect_equal(metric_mwpi(lower, upper), mean(upper - lower))
})

test_that("skill_score matches lower-is-better baseline normalization", {
  score <- c(0.8, 0.7, 0.9)
  baseline <- c(1.0, 1.0, 1.0)
  expected <- 1 - mean(score) / mean(baseline)

  expect_equal(skill_score(score, baseline), expected)
  expect_equal(metric_skill_score(score, baseline), expected)
})

test_that("A5 input contracts reject unsupported structures", {
  ens_bad <- matrix(c(1, 2, 3), nrow = 3)
  obs <- c(1, 2, 3)

  expect_error(crps(ens_bad, obs), "at least 2 ensemble members")
  expect_error(crps(c(1, 2, 3), obs), "numeric matrix")
  expect_error(picp(c(2, 1), c(1, 2), c(1.5, 1.5)), "`lower` must be less than or equal to `upper`")
  expect_error(mwpi(c(2, 1), c(1, 2)), "`lower` must be less than or equal to `upper`")
  expect_error(skill_score(score = 1, baseline_score = 0), "mean\\(baseline_score\\) == 0")
})

test_that("A5 contracts reject mismatched lengths and invalid score inputs", {
  ens <- matrix(c(1, 2, 3, 2, 3, 4), nrow = 2, byrow = TRUE)

  expect_error(crps(ens, c(1)), "must match `nrow\\(sim\\)`")
  expect_error(picp(c(0, 1), c(1, 2), c(0.5)), "same length")
  expect_error(mwpi(c(0, 1), c(1)), "same length")
  expect_error(skill_score(score = c(-1, 1), baseline_score = c(1, 1)), "must be non-negative")
})
