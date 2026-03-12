rfactor <- function(sim, obs, na.rm = TRUE, ...) {
  out <- gof(sim = sim, obs = obs, methods = "rfactor", na.rm = na.rm, ...)
  values <- out[["rfactor"]]
  if (length(values) == 1L) {
    return(as.numeric(values))
  }
  values
}
