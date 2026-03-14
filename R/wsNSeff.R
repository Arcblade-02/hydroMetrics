#' Evaluate the legacy weighted-squared NSE wrapper
#'
#' Compatibility export retained for legacy hydroGOF-style wrapper continuity.
#' This thin wrapper delegates to [gof()] for the registry metric `"wsnse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs. The documented return shape and failure behavior are
#'   preserved as part of the compatibility contract.
#'
#' @examples
#' wsNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
wsNSeff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("wsnse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
