metric_mdae <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("mdae requires at least 1 value.", call. = FALSE)
  }

  stats::median(abs(sim - obs))
}

core_metric_spec_mdae <- function() {
  list(
    id = "mdae",
    fun = metric_mdae,
    name = "Median Absolute Error",
    description = "Median absolute deviation between sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "NIST/SEMATECH e-Handbook of Statistical Methods; robust absolute-error summary.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_maxae <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("maxae requires at least 1 value.", call. = FALSE)
  }

  max(abs(sim - obs))
}

core_metric_spec_maxae <- function() {
  list(
    id = "maxae",
    fun = metric_maxae,
    name = "Maximum Absolute Error",
    description = "Maximum absolute deviation between sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "NIST/SEMATECH e-Handbook of Statistical Methods; absolute-error summary statistics.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_rbias <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rbias is undefined because obs contains zero.", call. = FALSE)
  }

  mean((sim - obs) / obs)
}

core_metric_spec_rbias <- function() {
  list(
    id = "rbias",
    fun = metric_rbias,
    name = "Relative Bias",
    description = "Mean paired relative bias computed as mean((sim - obs) / obs).",
    category = "bias",
    perfect = 0,
    range = c(-Inf, Inf),
    references = "Relative-error model-evaluation family described by Hwang et al. (2012).",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_ccc <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("ccc requires at least 2 values.", call. = FALSE)
  }

  var_sim <- stats::var(sim)
  var_obs <- stats::var(obs)
  mean_diff_sq <- (mean(sim) - mean(obs))^2
  denom <- var_sim + var_obs + mean_diff_sq

  if (denom == 0) {
    return(1)
  }

  (2 * stats::cov(sim, obs)) / denom
}

core_metric_spec_ccc <- function() {
  list(
    id = "ccc",
    fun = metric_ccc,
    name = "Concordance Correlation Coefficient",
    description = "Lin's concordance correlation coefficient for agreement between sim and obs.",
    category = "agreement",
    perfect = 1,
    range = c(-1, 1),
    references = "Lin, L.I.-K. (1989). A concordance correlation coefficient to evaluate reproducibility.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_e1 <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("e1 requires at least 1 value.", call. = FALSE)
  }

  denom <- sum(abs(obs - mean(obs)))
  if (denom == 0) {
    stop("e1 is undefined because sum(abs(obs - mean(obs))) == 0.", call. = FALSE)
  }

  1 - sum(abs(sim - obs)) / denom
}

core_metric_spec_e1 <- function() {
  list(
    id = "e1",
    fun = metric_e1,
    name = "Modified Coefficient of Efficiency",
    description = "Legates-McCabe absolute-error efficiency statistic.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Legates, D.R. & McCabe, G.J. (1999). Evaluating the use of goodness-of-fit measures in hydrologic and hydroclimatic model validation.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_rrmse <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rrmse is undefined because obs contains zero.", call. = FALSE)
  }

  sqrt(mean(((sim - obs) / obs)^2))
}

core_metric_spec_rrmse <- function() {
  list(
    id = "rrmse",
    fun = metric_rrmse,
    name = "Relative Root Mean Squared Error",
    description = "Root mean squared paired relative error computed as sqrt(mean(((sim - obs) / obs)^2)).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Relative-error model-evaluation family described by Hwang et al. (2012).",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_smape <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("smape requires at least 1 value.", call. = FALSE)
  }

  denom <- abs(sim) + abs(obs)
  terms <- numeric(length(denom))
  nz <- denom != 0
  terms[nz] <- 200 * abs(sim[nz] - obs[nz]) / denom[nz]
  mean(terms)
}

core_metric_spec_smape <- function() {
  list(
    id = "smape",
    fun = metric_smape,
    name = "Symmetric Mean Absolute Percentage Error",
    description = "sMAPE computed as mean(200 * abs(sim - obs) / (abs(sim) + abs(obs))) with 0/0 pairs contributing 0.",
    category = "error",
    perfect = 0,
    range = c(0, 200),
    references = "Makridakis (1993) and Goodwin & Lawton (1999) on sMAPE and its interpretation.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a2")
  )
}

