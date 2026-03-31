validate_distribution_vector <- function(x, name) {
  validate_numeric_vector(x, name)
  validate_finite(x, x)

  if (length(x) < 1L) {
    stop(sprintf("%s requires at least 1 value.", name), call. = FALSE)
  }

  invisible(TRUE)
}

# Shared Batch B1 empirical-distribution convention:
# - support comparisons use the ascending union support grid of sim and obs
# - empirical CDFs are right-continuous step functions evaluated on that grid
# - quantile comparisons use fixed probabilities p = 0.1, 0.2, ..., 0.9 with
#   stats::quantile(..., type = 7)
# - Wasserstein distance uses equal-weight empirical quantile coupling for the
#   paired aligned sample size already established by package preprocessing

.hm_b1_union_support <- function(sim, obs) {
  sort(unique(c(as.numeric(sim), as.numeric(obs))))
}

.hm_b1_ecdf_values <- function(x, grid) {
  stats::ecdf(as.numeric(x))(grid)
}

.hm_b1_fixed_prob_grid <- function() {
  seq(0.1, 0.9, by = 0.1)
}

.hm_b1_fdc_normalize <- function(x, name) {
  x <- as.numeric(x)
  x_range <- diff(range(x))
  if (!is.finite(x_range) || x_range == 0) {
    stop(sprintf("%s is undefined because range(%s) == 0.", name, name), call. = FALSE)
  }

  (sort(x, decreasing = TRUE) - min(x)) / x_range
}

.hm_b1_anderson_darling_weights <- function(sim, obs, grid) {
  n <- length(sim)
  m <- length(obs)
  pooled_counts <- vapply(grid, function(value) {
    sum(sim == value) + sum(obs == value)
  }, numeric(1))
  pooled_cdf <- (n * .hm_b1_ecdf_values(sim, grid) + m * .hm_b1_ecdf_values(obs, grid)) / (n + m)

  list(
    dH = pooled_counts / (n + m),
    H = pooled_cdf
  )
}

metric_ks_statistic <- function(sim, obs) {
  validate_distribution_vector(sim, "ks_statistic")
  validate_distribution_vector(obs, "ks_statistic")

  grid <- .hm_b1_union_support(sim, obs)
  max(abs(.hm_b1_ecdf_values(sim, grid) - .hm_b1_ecdf_values(obs, grid)))
}

