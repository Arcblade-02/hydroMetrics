metric_d <- function(sim, obs) {
  obs_mean <- mean(obs)
  denom <- sum((abs(sim - obs_mean) + abs(obs - obs_mean))^2)
  if (denom == 0) {
    stop("d is undefined (denominator is 0; constant series).", call. = FALSE)
  }
  1 - sum((sim - obs)^2) / denom
}

core_metric_spec_d <- function() {
  list(
    id = "d",
    fun = metric_d,
    name = "Willmott Index of Agreement",
    description = "Willmott d (1981) using squared-error agreement formulation.",
    category = "agreement",
    perfect = 1,
    range = c(0, 1),
    references = "Willmott, C.J. (1981). On the validation of models.",
    version_added = "0.1.0",
    tags = character()
  )
}
