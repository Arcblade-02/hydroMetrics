metric_md <- function(sim, obs) {
  obs_mean <- mean(obs)
  denom <- sum(abs(sim - obs_mean) + abs(obs - obs_mean))
  if (denom == 0) {
    stop("md is undefined (denominator is 0; constant series).", call. = FALSE)
  }
  1 - sum(abs(sim - obs)) / denom
}

core_metric_spec_md <- function() {
  list(
    id = "md",
    fun = metric_md,
    name = "Modified Index of Agreement",
    description = "Modified Willmott agreement index using absolute deviations.",
    category = "agreement",
    perfect = 1,
    range = NULL,
    references = "Willmott, C.J., Robeson, S.M., & Matsuura, K. (2012). A refined index of model performance.",
    version_added = "0.1.0",
    tags = character()
  )
}
