NSeff <- function(sim, obs, ...) {
  out <- gof(sim = sim, obs = obs, methods = "nse", ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
