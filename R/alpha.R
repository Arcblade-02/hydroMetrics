#' Evaluate the alpha metric wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"alpha"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' alpha(c(1, 2, 3), c(1, 2, 4))
#' @export
alpha <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("alpha", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
