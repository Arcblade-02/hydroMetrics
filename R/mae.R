#' Evaluate the mean absolute error wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mae"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' mae(c(1, 2, 3), c(1, 3, 2))
#' @export
mae <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "mae", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
