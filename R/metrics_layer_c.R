# Shared Batch C1 conventions:
# - skewness_error uses the adjusted Fisher-Pearson sample skewness G1 from
#   Joanes & Gill (1998) and returns abs(G1_sim - G1_obs)
# - kurtosis_error uses the adjusted Fisher-Pearson sample excess kurtosis G2
#   from Joanes & Gill (1998) and returns abs(G2_sim - G2_obs)
# - iqr_error uses stats::quantile(..., type = 7) with IQR = Q3 - Q1 and
#   returns abs(IQR_sim - IQR_obs)

.hm_c1_validate_summary_vector <- function(x, metric_id, name, min_length) {
  validate_numeric_vector(x, name)
  validate_finite(x, x)

  if (length(x) < min_length) {
    stop(sprintf("%s requires at least %d values.", metric_id, min_length), call. = FALSE)
  }

  as.numeric(x)
}

.hm_c1_centered_moment <- function(x, order) {
  centered <- x - mean(x)
  mean(centered^order)
}

.hm_c1_adjusted_skewness <- function(x, metric_id, name) {
  x <- .hm_c1_validate_summary_vector(x, metric_id, name, min_length = 3L)
  m2 <- .hm_c1_centered_moment(x, 2L)
  if (!is.finite(m2) || m2 == 0) {
    stop(sprintf("%s is undefined because %s has zero variance.", metric_id, name), call. = FALSE)
  }

  n <- length(x)
  g1 <- .hm_c1_centered_moment(x, 3L) / (m2^(3 / 2))
  sqrt(n * (n - 1)) / (n - 2) * g1
}

.hm_c1_adjusted_excess_kurtosis <- function(x, metric_id, name) {
  x <- .hm_c1_validate_summary_vector(x, metric_id, name, min_length = 4L)
  m2 <- .hm_c1_centered_moment(x, 2L)
  if (!is.finite(m2) || m2 == 0) {
    stop(sprintf("%s is undefined because %s has zero variance.", metric_id, name), call. = FALSE)
  }

  n <- length(x)
  g2 <- .hm_c1_centered_moment(x, 4L) / (m2^2) - 3
  ((n - 1) / ((n - 2) * (n - 3))) * ((n + 1) * g2 + 6)
}

.hm_c1_type7_iqr <- function(x, metric_id, name) {
  x <- .hm_c1_validate_summary_vector(x, metric_id, name, min_length = 2L)
  qs <- stats::quantile(x, probs = c(0.25, 0.75), type = 7, names = FALSE)
  if (any(!is.finite(qs))) {
    stop(sprintf("%s is undefined because %s quartiles could not be estimated.", metric_id, name), call. = FALSE)
  }

  as.numeric(qs[[2L]] - qs[[1L]])
}

metric_skewness_error <- function(sim, obs) {
  abs(
    .hm_c1_adjusted_skewness(sim, "skewness_error", "sim") -
      .hm_c1_adjusted_skewness(obs, "skewness_error", "obs")
  )
}

core_metric_spec_skewness_error <- function() {
  list(
    id = "skewness_error",
    fun = metric_skewness_error,
    name = "Skewness Error",
    description = "Absolute difference between adjusted Fisher-Pearson sample skewness of sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Joanes & Gill (1998) sample skewness conventions; package metric uses absolute error in adjusted Fisher-Pearson sample skewness G1.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c1")
  )
}

metric_kurtosis_error <- function(sim, obs) {
  abs(
    .hm_c1_adjusted_excess_kurtosis(sim, "kurtosis_error", "sim") -
      .hm_c1_adjusted_excess_kurtosis(obs, "kurtosis_error", "obs")
  )
}

core_metric_spec_kurtosis_error <- function() {
  list(
    id = "kurtosis_error",
    fun = metric_kurtosis_error,
    name = "Kurtosis Error",
    description = "Absolute difference between adjusted Fisher-Pearson sample excess kurtosis of sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Joanes & Gill (1998) sample kurtosis conventions; package metric uses absolute error in adjusted Fisher-Pearson excess kurtosis G2.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c1")
  )
}

