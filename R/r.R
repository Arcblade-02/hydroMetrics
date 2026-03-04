r <- function(sim, obs, ...) {
  out <- gof(sim = sim, obs = obs, methods = "r", ...)
  if (is.matrix(out)) {
    return(out)
  }
  as.numeric(out[[1]])
}
