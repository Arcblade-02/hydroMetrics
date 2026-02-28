metric_nse <- function(sim, obs) {
  1 - (sum((sim - obs)^2) / sum((obs - mean(obs))^2))
}

core_metric_spec_nse <- function() {
  list(
    id = "nse",
    fun = metric_nse,
    name = "Nash-Sutcliffe Efficiency",
    description = "NSE computed as 1 - SSE/SST using observed values as baseline.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles.",
    version_added = "0.1.0",
    tags = c("core", "phase-2")
  )
}
