metric_cp <- function(sim, obs) {
  if (length(obs) < 2) {
    stop("cp requires at least 2 observations.", call. = FALSE)
  }

  obs_t <- obs[-1]
  sim_t <- sim[-1]
  obs_lag <- obs[-length(obs)]

  num <- sum((obs_t - sim_t)^2)
  den <- sum((obs_t - obs_lag)^2)

  if (den == 0) {
    stop("cp is undefined because persistence baseline variance is zero.", call. = FALSE)
  }

  1 - num / den
}

core_metric_spec_cp <- function() {
  list(
    id = "cp",
    fun = metric_cp,
    name = "Coefficient of Persistence",
    description = "Persistence skill score against one-step observed persistence baseline.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Persistence skill-score definition from hydrology model-evaluation literature.",
    version_added = "0.1.0",
    tags = character()
  )
}
