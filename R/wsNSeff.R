#' Evaluate the legacy weighted-squared NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"wsnse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' wsNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
wsNSeff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("wsnse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
