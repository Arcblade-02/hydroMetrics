#' Evaluate the legacy NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"nse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' NSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
NSeff <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "nse", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
