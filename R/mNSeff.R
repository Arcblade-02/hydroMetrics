#' Evaluate the legacy modified NSE wrapper
#'
#' Compatibility export retained for legacy hydroGOF-style wrapper continuity.
#' This thin wrapper delegates to [gof()] for the registry metric `"mnse"`.
#' It inherits NA handling, input-shape checks, and denominator/domain
#' failures from [gof()] and the canonical `"mnse"` metric.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs. The documented return shape and failure behavior are
#'   preserved as part of the compatibility contract.
#'
#' @examples
#' mNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
mNSeff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("mnse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
