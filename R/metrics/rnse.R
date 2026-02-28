metric_rnse <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rNSE undefined because obs contains zero.", call. = FALSE)
  }
  rel <- (sim - obs) / obs
  den <- sum(((obs - mean(obs)) / obs)^2)
  if (den == 0) {
    stop("rNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - sum(rel^2) / den
}

core_metric_spec_rnse <- function() {
  list(
    id = "rnse",
    fun = metric_rnse,
    name = "Relative NSE",
    description = "Relative NSE using observation-scaled errors.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE relative variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
