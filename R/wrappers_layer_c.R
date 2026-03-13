#' Evaluate the skewness error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"skewness_error"`. The metric uses the adjusted Fisher-Pearson sample
#' skewness convention and returns the absolute simulated-versus-observed
#' difference.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' skewness_error(c(1, 2, 3, 4, 8, 9), c(1, 2, 3, 4, 5, 6))
#' @export
skewness_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("skewness_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the kurtosis error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"kurtosis_error"`. The metric uses the adjusted Fisher-Pearson sample
#' excess kurtosis convention and returns the absolute simulated-versus-observed
#' difference.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' kurtosis_error(c(1, 2, 3, 4, 8, 9), c(1, 2, 3, 4, 5, 6))
#' @export
kurtosis_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("kurtosis_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the interquartile range error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"iqr_error"`.
#' The metric defines IQR as `Q3 - Q1` using `stats::quantile(..., type = 7)`
#' and returns the absolute simulated-versus-observed difference.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' iqr_error(c(1, 2, 3, 4, 8, 9), c(1, 2, 3, 4, 5, 6))
#' @export
iqr_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("iqr_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the entropy difference wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"entropy_diff"`. The metric uses pooled-support Sturges histograms and
#' returns the absolute difference between the Shannon entropies of the
#' empirical sim and obs distributions.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' entropy_diff(c(1, 2, 2, 3, 4, 5), c(1, 1, 2, 3, 3, 4))
#' @export
entropy_diff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("entropy_diff", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the mutual information score wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"mutual_information_score"`. The metric computes raw mutual information in
#' natural-log units from the paired Sturges-binned joint empirical
#' distribution on the pooled support grid.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mutual_information_score(c(1, 2, 2, 3, 4, 5), c(1, 1, 2, 3, 3, 4))
#' @export
mutual_information_score <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper(
    "mutual_information_score",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...)
  )
}

#' Evaluate the mutual information wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"mutual_information"`. Under the current deterministic policy this is the
#' canonical name for the same pooled-grid raw mutual information reported by
#' `"mutual_information_score"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mutual_information(c(1, 2, 2, 3, 4, 5), c(1, 1, 2, 3, 3, 4))
#' @export
mutual_information <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper(
    "mutual_information",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...)
  )
}

#' Evaluate the normalised mutual information wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"normalised_mi"`. The metric uses pooled-support Sturges histograms and
#' reports `MI / sqrt(H_sim * H_obs)` in natural-log units. Zero-entropy
#' normalization cases are rejected explicitly.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' normalised_mi(c(1, 2, 2, 3, 4, 5), c(1, 1, 2, 3, 3, 4))
#' @export
normalised_mi <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("normalised_mi", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the flow KL divergence wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"kl_divergence_flow"`. The metric reports directed `KL(P_obs || P_sim)` on
#' pooled-support Sturges histograms after fixed epsilon smoothing with
#' `epsilon = 1e-12`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' kl_divergence_flow(c(1, 2, 2, 3, 4, 5), c(1, 1, 2, 3, 3, 4))
#' @export
kl_divergence_flow <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("kl_divergence_flow", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the KL divergence wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"kl_divergence"`. Under the current deterministic policy this is the
#' canonical name for the same directed `KL(P_obs || P_sim)` quantity reported
#' by `"kl_divergence_flow"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' kl_divergence(c(1, 2, 2, 3, 4, 5), c(1, 1, 2, 3, 3, 4))
#' @export
kl_divergence <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("kl_divergence", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the Jensen-Shannon divergence wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"js_divergence"`. The metric uses pooled-support Sturges histograms,
#' natural logs, and fixed epsilon smoothing to report
#' `0.5 * KL(P_sim || M) + 0.5 * KL(P_obs || M)` with `M = 0.5 * (P_sim + P_obs)`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' js_divergence(c(1, 2, 2, 3, 4, 5), c(1, 1, 2, 3, 3, 4))
#' @export
js_divergence <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("js_divergence", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the flow-duration entropy wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"flow_duration_entropy"`. The metric reuses descending flow-duration-curve
#' ordering and computes the absolute difference between pooled-grid Shannon
#' entropies of Sturges-binned FDC values.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' flow_duration_entropy(c(1, 2, 3, 7, 8, 4), c(1, 2, 4, 8, 7, 5))
#' @export
flow_duration_entropy <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("flow_duration_entropy", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the tail dependence score wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"tail_dependence_score"`. The metric uses the observed type-7 `0.9`
#' quantile as a strict upper-tail threshold and reports the empirical
#' conditional exceedance score `P(sim > q_obs | obs > q_obs)`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' tail_dependence_score(c(1, 2, 3, 7, 8, 4), c(1, 2, 4, 8, 7, 5))
#' @export
tail_dependence_score <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("tail_dependence_score", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the extreme event ratio wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"extreme_event_ratio"`. Extreme events are contiguous runs strictly above
#' the observed type-7 `0.9` quantile threshold, counted separately in sim and
#' obs using the same observed threshold; the score is `n_sim / n_obs`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' extreme_event_ratio(c(1, 2, 3, 7, 8, 4), c(1, 2, 4, 8, 7, 5))
#' @export
extreme_event_ratio <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("extreme_event_ratio", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the rank turnover score wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"rank_turnover_score"`. The metric compares average ranks with
#' `ties.method = "average"` and returns the mean absolute rank difference
#' normalized by the reversed-order maximum for the current length.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' rank_turnover_score(c(1, 4, 2, 8, 5, 7), c(1, 2, 3, 4, 5, 6))
#' @export
rank_turnover_score <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("rank_turnover_score", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the distribution overlap wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"distribution_overlap"`. The metric uses pooled-support Sturges histograms
#' and reports the overlap coefficient `sum(min(p_sim, p_obs))`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' distribution_overlap(c(1, 4, 2, 8, 5, 7), c(1, 2, 3, 4, 5, 6))
#' @export
distribution_overlap <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("distribution_overlap", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the quantile shift index wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"quantile_shift_index"`. The metric uses type-7 quantiles on the fixed
#' grid `p = 0.1, ..., 0.9`, computes the mean absolute quantile difference,
#' and scales it by `IQR(obs)`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' quantile_shift_index(c(1, 4, 2, 8, 5, 7), c(1, 2, 3, 4, 5, 6))
#' @export
quantile_shift_index <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("quantile_shift_index", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the seasonal skill wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"seasonal_skill"`. The metric requires monthly seasonality that can be
#' inferred from a monthly `ts` input or from aligned date-like indices, then
#' computes an NSE-style skill score on the 12 monthly climatology means.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' sim <- ts(rep(c(10, 12, 9, 8, 7, 6, 5, 6, 7, 8, 9, 11), 2), frequency = 12)
#' obs <- ts(rep(c(9, 11, 10, 8, 6, 6, 5, 5, 8, 8, 10, 10), 2), frequency = 12)
#' seasonal_skill(sim, obs)
#' @export
seasonal_skill <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("seasonal_skill", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
