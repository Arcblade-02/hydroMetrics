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

#' Evaluate the square-root NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"sqrt_nse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' sqrt_nse(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
sqrt_nse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("sqrt_nse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the seasonal NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"seasonal_nse"`.
#' This metric requires monthly seasonality that can be inferred from a monthly
#' `ts` series or from aligned date-like indexed input.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' sim <- ts(rep(c(10, 12, 9, 8, 7, 6, 5, 6, 7, 8, 9, 11), 2), frequency = 12)
#' obs <- ts(rep(c(9, 11, 10, 8, 6, 6, 5, 5, 8, 8, 10, 10), 2), frequency = 12)
#' seasonal_nse(sim, obs)
#' @export
seasonal_nse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("seasonal_nse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the weighted KGE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"weighted_kge"`.
#'
#' @inheritParams gof
#' @param w_r Positive weight applied to the correlation component deviation.
#'   The stable package default is `1`.
#' @param w_alpha Positive weight applied to the variability-ratio component
#'   deviation. The stable package default is `1`.
#' @param w_beta Positive weight applied to the bias-ratio component deviation.
#'   The stable package default is `1`.
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' weighted_kge(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
weighted_kge <- function(sim, obs, w_r = 1, w_alpha = 1, w_beta = 1, na.rm = NULL, ...) {
  .hm_b2_validate_positive_weight(w_r, "w_r")
  .hm_b2_validate_positive_weight(w_alpha, "w_alpha")
  .hm_b2_validate_positive_weight(w_beta, "w_beta")

  .hm_run_single_metric_param_wrapper(
    "weighted_kge",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...),
    params = list(
      w_r = as.numeric(w_r),
      w_alpha = as.numeric(w_alpha),
      w_beta = as.numeric(w_beta)
    )
  )
}

#' Evaluate the quantile KGE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"quantile_kge"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' quantile_kge(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
quantile_kge <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("quantile_kge", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the hydrograph slope error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"hydrograph_slope_error"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' hydrograph_slope_error(c(1, 2, 4, 7), c(1, 2, 3, 6))
#' @export
hydrograph_slope_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("hydrograph_slope_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the derivative NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"derivative_nse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' derivative_nse(c(1, 2, 4, 7), c(1, 2, 3, 6))
#' @export
derivative_nse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("derivative_nse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the peak timing error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"peak_timing_error"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' peak_timing_error(c(1, 2, 4, 7), c(1, 2, 3, 6))
#' @export
peak_timing_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("peak_timing_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the rising limb error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"rising_limb_error"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' rising_limb_error(c(1, 2, 4, 7), c(1, 2, 3, 6))
#' @export
rising_limb_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("rising_limb_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the recession constant error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"recession_constant"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' recession_constant(c(1, 2, 5, 4, 3, 2), c(1, 2, 6, 5, 4, 3))
#' @export
recession_constant <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("recession_constant", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the baseflow index error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric
#' `"baseflow_index_error"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' baseflow_index_error(c(1, 2, 5, 4, 3, 2), c(1, 2, 6, 5, 4, 3))
#' @export
baseflow_index_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("baseflow_index_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the event NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"event_nse"`.
#' Observed event windows are defined as contiguous runs of observed values
#' strictly above the observed 0.8 quantile and the score is computed as NSE on
#' the pooled observed event windows.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' obs <- c(1, 2, 5, 6, 2, 1, 1, 4, 5, 2, 1, 1)
#' sim <- c(1, 2, 4, 7, 2, 1, 1, 3, 6, 2, 1, 1)
#' event_nse(sim, obs)
#' @export
event_nse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("event_nse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
