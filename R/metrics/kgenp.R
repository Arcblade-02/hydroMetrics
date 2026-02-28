metric_kgenp <- function(sim, obs) {
  iqr_obs <- stats::IQR(obs)
  median_obs <- stats::median(obs)

  if (iqr_obs == 0) {
    stop("KGEnp undefined because IQR(obs) == 0.", call. = FALSE)
  }
  if (median_obs == 0) {
    stop("KGEnp undefined because median(obs) == 0.", call. = FALSE)
  }

  r <- stats::cor(sim, obs, method = "spearman")
  if (is.na(r)) {
    stop("KGEnp undefined because Spearman correlation is NA.", call. = FALSE)
  }

  alpha <- stats::IQR(sim) / iqr_obs
  beta <- stats::median(sim) / median_obs

  1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)
}

core_metric_spec_kgenp <- function() {
  list(
    id = "kgenp",
    fun = metric_kgenp,
    name = "KGE Nonparametric",
    description = "Nonparametric KGE using Spearman correlation, IQR ratio, and median ratio.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nonparametric KGE formulations in hydrology practice; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
