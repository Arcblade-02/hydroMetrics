validate_non_constant_series <- function(sim, obs, metric_id) {
  sd_sim <- stats::sd(sim)
  sd_obs <- stats::sd(obs)

  if (is.na(sd_sim) || is.na(sd_obs) || sd_sim == 0 || sd_obs == 0) {
    stop(sprintf("%s is undefined for constant series.", metric_id), call. = FALSE)
  }
}

metric_r2 <- function(sim, obs) {
  validate_non_constant_series(sim, obs, "R2")
  stats::cor(sim, obs)^2
}

core_metric_spec_r2 <- function() {
  list(
    id = "r2",
    fun = metric_r2,
    name = "Squared Pearson Correlation",
    description = "R2 defined as squared Pearson correlation cor(sim, obs)^2.",
    category = "correlation",
    perfect = 1,
    range = c(0, 1),
    references = "R-squared defined as squared Pearson correlation.",
    version_added = "0.1.0",
    tags = character()
  )
}
