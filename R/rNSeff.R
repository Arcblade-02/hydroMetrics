#' Evaluate the legacy relative NSE wrapper
#'
#' Compatibility export retained for legacy hydroGOF-style wrapper continuity.
#' This thin wrapper delegates to [gof()] for the registry metric `"rnse"`.
#' It inherits NA handling, input-shape checks, and the canonical `"rnse"`
#' zero-observation and denominator guards from [gof()].
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs. The documented return shape and failure behavior are
#'   preserved as part of the compatibility contract.
#'
#' @examples
#' rNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
rNSeff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("rnse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
