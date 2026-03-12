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
