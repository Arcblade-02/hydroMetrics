#' Evaluate the beta metric wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"beta"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' beta(c(1, 2, 3), c(1, 1, 3))
#' @export
beta <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("beta", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
