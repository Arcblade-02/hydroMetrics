#' Evaluate the legacy modified NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mnse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
mNSeff <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "mnse", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