metric_mare <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("mare is undefined because obs contains zero.", call. = FALSE)
  }

  mean(abs((sim - obs) / obs))
}

core_metric_spec_mare <- function() {
  list(
    id = "mare",
    fun = metric_mare,
    name = "Mean Absolute Relative Error",
    description = "Mean absolute paired relative error computed as mean(abs((sim - obs) / obs)).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Relative-error criteria as used in regional hydrological hazard evaluation literature.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a2")
  )
}

metric_mrb <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("mrb is undefined because obs contains zero.", call. = FALSE)
  }

  100 * mean((sim - obs) / obs)
}

core_metric_spec_mrb <- function() {
  list(
    id = "mrb",
    fun = metric_mrb,
    name = "Mean Relative Bias",
    description = "Mean paired relative bias in percent computed as 100 * mean((sim - obs) / obs).",
    category = "bias",
    perfect = 0,
    range = c(-Inf, Inf),
    references = "Relative-bias criteria as used in regional hydrological hazard evaluation literature.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a2")
  )
}

metric_log_rmse <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("log_rmse requires at least 1 value.", call. = FALSE)
  }
  if (any(sim <= 0) || any(obs <= 0)) {
    stop("log_rmse is undefined for non-positive values.", call. = FALSE)
  }

  sqrt(mean((log(sim) - log(obs))^2))
}

core_metric_spec_log_rmse <- function() {
  list(
    id = "log_rmse",
    fun = metric_log_rmse,
    name = "Log-Transformed RMSE",
    description = "RMSE computed on log-transformed positive sim and obs values.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Log-transformed hydrological objective functions discussed by Krause et al. (2005).",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a2")
  )
}

metric_msle <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("msle requires at least 1 value.", call. = FALSE)
  }
  if (any(sim < 0) || any(obs < 0)) {
    stop("msle is undefined for negative values.", call. = FALSE)
  }

  mean((log1p(sim) - log1p(obs))^2)
}

core_metric_spec_msle <- function() {
  list(
    id = "msle",
    fun = metric_msle,
    name = "Mean Squared Logarithmic Error",
    description = "MSLE computed as mean((log1p(sim) - log1p(obs))^2) for non-negative inputs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Hodson (2021) and Hodson et al. (2021) on MSLE in streamflow prediction benchmarking.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a2")
  )
}

metric_log_nse <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("log_nse requires at least 1 value.", call. = FALSE)
  }
  if (any(sim <= 0) || any(obs <= 0)) {
    stop("log_nse is undefined for non-positive values.", call. = FALSE)
  }

  log_sim <- log(sim)
  log_obs <- log(obs)
  denom <- sum((log_obs - mean(log_obs))^2)

  if (denom == 0) {
    stop("log_nse is undefined because log(obs) has zero variance.", call. = FALSE)
  }

  1 - sum((log_sim - log_obs)^2) / denom
}

core_metric_spec_log_nse <- function() {
  list(
    id = "log_nse",
    fun = metric_log_nse,
    name = "Log-Transformed Nash-Sutcliffe Efficiency",
    description = "NSE computed on log-transformed positive sim and obs values to emphasize low flows.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Log-transformed NSE use in hydrological model assessment discussed by Krause et al. (2005).",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a2")
  )
}

# Shared Batch A3 FDC convention:
# flows are sorted in descending order and paired with Weibull exceedance
# probabilities p_i = i / (n + 1). Windowed FDC diagnostics use this single
# construction throughout the batch.
.hm_fdc_prepare <- function(x) {
  if (length(x) < 1L) {
    stop("FDC metrics require at least 1 value.", call. = FALSE)
  }

  list(
    flow = sort(as.numeric(x), decreasing = TRUE),
    exceedance = seq_along(x) / (length(x) + 1)
  )
}

