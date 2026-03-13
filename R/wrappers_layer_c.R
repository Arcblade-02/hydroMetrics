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
