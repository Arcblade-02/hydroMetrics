metric_alpha <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("alpha requires at least 2 values.", call. = FALSE)
  }

  obs_sd <- stats::sd(obs)
  if (obs_sd == 0) {
    stop("sd(obs) is zero; alpha undefined", call. = FALSE)
  }

  stats::sd(sim) / obs_sd
}

core_metric_spec_alpha <- function() {
  list(
    id = "alpha",
    fun = metric_alpha,
    name = "Variability Ratio",
    description = "Alpha component computed as sd(sim) / sd(obs).",
    category = "scale",
    perfect = 1,
    range = c(0, Inf),
    references = "KGE component definition in hydrology literature using variability ratio sd(sim)/sd(obs).",
    version_added = "0.1.0",
    tags = c("kge-component")
  )
}