.hm_fdc_interp <- function(fdc, probs) {
  stats::approx(
    x = fdc$exceedance,
    y = fdc$flow,
    xout = probs,
    rule = 2,
    ties = "ordered"
  )$y
}

.hm_fdc_segment_count <- function(n, fraction, min_count = 1L) {
  max(as.integer(min_count), as.integer(ceiling(n * fraction)))
}

metric_nrmse_range <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("nrmse_range requires at least 1 value.", call. = FALSE)
  }

  obs_range <- diff(range(obs))
  if (obs_range == 0) {
    stop("nrmse_range is undefined because range(obs) == 0.", call. = FALSE)
  }

  metric_rmse(sim, obs) / obs_range
}

core_metric_spec_nrmse_range <- function() {
  list(
    id = "nrmse_range",
    fun = metric_nrmse_range,
    name = "Range-Normalized RMSE",
    description = "RMSE normalized by the observed range max(obs) - min(obs).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Pontius et al. (2008) and related normalized-RMSE comparison literature.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a3")
  )
}

metric_fdc_slope_error <- function(sim, obs) {
  if (length(obs) < 3L) {
    stop("fdc_slope_error requires at least 3 values.", call. = FALSE)
  }
  if (any(sim <= 0) || any(obs <= 0)) {
    stop("fdc_slope_error is undefined for non-positive values.", call. = FALSE)
  }

  sim_fdc <- .hm_fdc_prepare(sim)
  obs_fdc <- .hm_fdc_prepare(obs)
  sim_q <- .hm_fdc_interp(sim_fdc, c(0.2, 0.7))
  obs_q <- .hm_fdc_interp(obs_fdc, c(0.2, 0.7))
  sim_slope <- abs(log(sim_q[[1L]]) - log(sim_q[[2L]]))
  obs_slope <- abs(log(obs_q[[1L]]) - log(obs_q[[2L]]))

  if (obs_slope == 0) {
    stop("fdc_slope_error is undefined because the observed FDC middle slope is zero.", call. = FALSE)
  }

  abs(100 * (sim_slope - obs_slope) / obs_slope)
}

core_metric_spec_fdc_slope_error <- function() {
  list(
    id = "fdc_slope_error",
    fun = metric_fdc_slope_error,
    name = "FDC Middle-Slope Error",
    description = "Absolute percent error in the middle flow-duration-curve slope between 20% and 70% exceedance on log flow.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Yilmaz et al. (2008) middle-slope diagnostic (BiasFMS), reported here as an absolute error under the package FDC convention.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a3")
  )
}

metric_fdc_highflow_bias <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("fdc_highflow_bias requires at least 1 value.", call. = FALSE)
  }

  sim_fdc <- .hm_fdc_prepare(sim)
  obs_fdc <- .hm_fdc_prepare(obs)
  n_high <- .hm_fdc_segment_count(length(obs), fraction = 0.02, min_count = 1L)
  obs_high <- obs_fdc$flow[seq_len(n_high)]
  sim_high <- sim_fdc$flow[seq_len(n_high)]
  denom <- sum(obs_high)

  if (denom == 0) {
    stop("fdc_highflow_bias is undefined because the observed high-flow segment sums to zero.", call. = FALSE)
  }

  100 * sum(sim_high - obs_high) / denom
}

core_metric_spec_fdc_highflow_bias <- function() {
  list(
    id = "fdc_highflow_bias",
    fun = metric_fdc_highflow_bias,
    name = "FDC High-Flow Bias",
    description = "Percent bias in the upper 2% of the descending flow-duration curve.",
    category = "bias",
    perfect = 0,
    range = c(-Inf, Inf),
    references = "Yilmaz et al. (2008) high-flow volume diagnostic (BiasFHV).",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a3")
  )
}

