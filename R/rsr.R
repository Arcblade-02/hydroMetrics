#' Evaluate the RSR wrapper
#'
#' Thin exported wrapper over [gof()] for the canonical registry metric
#' `"rsr"`. Deprecated alias `"nrmse_sd"` resolves to this canonical metric
#' during orchestration and engine evaluation.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' rsr(c(1, 2, 3), c(1, 2, 4))
#' @export
rsr <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("rsr", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
