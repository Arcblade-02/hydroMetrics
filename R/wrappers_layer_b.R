#' Evaluate the Kolmogorov-Smirnov statistic wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"ks_statistic"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' ks_statistic(c(1, 2, 4), c(1, 3, 2))
#' @export
ks_statistic <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("ks_statistic", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the empirical CDF RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"cdf_rmse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' cdf_rmse(c(1, 2, 4), c(1, 3, 2))
#' @export
cdf_rmse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("cdf_rmse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the quantile deviation wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"quantile_deviation"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' quantile_deviation(c(1, 2, 4), c(1, 3, 2))
#' @export
quantile_deviation <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("quantile_deviation", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the flow-duration-curve shape distance wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"fdc_shape_distance"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' fdc_shape_distance(c(1, 2, 4), c(1, 3, 2))
#' @export
fdc_shape_distance <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("fdc_shape_distance", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the Anderson-Darling distribution statistic wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"anderson_darling_stat"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' anderson_darling_stat(c(1, 2, 4), c(1, 3, 2))
#' @export
anderson_darling_stat <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("anderson_darling_stat", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the one-dimensional Wasserstein distance wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"wasserstein_distance"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' wasserstein_distance(c(1, 2, 4), c(1, 3, 2))
#' @export
wasserstein_distance <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("wasserstein_distance", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
