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
#' Deprecated forwarding wrapper for [mutual_information()].
#'
#' `mutual_information_score()` remains exported temporarily for compatibility,
#' but `"mutual_information_score"` is no longer a live canonical registry
#' metric id. Each call warns once and then forwards directly to canonical
#' [mutual_information()], which computes raw mutual information in
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
  warning(
    "`mutual_information_score()` is deprecated; use `mutual_information()`.",
    call. = FALSE
  )
  mutual_information(sim = sim, obs = obs, na.rm = na.rm, ...)
}

#' Evaluate the mutual information wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"mutual_information"`. Under the current deterministic policy this is the
#' canonical name for the same pooled-grid raw mutual information formerly
#' exposed through deprecated wrapper [mutual_information_score()]. The
#' estimator uses a pooled-support Sturges histogram on the paired joint
#' empirical distribution and reports the result in natural-log units.
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

#' Evaluate the upper-tail conditional exceedance wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"upper_tail_conditional_exceedance"`. The metric uses the observed type-7
#' `0.9` quantile as a strict upper-tail threshold and reports the empirical
#' conditional exceedance score `P(sim > q_obs | obs > q_obs)`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' upper_tail_conditional_exceedance(c(1, 2, 3, 7, 8, 4), c(1, 2, 4, 8, 7, 5))
#' @export
upper_tail_conditional_exceedance <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper(
    "upper_tail_conditional_exceedance",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...)
  )
}

#' Evaluate the tail dependence score wrapper
#'
#' Deprecated forwarding wrapper for [upper_tail_conditional_exceedance()].
#'
#' `tail_dependence_score()` remains exported temporarily for compatibility,
#' but `"tail_dependence_score"` is no longer a live canonical registry metric
#' id. Each call warns once and then forwards directly to canonical
#' [upper_tail_conditional_exceedance()].
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
  warning(
    "`tail_dependence_score()` is deprecated; use `upper_tail_conditional_exceedance()`.",
    call. = FALSE
  )
  upper_tail_conditional_exceedance(sim = sim, obs = obs, na.rm = na.rm, ...)
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

#' Evaluate the composite performance index wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"composite_performance_index"`. The metric is a fixed equal-weight
#' composite of normalized `nse`, `kge`, `rmse`, `pbias`, `r`, `mae`, `rsr`,
#' and `ve` component scores computed on the same aligned prepared data.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' composite_performance_index(c(1.2, 1.8, 3.4, 3.9, 5.1), c(1.0, 2.0, 3.0, 4.0, 5.0))
#' @export
composite_performance_index <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper(
    "composite_performance_index",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...)
  )
}

#' Evaluate the extended validation index wrapper
#'
#' Deprecated forwarding wrapper for [composite_performance_index()].
#'
#' `extended_valindex()` remains exported temporarily for compatibility, but
#' `"extended_valindex"` is no longer a live canonical registry metric id.
#' Each call warns once and then forwards directly to canonical
#' [composite_performance_index()].
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' extended_valindex(c(1.2, 1.8, 3.4, 3.9, 5.1), c(1.0, 2.0, 3.0, 4.0, 5.0))
#' @export
extended_valindex <- function(sim, obs, na.rm = NULL, ...) {
  warning(
    "`extended_valindex()` is deprecated; use `composite_performance_index()`.",
    call. = FALSE
  )
  composite_performance_index(sim = sim, obs = obs, na.rm = na.rm, ...)
}
