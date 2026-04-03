#' Evaluate the percent bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"pbias"`.
#' The implemented sign convention is `100 * sum(sim - obs) / sum(obs)`, so
#' positive values indicate overestimation relative to `obs`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' pbias(c(1, 2, 3), c(1, 2, 4))
#' @export
pbias <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("pbias", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
