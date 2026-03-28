# Shared Batch C1 conventions:
# - skewness_error uses the adjusted Fisher-Pearson sample skewness G1 from
#   Joanes & Gill (1998) and returns abs(G1_sim - G1_obs)
# - kurtosis_error uses the adjusted Fisher-Pearson sample excess kurtosis G2
#   from Joanes & Gill (1998) and returns abs(G2_sim - G2_obs)

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

# Shared Batch C2 conventions:
# - all C2 metrics use histogram-based discrete approximations with the
#   Sturges bin-count rule k = ceiling(log2(n_pool) + 1)
# - non-constant pooled support uses at least 2 equal-width bins; constant
#   pooled support collapses to 1 bin with a small symmetric padding interval
# - entropy_diff and kl_divergence_flow bin sim and obs on the same pooled
#   shared-support grid
# - mutual_information_score uses the same pooled support grid on both axes for
#   the paired (sim, obs) joint histogram
# - mutual_information is the canonical alias of mutual_information_score under
#   the same pooled-grid raw-MI convention
# - kl_divergence is the canonical alias of kl_divergence_flow under the same
#   directed KL(P_obs || P_sim) convention
# - normalised_mi reports MI / sqrt(H_sim * H_obs) and is undefined when either
#   marginal entropy is zero
# - js_divergence reports 0.5 * KL(P_sim || M) + 0.5 * KL(P_obs || M) with
#   M = 0.5 * (P_sim + P_obs) using the same smoothed pooled-grid marginals
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

.hm_c2_mutual_information_value <- function(sim, obs, metric_id) {
  inputs <- .hm_c2_validate_info_pair(
    sim,
    obs,
    metric_id,
    min_length = 3L,
    require_equal_length = TRUE
  )
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, metric_id)
  joint <- .hm_c2_joint_probs(inputs$sim, inputs$obs, breaks, metric_id)
  px <- rowSums(joint)
  py <- colSums(joint)
  denom <- outer(px, py)
  positive <- joint > 0

  list(
    value = sum(joint[positive] * log(joint[positive] / denom[positive])),
    sim_probs = px,
    obs_probs = py
  )
}

.hm_c2_kl_value_from_probs <- function(p_ref, p_cmp, metric_id) {
  value <- sum(p_ref * log(p_ref / p_cmp))
  if (!is.finite(value)) {
    stop(sprintf("%s remained non-finite after epsilon smoothing.", metric_id), call. = FALSE)
  }

  value
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
  .hm_c2_mutual_information_value(sim, obs, "mutual_information_score")$value
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

metric_mutual_information <- function(sim, obs) {
  .hm_c2_mutual_information_value(sim, obs, "mutual_information")$value
}

core_metric_spec_mutual_information <- function() {
  list(
    id = "mutual_information",
    fun = metric_mutual_information,
    name = "Mutual Information",
    description = "Canonical raw mutual information in nats on the paired Sturges-binned joint empirical distribution using the pooled support grid.",
    category = "agreement",
    perfect = Inf,
    range = c(0, Inf),
    references = "Shannon (1948) mutual-information foundation with Sturges (1926) histogram binning; package metric is the canonical raw pooled-grid mutual information in nats and matches mutual_information_score under the current deterministic policy.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "canonical-info-theory")
  )
}

metric_normalised_mi <- function(sim, obs) {
  out <- .hm_c2_mutual_information_value(sim, obs, "normalised_mi")
  h_sim <- .hm_c2_entropy_from_probs(out$sim_probs)
  h_obs <- .hm_c2_entropy_from_probs(out$obs_probs)

  if (!is.finite(h_sim) || !is.finite(h_obs) || h_sim <= 0 || h_obs <= 0) {
    stop("normalised_mi is undefined because both marginal entropies must be positive.", call. = FALSE)
  }

  out$value / sqrt(h_sim * h_obs)
}

core_metric_spec_normalised_mi <- function() {
  list(
    id = "normalised_mi",
    fun = metric_normalised_mi,
    name = "Normalised Mutual Information",
    description = "Canonical normalized mutual information MI / sqrt(H_sim * H_obs) on pooled-support Sturges histograms using natural logs.",
    category = "agreement",
    perfect = 1,
    range = c(0, 1),
    references = "Shannon (1948) mutual-information and entropy foundations, Sturges (1926) histogram binning, and Strehl & Ghosh (2002) normalized mutual-information context; package metric uses the explicit normalization MI / sqrt(H_sim * H_obs) and rejects zero-entropy cases.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "canonical-info-theory")
  )
}

metric_kl_divergence_flow <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "kl_divergence_flow", min_length = 2L)
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, "kl_divergence_flow")
  p_obs <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$obs, breaks, "kl_divergence_flow", "obs"))
  p_sim <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$sim, breaks, "kl_divergence_flow", "sim"))
  .hm_c2_kl_value_from_probs(p_obs, p_sim, "kl_divergence_flow")
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

