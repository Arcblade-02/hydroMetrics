validate_non_constant_series <- function(sim, obs, metric_id) {
  sd_sim <- stats::sd(sim)
  sd_obs <- stats::sd(obs)

  if (is.na(sd_sim) || is.na(sd_obs) || sd_sim == 0 || sd_obs == 0) {
    stop(sprintf("%s is undefined for constant series.", metric_id), call. = FALSE)
  }
}

metric_r <- function(sim, obs) {
  validate_non_constant_series(sim, obs, "R")
  stats::cor(sim, obs)
}

core_metric_spec_r <- function() {
  list(
    id = "r",
    fun = metric_r,
    name = "Pearson Correlation",
    description = "Pearson product-moment correlation coefficient between sim and obs.",
    category = "correlation",
    perfect = 1,
    range = c(-1, 1),
    references = "Pearson correlation coefficient (standard definition).",
    version_added = "0.1.0",
    tags = character()
  )
}