metric_fdc_lowflow_bias <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("fdc_lowflow_bias requires at least 2 values.", call. = FALSE)
  }

  sim_fdc <- .hm_fdc_prepare(sim)
  obs_fdc <- .hm_fdc_prepare(obs)
  n_low <- .hm_fdc_segment_count(length(obs), fraction = 0.30, min_count = 2L)
  sim_low <- utils::tail(sim_fdc$flow, n_low)
  obs_low <- utils::tail(obs_fdc$flow, n_low)

  if (any(sim_low <= 0) || any(obs_low <= 0)) {
    stop("fdc_lowflow_bias is undefined for non-positive values in the low-flow segment.", call. = FALSE)
  }

  sim_terms <- log(sim_low) - log(sim_low[[n_low]])
  obs_terms <- log(obs_low) - log(obs_low[[n_low]])
  denom <- sum(obs_terms)

  if (denom == 0) {
    stop("fdc_lowflow_bias is undefined because the observed low-flow segment is not estimable.", call. = FALSE)
  }

  -100 * (sum(sim_terms) - sum(obs_terms)) / denom
}

core_metric_spec_fdc_lowflow_bias <- function() {
  list(
    id = "fdc_lowflow_bias",
    fun = metric_fdc_lowflow_bias,
    name = "FDC Low-Flow Bias",
    description = "Percent bias in the lower 30% of the descending flow-duration curve on log flow.",
    category = "bias",
    perfect = 0,
    range = c(-Inf, Inf),
    references = "Yilmaz et al. (2008) low-flow diagnostic (BiasFLV).",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a3")
  )
}

metric_log_fdc_rmse <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("log_fdc_rmse requires at least 1 value.", call. = FALSE)
  }
  if (any(sim <= 0) || any(obs <= 0)) {
    stop("log_fdc_rmse is undefined for non-positive values.", call. = FALSE)
  }

  sim_fdc <- .hm_fdc_prepare(sim)
  obs_fdc <- .hm_fdc_prepare(obs)
  sqrt(mean((log(sim_fdc$flow) - log(obs_fdc$flow))^2))
}

core_metric_spec_log_fdc_rmse <- function() {
  list(
    id = "log_fdc_rmse",
    fun = metric_log_fdc_rmse,
    name = "Log FDC RMSE",
    description = "RMSE between descending flow-duration curves computed on log-transformed positive flows.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Searcy (1959) flow-duration-curve construction with log-error emphasis following low-flow objective-function practice discussed by Krause et al. (2005).",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a3")
  )
}

metric_low_flow_bias <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("low_flow_bias requires at least 1 value.", call. = FALSE)
  }

  q_low <- as.numeric(stats::quantile(obs, probs = 0.3, type = 7, names = FALSE))
  idx <- which(obs <= q_low)
  if (length(idx) == 0L) {
    stop("low_flow_bias is undefined because the observed low-flow subset is empty.", call. = FALSE)
  }

  denom <- sum(obs[idx])
  if (denom == 0) {
    stop("low_flow_bias is undefined because the observed low-flow subset sums to zero.", call. = FALSE)
  }

  100 * sum(sim[idx] - obs[idx]) / denom
}

core_metric_spec_low_flow_bias <- function() {
  list(
    id = "low_flow_bias",
    fun = metric_low_flow_bias,
    name = "Low-Flow Bias",
    description = "Percent bias over the observed lower-30% flow subset defined from paired observations.",
    category = "bias",
    perfect = 0,
    range = c(-Inf, Inf),
    references = "Yilmaz et al. (2008) low-flow diagnostic context, applied here to the paired observed lower-30% subset.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a3")
  )
}

.hm_validate_huber_delta <- function(delta) {
  if (!is.numeric(delta) || length(delta) != 1L || is.na(delta) || delta <= 0) {
    stop("`delta` must be a positive numeric scalar.", call. = FALSE)
  }

  as.numeric(delta)
}

.hm_validate_quantile_tau <- function(tau) {
  if (!is.numeric(tau) || length(tau) != 1L || is.na(tau) || tau <= 0 || tau >= 1) {
    stop("`tau` must be a numeric scalar in (0, 1).", call. = FALSE)
  }

  as.numeric(tau)
}

