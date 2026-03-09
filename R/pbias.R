#' Evaluate the percent bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"pbias"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' pbias(c(1, 2, 3), c(1, 2, 4))
#' @export
pbias <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "pbias", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