core_metric_spec_ks_statistic <- function() {
  list(
    id = "ks_statistic",
    fun = metric_ks_statistic,
    name = "Kolmogorov-Smirnov Statistic",
    description = "Maximum absolute gap between the empirical CDFs of sim and obs on the pooled support grid.",
    category = "agreement",
    perfect = 0,
    range = c(0, 1),
    references = "Nikiforov (1994) exact Smirnov two-sample test context; package metric reports the two-sample empirical KS distance only.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_cdf_rmse <- function(sim, obs) {
  validate_distribution_vector(sim, "cdf_rmse")
  validate_distribution_vector(obs, "cdf_rmse")

  grid <- .hm_b1_union_support(sim, obs)
  diff_cdf <- .hm_b1_ecdf_values(sim, grid) - .hm_b1_ecdf_values(obs, grid)
  sqrt(mean(diff_cdf^2))
}

core_metric_spec_cdf_rmse <- function() {
  list(
    id = "cdf_rmse",
    fun = metric_cdf_rmse,
    name = "CDF RMSE",
    description = "Package-defined RMSE between empirical CDFs of sim and obs evaluated on the pooled support grid.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Package-defined empirical-distribution comparison grounded in Smirnov-type EDF distances; the metric uses RMSE over the pooled support grid.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_quantile_deviation <- function(sim, obs) {
  validate_distribution_vector(sim, "quantile_deviation")
  validate_distribution_vector(obs, "quantile_deviation")

  probs <- .hm_b1_fixed_prob_grid()
  sim_q <- stats::quantile(sim, probs = probs, type = 7, names = FALSE)
  obs_q <- stats::quantile(obs, probs = probs, type = 7, names = FALSE)

  sqrt(mean((sim_q - obs_q)^2))
}

core_metric_spec_quantile_deviation <- function() {
  list(
    id = "quantile_deviation",
    fun = metric_quantile_deviation,
    name = "Quantile Deviation",
    description = "RMSE between type-7 sample quantiles on the fixed probability grid p = 0.1, ..., 0.9.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Hyndman & Fan (1996) sample-quantile conventions; package metric uses a fixed p = 0.1..0.9 quantile RMSE.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_anderson_darling_stat <- function(sim, obs) {
  validate_distribution_vector(sim, "anderson_darling_stat")
  validate_distribution_vector(obs, "anderson_darling_stat")

  grid <- .hm_b1_union_support(sim, obs)
  sim_cdf <- .hm_b1_ecdf_values(sim, grid)
  obs_cdf <- .hm_b1_ecdf_values(obs, grid)
  weights <- .hm_b1_anderson_darling_weights(sim, obs, grid)
  valid <- weights$H > 0 & weights$H < 1

  if (!any(valid)) {
    return(0)
  }

  sum(((sim_cdf[valid] - obs_cdf[valid])^2 / (weights$H[valid] * (1 - weights$H[valid]))) * weights$dH[valid])
}

core_metric_spec_anderson_darling_stat <- function() {
  list(
    id = "anderson_darling_stat",
    fun = metric_anderson_darling_stat,
    name = "Anderson-Darling Distribution Statistic",
    description = "Tail-weighted empirical CDF gap statistic on the pooled support grid using Anderson-Darling weighting.",
    category = "agreement",
    perfect = 0,
    range = c(0, Inf),
    references = "Pettitt (1976) and Scholz & Stephens (1987) tail-weighted two-sample EDF comparison context; package metric reports a pooled-grid Anderson-Darling-style distance statistic.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_wasserstein_distance <- function(sim, obs) {
  validate_distribution_vector(sim, "wasserstein_distance")
  validate_distribution_vector(obs, "wasserstein_distance")
  validate_equal_length(sim, obs)

  mean(abs(sort(as.numeric(sim)) - sort(as.numeric(obs))))
}

core_metric_spec_wasserstein_distance <- function() {
  list(
    id = "wasserstein_distance",
    fun = metric_wasserstein_distance,
    name = "1-Wasserstein Distance",
    description = "Empirical one-dimensional Wasserstein distance via equal-weight quantile coupling of sorted samples.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Ramdas, Garcia, & Cuturi (2017) Wasserstein two-sample comparison context; package metric uses equal-weight empirical quantile coupling.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

# Shared Batch B2 conventions:
# - sqrt_nse applies sqrt() to both sim and obs before the standard NSE formula
# - weighted_kge uses the explicit weighted Euclidean distance in KGE component
#   space with stable defaults w_r = w_alpha = w_beta = 1
# - quantile_kge uses type-7 sample quantiles on the fixed probability grid
#   p = 0.1, ..., 0.9 and applies the standard KGE form to those summaries

.hm_b2_validate_positive_weight <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x) || x <= 0) {
    stop(sprintf("`%s` must be a positive finite numeric scalar.", name), call. = FALSE)
  }

  as.numeric(x)
}

metric_sqrt_nse <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("sqrt_nse requires at least 1 value.", call. = FALSE)
  }
  if (any(sim < 0) || any(obs < 0)) {
    stop("sqrt_nse is undefined for negative values.", call. = FALSE)
  }

  sim_sqrt <- sqrt(sim)
  obs_sqrt <- sqrt(obs)
  denom <- sum((obs_sqrt - mean(obs_sqrt))^2)

  if (denom == 0) {
    stop("sqrt_nse is undefined because sqrt(obs) has zero variance.", call. = FALSE)
  }

  1 - sum((sim_sqrt - obs_sqrt)^2) / denom
}

core_metric_spec_sqrt_nse <- function() {
  list(
    id = "sqrt_nse",
    fun = metric_sqrt_nse,
    name = "Square-Root NSE",
    description = "NSE computed after applying the square-root transform to non-negative sim and obs.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nash & Sutcliffe (1970) baseline NSE with transformed-objective-function context from Krause et al. (2005).",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b2")
  )
}

metric_weighted_kge <- function(sim, obs, w_r = 1, w_alpha = 1, w_beta = 1) {
  w_r <- .hm_b2_validate_positive_weight(w_r, "w_r")
  w_alpha <- .hm_b2_validate_positive_weight(w_alpha, "w_alpha")
  w_beta <- .hm_b2_validate_positive_weight(w_beta, "w_beta")

  r <- metric_r(sim, obs)
  alpha <- metric_alpha(sim, obs)
  beta <- metric_beta(sim, obs)

  1 - sqrt((w_r * (r - 1))^2 + (w_alpha * (alpha - 1))^2 + (w_beta * (beta - 1))^2)
}

core_metric_spec_weighted_kge <- function() {
  list(
    id = "weighted_kge",
    fun = metric_weighted_kge,
    name = "Weighted Kling-Gupta Efficiency",
    description = "Weighted KGE with defaults w_r = 1, w_alpha = 1, and w_beta = 1.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Gupta et al. (2009) KGE component framework; the exact weighted extension is a stable package-defined Phase 3 variant.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b2")
  )
}

