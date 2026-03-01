metric_rsd <- function(sim, obs) {
  sd_obs <- stats::sd(obs)
  if (sd_obs == 0) {
    stop("rSD undefined because sd(obs) == 0.", call. = FALSE)
  }
  stats::sd(sim) / sd_obs
}

core_metric_spec_rsd <- function() {
  list(
    id = "rsd",
    fun = metric_rsd,
    name = "Standard Deviation Ratio",
    description = "rSD computed as sd(sim) / sd(obs).",
    category = "scale",
    perfect = 1,
    range = c(0, Inf),
    references = "Project definition for hydrology compatibility: ratio of simulated to observed standard deviation.",
    version_added = "0.1.0",
    tags = character()
  )
}
