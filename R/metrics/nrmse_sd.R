metric_nrmse_sd <- function(sim, obs) {
  obs_sd <- stats::sd(obs)
  if (obs_sd == 0) {
    stop("NRMSE_SD undefined because sd(obs) == 0.", call. = FALSE)
  }
  sqrt(mean((sim - obs)^2)) / obs_sd
}

core_metric_spec_nrmse_sd <- function() {
  list(
    id = "nrmse_sd",
    fun = metric_nrmse_sd,
    name = "NRMSE by SD",
    description = "NRMSE_SD computed as RMSE(sim, obs) divided by sd(obs).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Project-defined NRMSE variant normalized by sd(obs).",
    version_added = "0.1.0",
    tags = character()
  )
}