metric_quantile_kge <- function(sim, obs) {
  if (length(obs) < 3L) {
    stop("quantile_kge requires at least 3 values.", call. = FALSE)
  }

  probs <- .hm_b1_fixed_prob_grid()
  sim_q <- stats::quantile(sim, probs = probs, type = 7, names = FALSE)
  obs_q <- stats::quantile(obs, probs = probs, type = 7, names = FALSE)
  obs_q_sd <- stats::sd(obs_q)
  sim_q_sd <- stats::sd(sim_q)
  obs_q_mean <- mean(obs_q)

  if (obs_q_sd == 0) {
    stop("quantile_kge is undefined because quantile(obs) has zero variance.", call. = FALSE)
  }
  if (sim_q_sd == 0) {
    stop("quantile_kge is undefined for constant quantile(sim) summaries.", call. = FALSE)
  }
  if (obs_q_mean == 0) {
    stop("quantile_kge is undefined because mean(quantile(obs)) == 0.", call. = FALSE)
  }

  r_q <- stats::cor(sim_q, obs_q)
  alpha_q <- sim_q_sd / obs_q_sd
  beta_q <- mean(sim_q) / obs_q_mean

  1 - sqrt((r_q - 1)^2 + (alpha_q - 1)^2 + (beta_q - 1)^2)
}

core_metric_spec_quantile_kge <- function() {
  list(
    id = "quantile_kge",
    fun = metric_quantile_kge,
    name = "Quantile Kling-Gupta Efficiency",
    description = "KGE applied to type-7 sample quantiles on the fixed probability grid p = 0.1, ..., 0.9.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Gupta et al. (2009) KGE component framework with Hyndman & Fan (1996) quantile conventions; the exact quantile-summary extension is a stable package-defined Phase 3 variant.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b2")
  )
}

# Shared Batch B3 conventions:
# - ordered input vectors are treated as hydrograph time order without any
#   magnitude-based reordering
# - derivative_nse applies the standard NSE formula to first differences
# - peak_timing_error uses the first occurrence of the series maximum
# - rising_limb_error uses observed positive first differences before the first
#   observed peak
# - recession_constant compares fitted log-recession constants on the first
#   contiguous observed recession segment after the first observed peak
# - baseflow_index_error uses a fixed three-pass Lyne-Hollick-style filter with
#   alpha = 0.925 and compares absolute BFI differences

.hm_b3_validate_ordered_series <- function(x, name, metric_id, min_length = 1L) {
  validate_numeric_vector(x, name)
  validate_finite(x, x)

  if (length(x) < min_length) {
    stop(sprintf("%s requires at least %d value%s.", metric_id, min_length, if (min_length == 1L) "" else "s"), call. = FALSE)
  }

  invisible(TRUE)
}

