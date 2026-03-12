#' Evaluate the legacy modified NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mnse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
mNSeff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("mnse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
