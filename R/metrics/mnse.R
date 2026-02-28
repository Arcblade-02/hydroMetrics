metric_mnse <- function(sim, obs) {
  num <- sum(abs(sim - obs))
  den <- sum(abs(obs - mean(obs)))
  if (den == 0) {
    stop("mNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - num / den
}

core_metric_spec_mnse <- function() {
  list(
    id = "mnse",
    fun = metric_mnse,
    name = "Modified NSE",
    description = "Modified NSE using absolute-error numerator and denominator.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE modified variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