.hm_validate_fraction_01 <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 0 || x >= 0.5) {
    stop(sprintf("`%s` must be a numeric scalar in [0, 0.5).", name), call. = FALSE)
  }

  as.numeric(x)
}

.hm_trimmed_residuals <- function(sim, obs, trim) {
  residuals <- sort(as.numeric(sim - obs))
  n <- length(residuals)
  k <- floor(trim * n)

  if (k == 0L) {
    return(residuals)
  }

  residuals[seq.int(k + 1L, n - k)]
}

.hm_winsorized_residuals <- function(sim, obs, winsor) {
  residuals <- sort(as.numeric(sim - obs))
  n <- length(residuals)
  k <- floor(winsor * n)

  if (k == 0L) {
    return(residuals)
  }

  lower <- residuals[[k + 1L]]
  upper <- residuals[[n - k]]
  pmin(pmax(residuals, lower), upper)
}

metric_huber_loss <- function(sim, obs, delta = 1) {
  if (length(obs) < 1L) {
    stop("huber_loss requires at least 1 value.", call. = FALSE)
  }

  delta <- .hm_validate_huber_delta(delta)
  residuals <- sim - obs
  abs_residuals <- abs(residuals)
  quadratic <- 0.5 * residuals^2
  linear <- delta * (abs_residuals - 0.5 * delta)

  mean(ifelse(abs_residuals <= delta, quadratic, linear))
}

core_metric_spec_huber_loss <- function() {
  list(
    id = "huber_loss",
    fun = metric_huber_loss,
    name = "Mean Huber Loss",
    description = "Mean Huber loss with stable default delta = 1.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Huber (1964) robust loss with package default delta = 1.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a4")
  )
}

metric_quantile_loss <- function(sim, obs, tau = 0.5) {
  if (length(obs) < 1L) {
    stop("quantile_loss requires at least 1 value.", call. = FALSE)
  }

  tau <- .hm_validate_quantile_tau(tau)
  residuals <- obs - sim

  mean(ifelse(residuals >= 0, tau * residuals, (tau - 1) * residuals))
}

core_metric_spec_quantile_loss <- function() {
  list(
    id = "quantile_loss",
    fun = metric_quantile_loss,
    name = "Mean Quantile Loss",
    description = "Mean pinball loss on obs - sim residuals with stable default tau = 0.5.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Koenker & Bassett (1978) quantile loss with package default tau = 0.5.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a4")
  )
}

metric_trimmed_rmse <- function(sim, obs, trim = 0.2) {
  if (length(obs) < 1L) {
    stop("trimmed_rmse requires at least 1 value.", call. = FALSE)
  }

  trim <- .hm_validate_fraction_01(trim, "trim")
  residuals <- .hm_trimmed_residuals(sim, obs, trim = trim)

  sqrt(mean(residuals^2))
}

core_metric_spec_trimmed_rmse <- function() {
  list(
    id = "trimmed_rmse",
    fun = metric_trimmed_rmse,
    name = "Trimmed RMSE",
    description = "RMSE after symmetric trimming of the signed residual distribution with stable default trim = 0.2.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Robust trimmed-estimation practice summarized by Wilcox (2012), adapted here to residual RMSE with package default trim = 0.2.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a4")
  )
}

metric_winsor_rmse <- function(sim, obs, winsor = 0.2) {
  if (length(obs) < 1L) {
    stop("winsor_rmse requires at least 1 value.", call. = FALSE)
  }

  winsor <- .hm_validate_fraction_01(winsor, "winsor")
  residuals <- .hm_winsorized_residuals(sim, obs, winsor = winsor)

  sqrt(mean(residuals^2))
}

core_metric_spec_winsor_rmse <- function() {
  list(
    id = "winsor_rmse",
    fun = metric_winsor_rmse,
    name = "Winsorized RMSE",
    description = "RMSE after symmetric winsorization of the signed residual distribution with stable default winsor = 0.2.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Robust winsorization practice summarized by Wilcox (2012), adapted here to residual RMSE with package default winsor = 0.2.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-a", "batch-a4")
  )
}