.hm_b3_first_differences <- function(x, metric_id) {
  if (length(x) < 2L) {
    stop(sprintf("%s requires at least 2 values.", metric_id), call. = FALSE)
  }

  diff(as.numeric(x))
}

.hm_b3_first_peak_index <- function(x) {
  which.max(as.numeric(x))
}

.hm_b3_rising_limb_interval_idx <- function(obs, metric_id) {
  peak_idx <- .hm_b3_first_peak_index(obs)
  if (peak_idx <= 1L) {
    stop(sprintf("%s is undefined because the observed peak occurs at the first time step.", metric_id), call. = FALSE)
  }

  dobs <- diff(as.numeric(obs))
  idx <- which(dobs[seq_len(peak_idx - 1L)] > 0)
  if (length(idx) == 0L) {
    stop(sprintf("%s is undefined because the observed series has no rising-limb intervals before the peak.", metric_id), call. = FALSE)
  }

  idx
}

.hm_b3_recession_segment_idx <- function(obs, metric_id) {
  peak_idx <- .hm_b3_first_peak_index(obs)
  n <- length(obs)
  if (peak_idx >= n) {
    stop(sprintf("%s is undefined because the observed peak occurs at the final time step.", metric_id), call. = FALSE)
  }

  end_idx <- peak_idx
  for (i in seq.int(peak_idx, n - 1L)) {
    if (obs[[i]] > 0 && obs[[i + 1L]] > 0 && obs[[i + 1L]] < obs[[i]]) {
      end_idx <- i + 1L
    } else {
      break
    }
  }

  idx <- seq.int(peak_idx, end_idx)
  if (length(idx) < 3L) {
    stop(sprintf("%s is undefined because no valid recession segment with at least 3 positive points was found.", metric_id), call. = FALSE)
  }

  idx
}

.hm_b3_fit_recession_constant <- function(x, idx, metric_id, name) {
  segment <- as.numeric(x[idx])
  if (any(segment <= 0)) {
    stop(sprintf("%s is undefined because the %s recession segment contains non-positive values.", metric_id, name), call. = FALSE)
  }

  time_idx <- seq_along(segment) - 1
  fit <- stats::lm(log(segment) ~ time_idx)
  slope <- stats::coef(fit)[["time_idx"]]
  if (!is.finite(slope)) {
    stop(sprintf("%s is undefined because the %s recession fit failed.", metric_id, name), call. = FALSE)
  }

  -as.numeric(slope)
}

.hm_b3_validate_nonnegative_flow <- function(x, metric_id, name) {
  if (any(x < 0)) {
    stop(sprintf("%s is undefined because %s contains negative values.", metric_id, name), call. = FALSE)
  }
}

.hm_b3_lh_baseflow_pass <- function(flow, alpha = 0.925) {
  n <- length(flow)
  quick <- numeric(n)

  for (i in 2:n) {
    quick[[i]] <- alpha * quick[[i - 1L]] + ((1 + alpha) / 2) * (flow[[i]] - flow[[i - 1L]])
    quick[[i]] <- min(max(quick[[i]], 0), flow[[i]])
  }

  pmin(pmax(flow - quick, 0), flow)
}

.hm_b3_baseflow_index_proxy <- function(flow, metric_id, alpha = 0.925) {
  if (length(flow) < 3L) {
    stop(sprintf("%s requires at least 3 values.", metric_id), call. = FALSE)
  }
  .hm_b3_validate_nonnegative_flow(flow, metric_id, "flow")

  flow_sum <- sum(flow)
  if (!is.finite(flow_sum) || flow_sum <= 0) {
    stop(sprintf("%s is undefined because sum(flow) must be positive.", metric_id), call. = FALSE)
  }

  baseflow <- as.numeric(flow)
  for (direction in c("forward", "backward", "forward")) {
    if (identical(direction, "backward")) {
      baseflow <- rev(.hm_b3_lh_baseflow_pass(rev(baseflow), alpha = alpha))
    } else {
      baseflow <- .hm_b3_lh_baseflow_pass(baseflow, alpha = alpha)
    }
  }

  sum(baseflow) / flow_sum
}

