#' Evaluate the Pearson correlation wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"r"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' r(c(1, 2, 3), c(1, 2, 4))
#' @export
r <- function(sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = "r", na.rm = na.rm, ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
