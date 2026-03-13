#' Evaluate the Pearson correlation wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"r"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' r(c(1, 2, 3), c(1, 2, 4))
#' @export
r <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("r", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
