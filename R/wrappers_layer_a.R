#' Evaluate the median absolute error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mdae"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mdae(c(1, 2, 4), c(1, 3, 2))
#' @export
mdae <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("mdae", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the maximum absolute error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"maxae"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' maxae(c(1, 2, 4), c(1, 3, 2))
#' @export
maxae <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("maxae", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the relative bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"rbias"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' rbias(c(1.2, 1.8, 3.1), c(1, 2, 3))
#' @export
rbias <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("rbias", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the concordance correlation coefficient wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"ccc"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' ccc(c(1, 2, 3), c(1, 2, 4))
#' @export
ccc <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("ccc", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the modified coefficient of efficiency wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"e1"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' e1(c(1, 2, 4), c(1, 3, 2))
#' @export
e1 <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("e1", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the relative root mean squared error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"rrmse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' rrmse(c(1.2, 1.8, 3.1), c(1, 2, 3))
#' @export
rrmse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("rrmse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the symmetric mean absolute percentage error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"smape"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' smape(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
smape <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("smape", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the mean absolute relative error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mare"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mare(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
mare <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("mare", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the mean relative bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mrb"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mrb(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
mrb <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("mrb", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the log-transformed RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"log_rmse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' log_rmse(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
log_rmse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("log_rmse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the mean squared logarithmic error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"msle"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' msle(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
msle <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("msle", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the log-transformed NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"log_nse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' log_nse(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
log_nse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("log_nse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the range-normalized RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"nrmse_range"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' nrmse_range(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
nrmse_range <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("nrmse_range", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the flow-duration-curve slope error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"fdc_slope_error"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' fdc_slope_error(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
fdc_slope_error <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("fdc_slope_error", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the flow-duration-curve high-flow bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"fdc_highflow_bias"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' fdc_highflow_bias(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
fdc_highflow_bias <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("fdc_highflow_bias", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the flow-duration-curve low-flow bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"fdc_lowflow_bias"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' fdc_lowflow_bias(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
fdc_lowflow_bias <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("fdc_lowflow_bias", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the log flow-duration-curve RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"log_fdc_rmse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' log_fdc_rmse(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
log_fdc_rmse <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("log_fdc_rmse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the low-flow bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"low_flow_bias"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' low_flow_bias(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
low_flow_bias <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("low_flow_bias", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

#' Evaluate the seasonal bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"seasonal_bias"`.
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
#' seasonal_bias(sim, obs)
#' @export
seasonal_bias <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("seasonal_bias", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}

.hm_run_single_metric_param_wrapper <- function(metric_id, sim, obs, na.rm = NULL, dots = list(), params = list()) {
  dots <- .hm_scalar_sanitize_dots(dots)
  dots <- .hm_merge_metric_params(
    dots = dots,
    metric_id = metric_id,
    params = params
  )

  out <- do.call(
    gof,
    c(
      list(sim = sim, obs = obs, methods = metric_id, na.rm = na.rm),
      dots
    )
  )

  if (is.matrix(out)) {
    return(out[metric_id, , drop = TRUE])
  }

  as.numeric(out[[metric_id]])
}

#' Evaluate the mean Huber loss wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"huber_loss"`.
#'
#' @inheritParams gof
#' @param delta Positive Huber threshold. The stable package default is `1`.
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' huber_loss(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
huber_loss <- function(sim, obs, delta = 1, na.rm = NULL, ...) {
  .hm_validate_huber_delta(delta)
  .hm_run_single_metric_param_wrapper(
    "huber_loss",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...),
    params = list(delta = as.numeric(delta))
  )
}

#' Evaluate the mean quantile loss wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"quantile_loss"`.
#'
#' @inheritParams gof
#' @param tau Quantile level used in the pinball loss. The stable package
#'   default is `0.5`.
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' quantile_loss(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
quantile_loss <- function(sim, obs, tau = 0.5, na.rm = NULL, ...) {
  .hm_validate_quantile_tau(tau)
  .hm_run_single_metric_param_wrapper(
    "quantile_loss",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...),
    params = list(tau = as.numeric(tau))
  )
}

#' Evaluate the trimmed RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"trimmed_rmse"`.
#'
#' @inheritParams gof
#' @param trim Symmetric trimming fraction applied to the signed residual
#'   distribution before RMSE calculation. The stable package default is `0.2`.
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' trimmed_rmse(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
trimmed_rmse <- function(sim, obs, trim = 0.2, na.rm = NULL, ...) {
  .hm_validate_fraction_01(trim, "trim")
  .hm_run_single_metric_param_wrapper(
    "trimmed_rmse",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...),
    params = list(trim = as.numeric(trim))
  )
}

#' Evaluate the winsorized RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"winsor_rmse"`.
#'
#' @inheritParams gof
#' @param winsor Symmetric winsorization fraction applied to the signed residual
#'   distribution before RMSE calculation. The stable package default is `0.2`.
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' winsor_rmse(c(1.2, 1.8, 3.4), c(1, 2, 3))
#' @export
winsor_rmse <- function(sim, obs, winsor = 0.2, na.rm = NULL, ...) {
  .hm_validate_fraction_01(winsor, "winsor")
  .hm_run_single_metric_param_wrapper(
    "winsor_rmse",
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    dots = list(...),
    params = list(winsor = as.numeric(winsor))
  )
}

#' Evaluate the empirical ensemble CRPS
#'
#' `crps()` computes the empirical continuous ranked probability score for
#' ensemble forecasts. In Batch A5 it supports only numeric ensemble matrices
#' with rows as forecast cases and columns as ensemble members.
#'
#' @param sim Numeric matrix of ensemble forecasts with rows = cases and
#'   columns = ensemble members.
#' @param obs Numeric vector of observed outcomes with length `nrow(sim)`.
#'
#' @return A numeric scalar.
#'
#' @examples
#' ens <- matrix(c(1.0, 1.2, 0.8, 2.0, 2.2, 1.8), nrow = 2, byrow = TRUE)
#' crps(ens, c(1.1, 2.1))
#' @export
crps <- function(sim, obs) {
  metric_crps(sim, obs)
}

#' Evaluate prediction interval coverage probability
#'
#' `picp()` computes inclusive interval coverage for deterministic lower and
#' upper predictive bounds.
#'
#' @param lower Numeric vector of lower predictive bounds.
#' @param upper Numeric vector of upper predictive bounds.
#' @param obs Numeric vector of observed outcomes.
#'
#' @return A numeric scalar.
#'
#' @examples
#' picp(c(0.9, 1.9), c(1.3, 2.3), c(1.1, 2.1))
#' @export
picp <- function(lower, upper, obs) {
  metric_picp(lower, obs, upper = upper)
}

#' Evaluate mean width of prediction intervals
#'
#' `mwpi()` computes the mean interval width `upper - lower` across all
#' supplied predictive intervals.
#'
#' @param lower Numeric vector of lower predictive bounds.
#' @param upper Numeric vector of upper predictive bounds.
#'
#' @return A numeric scalar.
#'
#' @examples
#' mwpi(c(0.9, 1.9), c(1.3, 2.3))
#' @export
mwpi <- function(lower, upper) {
  metric_mwpi(lower, upper)
}

#' Evaluate a lower-is-better skill score
#'
#' `skill_score()` computes relative improvement against a baseline score using
#' `1 - mean(score) / mean(baseline_score)`.
#'
#' @param score Numeric scalar or vector of forecast scores where lower is
#'   better.
#' @param baseline_score Numeric scalar or vector of reference scores with the
#'   same length as `score`.
#'
#' @return A numeric scalar.
#'
#' @examples
#' skill_score(score = 0.8, baseline_score = 1.0)
#' @export
skill_score <- function(score, baseline_score) {
  metric_skill_score(score, baseline_score)
}
