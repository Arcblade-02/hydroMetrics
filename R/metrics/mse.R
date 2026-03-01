metric_mse <- function(sim, obs) {
  mean((sim - obs)^2)
}

core_metric_spec_mse <- function() {
  list(
    id = "mse",
    fun = metric_mse,
    name = "Mean Squared Error",
    description = "MSE computed as mean squared deviation between sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard MSE definition in statistical error analysis literature.",
    version_added = "0.1.0",
    tags = character()
  )
}
