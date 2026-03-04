valindex <- function(sim, obs, fun = NULL, ...) {
  if (is.null(fun) || !is.character(fun) || length(fun) == 0L || any(!nzchar(fun))) {
    stop("`fun` must be provided as a non-empty character vector.", call. = FALSE)
  }

  gof(sim = sim, obs = obs, methods = fun, ...)
}
