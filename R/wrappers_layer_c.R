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