metric_derivative_nse <- function(sim, obs) {
  .hm_b3_validate_ordered_series(sim, "sim", "derivative_nse", min_length = 3L)
  .hm_b3_validate_ordered_series(obs, "obs", "derivative_nse", min_length = 3L)

  dsim <- .hm_b3_first_differences(sim, "derivative_nse")
  dobs <- .hm_b3_first_differences(obs, "derivative_nse")
  denom <- sum((dobs - mean(dobs))^2)

  if (denom == 0) {
    stop("derivative_nse is undefined because diff(obs) has zero variance.", call. = FALSE)
  }

  1 - sum((dsim - dobs)^2) / denom
}

core_metric_spec_derivative_nse <- function() {
  list(
    id = "derivative_nse",
    fun = metric_derivative_nse,
    name = "Derivative NSE",
    description = "NSE computed on ordered first-difference series diff(sim) and diff(obs).",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nash & Sutcliffe (1970) NSE with hydrograph-temporal-diagnostic context from Yilmaz et al. (2008); the package metric applies NSE to ordered first differences.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b3")
  )
}

metric_peak_timing_error <- function(sim, obs) {
  .hm_b3_validate_ordered_series(sim, "sim", "peak_timing_error", min_length = 1L)
  .hm_b3_validate_ordered_series(obs, "obs", "peak_timing_error", min_length = 1L)

  abs(.hm_b3_first_peak_index(sim) - .hm_b3_first_peak_index(obs))
}

core_metric_spec_peak_timing_error <- function() {
  list(
    id = "peak_timing_error",
    fun = metric_peak_timing_error,
    name = "Peak Timing Error",
    description = "Absolute time-step offset between the first simulated and observed peak occurrences.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Peak-timing evaluation context from Liu et al. (2011); the package metric uses the first occurrence of the maximum in each ordered series.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b3")
  )
}

metric_rising_limb_error <- function(sim, obs) {
  .hm_b3_validate_ordered_series(sim, "sim", "rising_limb_error", min_length = 2L)
  .hm_b3_validate_ordered_series(obs, "obs", "rising_limb_error", min_length = 2L)

  idx <- .hm_b3_rising_limb_interval_idx(obs, "rising_limb_error")
  dsim <- .hm_b3_first_differences(sim, "rising_limb_error")
  dobs <- .hm_b3_first_differences(obs, "rising_limb_error")

  sqrt(mean((dsim[idx] - dobs[idx])^2))
}

core_metric_spec_rising_limb_error <- function() {
  list(
    id = "rising_limb_error",
    fun = metric_rising_limb_error,
    name = "Rising Limb Error",
    description = "RMSE between simulated and observed first differences on observed rising-limb intervals before the first observed peak.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Hydrograph rising-limb diagnostic context from Yilmaz et al. (2008); the package metric uses observed positive-difference intervals before the first peak.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b3")
  )
}

metric_recession_constant <- function(sim, obs) {
  .hm_b3_validate_ordered_series(sim, "sim", "recession_constant", min_length = 3L)
  .hm_b3_validate_ordered_series(obs, "obs", "recession_constant", min_length = 3L)

  idx <- .hm_b3_recession_segment_idx(obs, "recession_constant")
  k_sim <- .hm_b3_fit_recession_constant(sim, idx, "recession_constant", "sim")
  k_obs <- .hm_b3_fit_recession_constant(obs, idx, "recession_constant", "obs")

  abs(k_sim - k_obs)
}

core_metric_spec_recession_constant <- function() {
  list(
    id = "recession_constant",
    fun = metric_recession_constant,
    name = "Recession Constant Error",
    description = "Absolute difference between fitted log-recession constants on the first contiguous observed recession segment after the peak.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Brutsaert & Nieber (1977) recession-analysis context; the package metric compares fitted log-recession constants on an observed post-peak recession segment.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b3")
  )
}