metric_iqr_error <- function(sim, obs) {
  abs(
    .hm_c1_type7_iqr(sim, "iqr_error", "sim") -
      .hm_c1_type7_iqr(obs, "iqr_error", "obs")
  )
}

core_metric_spec_iqr_error <- function() {
  list(
    id = "iqr_error",
    fun = metric_iqr_error,
    name = "Interquartile Range Error",
    description = "Absolute difference between type-7 interquartile ranges IQR = Q3 - Q1 of sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Hyndman & Fan (1996) sample-quantile conventions; package metric uses absolute error in the type-7 interquartile range.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c1")
  )
}

# Shared Batch C2 conventions:
# - all C2 metrics use histogram-based discrete approximations with the
#   Sturges bin-count rule k = ceiling(log2(n_pool) + 1)
# - non-constant pooled support uses at least 2 equal-width bins; constant
#   pooled support collapses to 1 bin with a small symmetric padding interval
# - entropy_diff and kl_divergence_flow bin sim and obs on the same pooled
#   shared-support grid
# - mutual_information_score uses the same pooled support grid on both axes for
#   the paired (sim, obs) joint histogram
# - Shannon quantities use the natural logarithm
# - kl_divergence_flow reports KL(P_obs || P_sim) after additive epsilon
#   smoothing with epsilon = 1e-12 and renormalization

.hm_c2_validate_info_pair <- function(sim, obs, metric_id, min_length, require_equal_length = FALSE) {
  sim <- .hm_c1_validate_summary_vector(sim, metric_id, "sim", min_length = min_length)
  obs <- .hm_c1_validate_summary_vector(obs, metric_id, "obs", min_length = min_length)

  if (require_equal_length) {
    validate_equal_length(sim, obs)
  }

  list(sim = sim, obs = obs)
}

.hm_c2_sturges_bin_count <- function(n) {
  max(2L, as.integer(ceiling(log(n, base = 2) + 1)))
}

.hm_c2_pooled_breaks <- function(sim, obs, metric_id) {
  pooled <- c(sim, obs)
  x_min <- min(pooled)
  x_max <- max(pooled)

  if (!is.finite(x_min) || !is.finite(x_max)) {
    stop(sprintf("%s requires finite pooled support.", metric_id), call. = FALSE)
  }

  if (x_min == x_max) {
    delta <- max(0.5, abs(x_min) * 1e-8)
    return(c(x_min - delta, x_max + delta))
  }

  n_bins <- .hm_c2_sturges_bin_count(length(pooled))
  seq(x_min, x_max, length.out = n_bins + 1L)
}

.hm_c2_bin_index <- function(x, breaks, metric_id, name) {
  bins <- cut(x, breaks = breaks, include.lowest = TRUE, right = TRUE, labels = FALSE)
  if (anyNA(bins)) {
    stop(sprintf("%s could not assign %s values to the shared histogram grid.", metric_id, name), call. = FALSE)
  }

  as.integer(bins)
}

.hm_c2_hist_probs <- function(x, breaks, metric_id, name) {
  bins <- .hm_c2_bin_index(x, breaks, metric_id, name)
  counts <- tabulate(bins, nbins = length(breaks) - 1L)
  counts / sum(counts)
}

.hm_c2_entropy_from_probs <- function(probs) {
  positive <- probs > 0
  -sum(probs[positive] * log(probs[positive]))
}

.hm_c2_smoothed_probs <- function(probs, epsilon = 1e-12) {
  smoothed <- as.numeric(probs) + epsilon
  smoothed / sum(smoothed)
}

.hm_c2_joint_probs <- function(sim, obs, breaks, metric_id) {
  sim_bins <- .hm_c2_bin_index(sim, breaks, metric_id, "sim")
  obs_bins <- .hm_c2_bin_index(obs, breaks, metric_id, "obs")
  n_bins <- length(breaks) - 1L
  joint_index <- (sim_bins - 1L) * n_bins + obs_bins
  counts <- tabulate(joint_index, nbins = n_bins * n_bins)
  matrix(counts / sum(counts), nrow = n_bins, ncol = n_bins, byrow = TRUE)
}

