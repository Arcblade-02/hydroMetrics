metric_dr <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("dr undefined because obs contains zero.", call. = FALSE)
  }
  obs_mean <- mean(obs)
  rel_abs <- abs(sim - obs) / abs(obs)
  denom <- sum(abs(sim - obs_mean) / abs(obs) + abs(obs - obs_mean) / abs(obs))
  if (denom == 0) {
    stop("dr is undefined (denominator is 0).", call. = FALSE)
  }
  1 - sum(rel_abs) / denom
}

core_metric_spec_dr <- function() {
  list(
    id = "dr",
    fun = metric_dr,
    name = "Relative Absolute Index of Agreement",
    description = "Relative absolute-error agreement index using obs-normalized terms.",
    category = "agreement",
    perfect = 1,
    range = NULL,
    references = "Willmott agreement-index family with relative absolute-error normalization.",
    version_added = "0.1.0",
    tags = character()
  )
}
