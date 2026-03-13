#' Evaluate the mean absolute error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mae"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mae(c(1, 2, 3), c(1, 3, 2))
#' @export
mae <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("mae", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
