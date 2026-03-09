#' Evaluate the legacy relative NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"rnse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' rNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
rNSeff <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "rnse", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
