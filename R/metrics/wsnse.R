metric_wsnse <- function(sim, obs) {
  if (any(obs < 0)) {
    stop("wsNSE undefined because obs contains negative values (weights must be nonnegative).", call. = FALSE)
  }
  obs_mean <- mean(obs)
  w <- obs^2
  num <- sum(w * (sim - obs)^2)
  den <- sum(w * (obs - obs_mean)^2)
  if (den == 0) {
    stop("wsNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - num / den
}

core_metric_spec_wsnse <- function() {
  list(
    id = "wsnse",
    fun = metric_wsnse,
    name = "Weighted Squared NSE",
    description = "Weighted NSE variant using squared observation weights w = obs^2.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE weighted variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
