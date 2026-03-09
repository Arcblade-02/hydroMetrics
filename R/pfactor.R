pfactor <- function(sim, obs, tol = 0.10, na.rm = TRUE, ...) {
  dots <- list(...)
  metric_params <- dots$metric_params
  if (is.null(metric_params)) {
    metric_params <- list()
  }
  pfactor_params <- metric_params$pfactor
  if (is.null(pfactor_params)) {
    pfactor_params <- list()
  }
  pfactor_params$tol <- tol
  metric_params$pfactor <- pfactor_params
  dots$metric_params <- metric_params

  out <- do.call(
    gof,
    c(
      list(sim = sim, obs = obs, methods = "pfactor", na.rm = na.rm),
      dots
    )
  )
  values <- out$pfactor
  if (length(values) == 1L) {
    return(as.numeric(values))
  }
  values
}