metric_kl_divergence <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "kl_divergence", min_length = 2L)
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, "kl_divergence")
  p_obs <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$obs, breaks, "kl_divergence", "obs"))
  p_sim <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$sim, breaks, "kl_divergence", "sim"))
  .hm_c2_kl_value_from_probs(p_obs, p_sim, "kl_divergence")
}

core_metric_spec_kl_divergence <- function() {
  list(
    id = "kl_divergence",
    fun = metric_kl_divergence,
    name = "KL Divergence",
    description = "Canonical directed KL(P_obs || P_sim) on Sturges-binned empirical distributions over the pooled support grid with fixed epsilon smoothing.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Kullback & Leibler (1951) directed divergence foundation with Sturges (1926) histogram binning; package metric is the canonical directed KL(P_obs || P_sim) and matches kl_divergence_flow under the current deterministic policy.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "canonical-info-theory")
  )
}

metric_js_divergence <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "js_divergence", min_length = 2L)
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, "js_divergence")
  p_sim <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$sim, breaks, "js_divergence", "sim"))
  p_obs <- .hm_c2_smoothed_probs(.hm_c2_hist_probs(inputs$obs, breaks, "js_divergence", "obs"))
  midpoint <- 0.5 * (p_sim + p_obs)

  0.5 * .hm_c2_kl_value_from_probs(p_sim, midpoint, "js_divergence") +
    0.5 * .hm_c2_kl_value_from_probs(p_obs, midpoint, "js_divergence")
}

core_metric_spec_js_divergence <- function() {
  list(
    id = "js_divergence",
    fun = metric_js_divergence,
    name = "Jensen-Shannon Divergence",
    description = "Jensen-Shannon divergence 0.5 * KL(P_sim || M) + 0.5 * KL(P_obs || M) on pooled-support Sturges histograms with fixed epsilon smoothing.",
    category = "error",
    perfect = 0,
    range = c(0, log(2)),
    references = "Lin (1991) Jensen-Shannon divergence foundation with Shannon (1948), Kullback & Leibler (1951), and Sturges (1926); package metric uses pooled-grid Sturges histograms, natural logs, and fixed epsilon smoothing.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "canonical-info-theory")
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

# Shared Batch C4 conventions:
# - rank_turnover_score uses paired average ranks via rank(..., ties.method =
#   "average"), computes the mean absolute rank difference, and normalizes by
#   the reversed-order maximum for length n so the score is in [0, 1]
# - distribution_overlap uses the C2 pooled-support Sturges histogram policy
#   and returns the overlap coefficient sum(min(p_sim, p_obs))
# - quantile_shift_index uses the fixed probability grid p = 0.1, ..., 0.9
#   with stats::quantile(..., type = 7), then scales the mean absolute
#   quantile difference by the observed IQR

.hm_c4_average_ranks <- function(x) {
  rank(as.numeric(x), ties.method = "average")
}

.hm_c4_max_mean_rank_diff <- function(n) {
  mean(abs(seq_len(n) - rev(seq_len(n))))
}

metric_rank_turnover_score <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(
    sim,
    obs,
    "rank_turnover_score",
    min_length = 2L,
    require_equal_length = TRUE
  )
  rank_diff <- abs(.hm_c4_average_ranks(inputs$sim) - .hm_c4_average_ranks(inputs$obs))
  max_diff <- .hm_c4_max_mean_rank_diff(length(inputs$obs))

  if (!is.finite(max_diff) || max_diff <= 0) {
    stop("rank_turnover_score is undefined because the rank normalization denominator is not positive.", call. = FALSE)
  }

  mean(rank_diff) / max_diff
}

core_metric_spec_rank_turnover_score <- function() {
  list(
    id = "rank_turnover_score",
    fun = metric_rank_turnover_score,
    name = "Rank Turnover Score",
    description = "Mean absolute average-rank difference between sim and obs, normalized by the reversed-order maximum for length n.",
    category = "error",
    perfect = 0,
    range = c(0, 1),
    references = "Spearman (1904) rank-order association context; package metric uses average ranks and a normalized mean absolute rank-difference score.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c4")
  )
}

metric_distribution_overlap <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "distribution_overlap", min_length = 2L)
  breaks <- .hm_c2_pooled_breaks(inputs$sim, inputs$obs, "distribution_overlap")
  p_sim <- .hm_c2_hist_probs(inputs$sim, breaks, "distribution_overlap", "sim")
  p_obs <- .hm_c2_hist_probs(inputs$obs, breaks, "distribution_overlap", "obs")

  sum(pmin(p_sim, p_obs))
}

core_metric_spec_distribution_overlap <- function() {
  list(
    id = "distribution_overlap",
    fun = metric_distribution_overlap,
    name = "Distribution Overlap",
    description = "Overlap coefficient sum(min(p_sim, p_obs)) on pooled-support Sturges histograms of sim and obs.",
    category = "agreement",
    perfect = 1,
    range = c(0, 1),
    references = "Sturges (1926) histogram binning; package metric reports the pooled-grid overlap coefficient sum(min(p_sim, p_obs)).",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c4")
  )
}

