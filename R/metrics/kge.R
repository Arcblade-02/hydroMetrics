metric_kge <- function(sim, obs) {
  obs_sd <- stats::sd(obs)
  obs_mean <- mean(obs)
  sim_sd <- stats::sd(sim)

  if (obs_sd == 0) {
    stop("KGE undefined because sd(obs) == 0.", call. = FALSE)
  }
  if (obs_mean == 0) {
    stop("KGE undefined because mean(obs) == 0.", call. = FALSE)
  }
  if (sim_sd == 0) {
    stop("KGE undefined for constant sim series.", call. = FALSE)
  }

  r <- stats::cor(sim, obs)
  alpha <- sim_sd / obs_sd
  beta <- mean(sim) / obs_mean
  1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)
}

core_metric_spec_kge <- function() {
  list(
    id = "kge",
    fun = metric_kge,
    name = "Kling-Gupta Efficiency",
    description = "KGE (2009) using r, alpha=sd(sim)/sd(obs), and beta=mean(sim)/mean(obs).",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios.",
    version_added = "0.1.0",
    tags = character()
  )
}
