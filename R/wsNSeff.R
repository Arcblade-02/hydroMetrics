#' Evaluate the legacy weighted-squared NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"wsnse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' wsNSeff(c(1, 2, 3), c(1, 2, 2))
#' @export
wsNSeff <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "wsnse", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