metric_quantile_shift_index <- function(sim, obs) {
  inputs <- .hm_c2_validate_info_pair(sim, obs, "quantile_shift_index", min_length = 3L)
  probs <- .hm_b1_fixed_prob_grid()
  sim_q <- stats::quantile(inputs$sim, probs = probs, type = 7, names = FALSE)
  obs_q <- stats::quantile(inputs$obs, probs = probs, type = 7, names = FALSE)
  iqr_obs <- .hm_c1_type7_iqr(inputs$obs, "quantile_shift_index", "obs")

  if (iqr_obs == 0) {
    stop("quantile_shift_index is undefined because IQR(obs) == 0.", call. = FALSE)
  }

  mean(abs(sim_q - obs_q)) / iqr_obs
}

core_metric_spec_quantile_shift_index <- function() {
  list(
    id = "quantile_shift_index",
    fun = metric_quantile_shift_index,
    name = "Quantile Shift Index",
    description = "Mean absolute type-7 quantile difference on p = 0.1, ..., 0.9 scaled by the observed interquartile range.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Hyndman & Fan (1996) quantile conventions; package metric uses a fixed p = 0.1..0.9 grid and scales the mean absolute quantile shift by IQR(obs).",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c4")
  )
}

# Composite validation-index convention:
# - extended_valindex is a fixed, equal-weight extension of the package's
#   existing valindex idea of combining multiple diagnostics
# - it uses the stable component set nse, kge, rmse, pbias, r, mae, rsr, and ve
# - all components are evaluated on the same aligned prepared sim/obs vectors
# - each component is converted to a bounded higher-is-better score before
#   aggregation; undefined component states are rejected explicitly

.hm_extended_valindex_component_ids <- function() {
  c("nse", "kge", "rmse", "pbias", "r", "mae", "rsr", "ve")
}

.hm_extended_valindex_obs_scale <- function(obs) {
  scale <- mean(abs(obs))
  if (!is.finite(scale) || scale <= 0) {
    stop("extended_valindex is undefined because mean(abs(obs)) must be positive.", call. = FALSE)
  }

  as.numeric(scale)
}

.hm_extended_valindex_require_finite <- function(value, metric_id, component_id) {
  if (!is.numeric(value) || length(value) != 1L || !is.finite(value)) {
    stop(
      sprintf("%s is undefined because component '%s' is not finite.", metric_id, component_id),
      call. = FALSE
    )
  }

  as.numeric(value)
}

.hm_extended_valindex_component_scores <- function(sim, obs, metric_id = "extended_valindex") {
  obs_scale <- .hm_extended_valindex_obs_scale(obs)
  values <- c(
    nse = .hm_extended_valindex_require_finite(metric_nse(sim, obs), metric_id, "nse"),
    kge = .hm_extended_valindex_require_finite(metric_kge(sim, obs), metric_id, "kge"),
    rmse = .hm_extended_valindex_require_finite(metric_rmse(sim, obs), metric_id, "rmse"),
    pbias = .hm_extended_valindex_require_finite(metric_pbias(sim, obs), metric_id, "pbias"),
    r = .hm_extended_valindex_require_finite(metric_r(sim, obs), metric_id, "r"),
    mae = .hm_extended_valindex_require_finite(metric_mae(sim, obs), metric_id, "mae"),
    rsr = .hm_extended_valindex_require_finite(metric_rsr(sim, obs), metric_id, "rsr"),
    ve = .hm_extended_valindex_require_finite(metric_ve(sim, obs), metric_id, "ve")
  )

  c(
    nse = 1 / (1 + abs(1 - values[["nse"]])),
    kge = 1 / (1 + abs(1 - values[["kge"]])),
    rmse = 1 / (1 + (values[["rmse"]] / obs_scale)),
    pbias = 1 / (1 + (abs(values[["pbias"]]) / 100)),
    r = (values[["r"]] + 1) / 2,
    mae = 1 / (1 + (values[["mae"]] / obs_scale)),
    rsr = 1 / (1 + values[["rsr"]]),
    ve = 1 / (1 + abs(1 - values[["ve"]]))
  )
}

metric_extended_valindex <- function(sim, obs) {
  mean(.hm_extended_valindex_component_scores(sim, obs, metric_id = "extended_valindex"))
}

core_metric_spec_extended_valindex <- function() {
  list(
    id = "extended_valindex",
    fun = metric_extended_valindex,
    name = "Extended Validation Index",
    description = "Equal-weight composite of normalized NSE, KGE, RMSE, PBIAS, r, MAE, RSR, and VE component scores on the same aligned data.",
    category = "agreement",
    perfect = 1,
    range = c(0, 1),
    references = "Package-defined composite validation index grounded in the valindex decision context plus the NSE, KGE, correlation, bias, error, and volumetric-efficiency literature already cited in the package references; the metric uses fixed equal weights and explicit bounded normalizations.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "composite")
  )
}
