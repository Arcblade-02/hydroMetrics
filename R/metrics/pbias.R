metric_pbias <- function(sim, obs) {
  100 * sum(sim - obs) / sum(obs)
}

core_metric_spec_pbias <- function() {
  list(
    id = "pbias",
    fun = metric_pbias,
    name = "Percent Bias",
    description = "PBIAS computed as 100 * sum(sim - obs) / sum(obs).",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations.",
    version_added = "0.1.0",
    tags = c("core", "phase-2")
  )
}
