#' Evaluate the legacy NSE wrapper
#'
#' Compatibility export retained for legacy hydroGOF-style wrapper continuity.
#' This thin wrapper delegates to [gof()] for the registry metric `"nse"`.
#' It inherits NA handling, input-shape checks, and undefined-domain failures
#' from [gof()] and the canonical `"nse"` metric.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs. The documented return shape and failure behavior are
#'   preserved as part of the compatibility contract.
#'
#' @examples
#' NSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
NSeff <- function(sim, obs, na.rm = NULL, ...) {
  .hm_run_single_metric_wrapper("nse", sim = sim, obs = obs, na.rm = na.rm, dots = list(...))
}