metric_entropy_diff <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "entropy_diff", min_length = 2L)
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, "entropy_diff")
  sim_entropy <- .hm_c2_entropy_from_probs(.hm_c2_hist_probs(inputs$sim, breaks, "entropy_diff", "sim"))
  obs_entropy <- .hm_c2_entropy_from_probs(.hm_c2_hist_probs(inputs$obs, breaks, "entropy_diff", "obs"))

  abs(sim_entropy - obs_entropy)
}

core_metric_spec_entropy_diff <- function() {
  list(
    id = "entropy_diff",
    fun = metric_entropy_diff,
    name = "Entropy Difference",
    description = "Absolute difference between pooled-grid Shannon entropies of the Sturges-binned empirical sim and obs distributions.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Shannon (1948) entropy foundation with Sturges (1926) histogram binning; package metric uses absolute entropy difference on the pooled support grid.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c2")
  )
}

metric_mutual_information_score <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(
    sim,
    obs,
    "mutual_information_score",
    min_length = 3L,
    require_equal_length = TRUE
  )
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, "mutual_information_score")
  joint <- .hm_c2_joint_probs(inputs$sim, inputs$obs, breaks, "mutual_information_score")
  px <- rowSums(joint)
  py <- colSums(joint)
  denom <- outer(px, py)
  positive <- joint > 0

  sum(joint[positive] * log(joint[positive] / denom[positive]))
}

core_metric_spec_mutual_information_score <- function() {
  list(
    id = "mutual_information_score",
    fun = metric_mutual_information_score,
    name = "Mutual Information Score",
    description = "Raw mutual information on the paired Sturges-binned joint empirical distribution using the pooled support grid and natural logs.",
    category = "agreement",
    perfect = Inf,
    range = c(0, Inf),
    references = "Shannon (1948) mutual-information foundation with Sturges (1926) histogram binning; package metric reports raw pooled-grid mutual information in nats.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c2")
  )
}

metric_kl_divergence_flow <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "kl_divergence_flow", min_length = 2L)
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, "kl_divergence_flow")
  p_obs <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$obs, breaks, "kl_divergence_flow", "obs"))
  p_sim <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$sim, breaks, "kl_divergence_flow", "sim"))
  value <- sum(p_obs * log(p_obs / p_sim))

  if (!is.finite(value)) {
    stop("kl_divergence_flow remained non-finite after epsilon smoothing.", call. = FALSE)
  }

  value
}

core_metric_spec_kl_divergence_flow <- function() {
  list(
    id = "kl_divergence_flow",
    fun = metric_kl_divergence_flow,
    name = "Flow KL Divergence",
    description = "Directed KL(P_obs || P_sim) on Sturges-binned empirical flow distributions over the pooled support grid with fixed epsilon smoothing.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Kullback & Leibler (1951) directed divergence foundation with Sturges (1926) histogram binning; package metric reports KL(P_obs || P_sim) after fixed epsilon smoothing.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c2")
  )
}

# Shared Batch C3 conventions:
# - flow_duration_entropy reuses descending FDC ordering from .hm_fdc_prepare
#   and applies the C2 pooled-support Sturges histogram entropy policy to the
#   ordered flow values
# - tail_dependence_score uses the observed 0.9 type-7 quantile as a strict
#   upper-tail threshold and reports P(sim > q_obs | obs > q_obs)
# - extreme_event_ratio uses the same observed 0.9 type-7 quantile for both
#   series and counts contiguous runs strictly above the threshold
# - extreme-event segmentation is deterministic and ordered; one contiguous run
#   above threshold is one event

.hm_c3_tail_threshold <- function(obs, metric_id, threshold_prob = 0.9) {
  q <- stats::quantile(obs, probs = threshold_prob, type = 7, names = FALSE)
  if (!is.finite(q)) {
    stop(sprintf("%s is undefined because the observed tail threshold could not be estimated.", metric_id), call. = FALSE)
  }

  as.numeric(q)
}

.hm_c3_event_windows_from_threshold <- function(x, threshold, metric_id, name) {
  active <- as.numeric(x) > threshold
  idx <- which(active)

  if (!length(idx)) {
    stop(sprintf("%s is undefined because %s contains no events above the observed 0.9 quantile threshold.", metric_id, name), call. = FALSE)
  }

  split_points <- cumsum(c(1L, diff(idx) > 1L))
  split(idx, split_points)
}

