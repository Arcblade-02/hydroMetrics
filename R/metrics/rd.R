metric_rd <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rd undefined because obs contains zero.", call. = FALSE)
  }
  obs_mean <- mean(obs)
  rel_err <- (sim - obs) / obs
  denom <- sum((abs((sim - obs_mean) / obs) + abs((obs - obs_mean) / obs))^2)
  if (denom == 0) {
    stop("rd is undefined (denominator is 0).", call. = FALSE)
  }
  1 - sum(rel_err^2) / denom
}

core_metric_spec_rd <- function() {
  list(
    id = "rd",
    fun = metric_rd,
    name = "Relative Index of Agreement",
    description = "Relative squared-error agreement index using obs-normalized terms.",
    category = "agreement",
    perfect = 1,
    range = NULL,
    references = "Willmott agreement-index family with relative normalization by observations.",
    version_added = "0.1.0",
    tags = character()
  )
}
