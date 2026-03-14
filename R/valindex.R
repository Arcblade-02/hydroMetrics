#' Evaluate selected metrics through valindex
#'
#' Stable orchestration entry point retained under historical naming. It
#' forwards `fun` to [gof()] as `methods`.
#'
#' @inheritParams gof
#' @param fun Character vector of metric names to evaluate.
#'
#' @return A `"hydro_metrics"` object returned by [gof()]. The documented
#'   return class, output shape, and warning/error behavior are inherited from
#'   [gof()] as part of the stable public contract.
#'
#' @examples
#' valindex(c(1, 2, 3), c(1, 2, 2), fun = c("NSE", "rmse"))
#' @export
valindex <- function(sim, obs, fun = NULL, na.rm = NULL, ...) {
  if (is.null(fun) || !is.character(fun) || length(fun) == 0L || any(!nzchar(fun))) {
    stop("`fun` must be provided as a non-empty character vector.", call. = FALSE)
  }

  gof(sim = sim, obs = obs, methods = fun, na.rm = na.rm, ...)
}
