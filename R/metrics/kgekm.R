metric_kgekm <- function(sim, obs) {
  mean_sim <- mean(sim)
  mean_obs <- mean(obs)
  sd_obs <- stats::sd(obs)

  if (mean_sim == 0 || mean_obs == 0) {
    stop("KGEkm undefined because mean(sim) == 0 or mean(obs) == 0.", call. = FALSE)
  }
  if (sd_obs == 0) {
    stop("KGEkm undefined because sd(obs) == 0.", call. = FALSE)
  }

  r <- stats::cor(sim, obs)
  if (is.na(r)) {
    stop("KGEkm undefined because cor(sim, obs) is NA.", call. = FALSE)
  }

  cv_sim <- stats::sd(sim) / mean_sim
  cv_obs <- sd_obs / mean_obs
  gamma <- cv_sim / cv_obs
  beta <- mean_sim / mean_obs

  1 - sqrt((r - 1)^2 + (gamma - 1)^2 + (beta - 1)^2)
}

core_metric_spec_kgekm <- function() {
  list(
    id = "kgekm",
    fun = metric_kgekm,
    name = "KGE Modified Variability",
    description = "KGE variant using gamma = CV(sim)/CV(obs) and beta = mean(sim)/mean(obs).",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "KGE variant definitions in hydrology practice using coefficient-of-variation ratio; citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
