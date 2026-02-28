metric_br2 <- function(sim, obs) {
  sd_sim <- stats::sd(sim)
  sd_obs <- stats::sd(obs)
  mean_sim <- mean(sim)
  mean_obs <- mean(obs)

  if (sd_sim == 0 || sd_obs == 0) {
    stop("br2 undefined because sd == 0.", call. = FALSE)
  }
  if (mean_sim == 0 || mean_obs == 0) {
    stop("br2 undefined because mean == 0.", call. = FALSE)
  }

  r <- stats::cor(sim, obs)
  if (is.na(r)) {
    stop("br2 undefined because cor(sim, obs) is NA.", call. = FALSE)
  }

  sd_penalty <- min(sd_sim, sd_obs) / max(sd_sim, sd_obs)
  mean_penalty <- min(mean_sim, mean_obs) / max(mean_sim, mean_obs)

  (r^2) * (sd_penalty^2) * (mean_penalty^2)
}

core_metric_spec_br2 <- function() {
  list(
    id = "br2",
    fun = metric_br2,
    name = "Bias-Corrected R-squared",
    description = "Bias-penalized Pearson r^2 using variability and mean-ratio penalties.",
    category = "correlation",
    perfect = 1,
    range = c(0, 1),
    references = "Project-defined bias-corrected R2 variant pending dedicated paper citation.",
    version_added = "0.1.0",
    tags = character()
  )
}
