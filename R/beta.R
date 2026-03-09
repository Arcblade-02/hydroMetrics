#' Evaluate the beta metric wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"beta"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' beta(c(1, 2, 3), c(1, 1, 3))
#' @export
beta <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "beta", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