metric_baseflow_index_error <- function(sim, obs) {
  .hm_b3_validate_ordered_series(sim, "sim", "baseflow_index_error", min_length = 3L)
  .hm_b3_validate_ordered_series(obs, "obs", "baseflow_index_error", min_length = 3L)

  abs(
    .hm_b3_baseflow_index_proxy(sim, "baseflow_index_error") -
      .hm_b3_baseflow_index_proxy(obs, "baseflow_index_error")
  )
}

core_metric_spec_baseflow_index_error <- function() {
  list(
    id = "baseflow_index_error",
    fun = metric_baseflow_index_error,
    name = "Baseflow Index Error",
    description = "Absolute difference between fixed-parameter Lyne-Hollick-style baseflow indices of sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Ladson et al. (2013) Lyne-Hollick baseflow-separation context; the package metric compares absolute BFI differences using a fixed three-pass alpha = 0.925 filter.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b3")
  )
}

# Shared Batch B4 conventions:
# - event_nse is the only public B4 metric
# - events are segmented on the observed series only
# - threshold = observed values strictly above the observed 0.8 quantile
# - each event is one contiguous run above that threshold
# - simulated values are evaluated only on the pooled observed event windows
# - the final score is standard NSE on the pooled event-window values

.hm_b4_event_threshold <- function(obs, metric_id) {
  q <- stats::quantile(obs, probs = 0.8, type = 7, names = FALSE)
  if (!is.finite(q)) {
    stop(sprintf("%s is undefined because the observed event threshold could not be estimated.", metric_id), call. = FALSE)
  }
  as.numeric(q)
}

.hm_b4_event_windows <- function(obs, metric_id) {
  .hm_b3_validate_ordered_series(obs, "obs", metric_id, min_length = 1L)

  threshold <- .hm_b4_event_threshold(obs, metric_id)
  active <- as.numeric(obs) > threshold
  idx <- which(active)

  if (!length(idx)) {
    stop(sprintf("%s is undefined because the observed series contains no event windows above the 0.8 quantile threshold.", metric_id), call. = FALSE)
  }

  split_points <- cumsum(c(1L, diff(idx) > 1L))
  windows <- split(idx, split_points)

  if (length(windows) < 2L) {
    stop(sprintf("%s is undefined because at least 2 observed event windows are required.", metric_id), call. = FALSE)
  }

  windows
}

.hm_b4_event_indices <- function(obs, metric_id) {
  windows <- .hm_b4_event_windows(obs, metric_id)
  idx <- unlist(windows, use.names = FALSE)

  if (length(idx) < 3L) {
    stop(sprintf("%s is undefined because pooled event windows must contain at least 3 observations.", metric_id), call. = FALSE)
  }

  idx
}

metric_event_nse <- function(sim, obs) {
  .hm_b3_validate_ordered_series(sim, "sim", "event_nse", min_length = 1L)
  .hm_b3_validate_ordered_series(obs, "obs", "event_nse", min_length = 1L)

  idx <- .hm_b4_event_indices(obs, "event_nse")
  sim_event <- as.numeric(sim)[idx]
  obs_event <- as.numeric(obs)[idx]
  denom <- sum((obs_event - mean(obs_event))^2)

  if (denom == 0) {
    stop("event_nse is undefined because pooled observed event windows have zero variance.", call. = FALSE)
  }

  1 - sum((sim_event - obs_event)^2) / denom
}

core_metric_spec_event_nse <- function() {
  list(
    id = "event_nse",
    fun = metric_event_nse,
    name = "Event NSE",
    description = "NSE computed on pooled observed event windows defined by contiguous observed values strictly above the observed 0.8 quantile.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nash & Sutcliffe (1970) baseline NSE with event-focused hydrograph diagnostic context from Yilmaz et al. (2008); the exact observed-window pooled-event formulation is a stable package-defined Phase 3 variant.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b4")
  )
}
