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
