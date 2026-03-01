metric_ubrmse <- function(sim, obs) {
  sqrt(mean(((sim - mean(sim)) - (obs - mean(obs)))^2))
}

core_metric_spec_ubrmse <- function() {
  list(
    id = "ubrmse",
    fun = metric_ubrmse,
    name = "Unbiased RMSE",
    description = "ubRMSE computed from anomalies relative to each series mean.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard unbiased RMSE definition in model-evaluation literature.",
    version_added = "0.1.0",
    tags = character()
  )
}
