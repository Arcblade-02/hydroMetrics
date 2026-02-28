metric_wnse <- function(sim, obs) {
  if (any(obs < 0)) {
    stop("wNSE undefined because obs contains negative values (weights must be nonnegative).", call. = FALSE)
  }
  obs_mean <- mean(obs)
  num <- sum(obs * (sim - obs)^2)
  den <- sum(obs * (obs - obs_mean)^2)
  if (den == 0) {
    stop("wNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - num / den
}

core_metric_spec_wnse <- function() {
  list(
    id = "wnse",
    fun = metric_wnse,
    name = "Weighted NSE",
    description = "Weighted NSE using observation weights w = obs.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE weighted variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
