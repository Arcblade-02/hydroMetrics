#' Evaluate the RSR wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"rsr"`.
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
  out <- gof(sim = sim, obs = obs, methods = "rsr", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
