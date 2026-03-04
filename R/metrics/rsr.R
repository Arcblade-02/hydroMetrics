metric_rsr <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("RSR requires at least 2 values.", call. = FALSE)
  }

  obs_sd <- stats::sd(obs)
  if (obs_sd == 0) {
    stop("sd(obs) is zero; RSR undefined", call. = FALSE)
  }

  sqrt(mean((sim - obs)^2)) / obs_sd
}

core_metric_spec_rsr <- function() {
  list(
    id = "rsr",
    fun = metric_rsr,
    name = "RSR",
    description = "RSR computed as RMSE(sim, obs) divided by sd(obs).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations.",
    version_added = "0.1.0",
    tags = character()
  )
}