metric_flow_duration_entropy <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "flow_duration_entropy", min_length = 2L)
  sim_fdc <- .hm_fdc_prepare(inputs$sim)$flow
  obs_fdc <- .hm_fdc_prepare(inputs$obs)$flow
  breaks <- .hm_c2_pooled_breaks(sim_fdc, obs_fdc, "flow_duration_entropy")
  sim_entropy <- .hm_c2_entropy_from_probs(.hm_c2_hist_probs(sim_fdc, breaks, "flow_duration_entropy", "sim"))
  obs_entropy <- .hm_c2_entropy_from_probs(.hm_c2_hist_probs(obs_fdc, breaks, "flow_duration_entropy", "obs"))

  abs(sim_entropy - obs_entropy)
}

core_metric_spec_flow_duration_entropy <- function() {
  list(
    id = "flow_duration_entropy",
    fun = metric_flow_duration_entropy,
    name = "Flow-Duration Entropy",
    description = "Absolute difference between pooled-grid Shannon entropies of descending flow-duration-curve values using Sturges histograms.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Searcy (1959) flow-duration-curve construction with Shannon (1948) entropy and Sturges (1926) histogram binning; package metric uses absolute entropy difference on descending FDC values.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c3")
  )
}

metric_tail_dependence_score <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(
    sim,
    obs,
    "tail_dependence_score",
    min_length = 3L,
    require_equal_length = TRUE
  )
  threshold <- .hm_c3_tail_threshold(inputs$obs, "tail_dependence_score")
  obs_exceed <- inputs$obs > threshold

  if (!any(obs_exceed)) {
    stop("tail_dependence_score is undefined because obs contains no exceedances above the observed 0.9 quantile threshold.", call. = FALSE)
  }

  mean(inputs$sim[obs_exceed] > threshold)
}

core_metric_spec_tail_dependence_score <- function() {
  list(
    id = "tail_dependence_score",
    fun = metric_tail_dependence_score,
    name = "Tail Dependence Score",
    description = "Empirical upper-tail dependence proxy P(sim > q_obs,0.9 | obs > q_obs,0.9) using the observed type-7 0.9 quantile threshold.",
    category = "agreement",
    perfect = 1,
    range = c(0, 1),
    references = "Coles, Heffernan, & Tawn (1999) tail-dependence diagnostic context; package metric uses a deterministic observed-threshold conditional exceedance score rather than an asymptotic estimator.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c3")
  )
}

metric_extreme_event_ratio <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(
    sim,
    obs,
    "extreme_event_ratio",
    min_length = 3L,
    require_equal_length = TRUE
  )
  .hm_b3_validate_ordered_series(inputs$sim, "sim", "extreme_event_ratio", min_length = 3L)
  .hm_b3_validate_ordered_series(inputs$obs, "obs", "extreme_event_ratio", min_length = 3L)

  threshold <- .hm_c3_tail_threshold(inputs$obs, "extreme_event_ratio")
  obs_windows <- .hm_c3_event_windows_from_threshold(inputs$obs, threshold, "extreme_event_ratio", "obs")
  sim_active <- as.numeric(inputs$sim) > threshold
  sim_idx <- which(sim_active)
  sim_count <- if (!length(sim_idx)) 0L else length(split(sim_idx, cumsum(c(1L, diff(sim_idx) > 1L))))

  sim_count / length(obs_windows)
}

core_metric_spec_extreme_event_ratio <- function() {
  list(
    id = "extreme_event_ratio",
    fun = metric_extreme_event_ratio,
    name = "Extreme Event Ratio",
    description = "Ratio of simulated to observed contiguous extreme-event counts using the observed type-7 0.9 quantile threshold for both series.",
    category = "agreement",
    perfect = 1,
    range = c(0, Inf),
    references = "Yilmaz et al. (2008) event-focused hydrograph diagnostic context with deterministic high-threshold event segmentation; package metric reports the observed-threshold event-count ratio n_sim / n_obs.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c3")
  )
}
