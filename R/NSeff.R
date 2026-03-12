#' Evaluate the legacy NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"nse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' NSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
NSeff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("nse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
