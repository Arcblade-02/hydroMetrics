metric_rmse <- function(sim, obs) {
  sqrt(mean((sim - obs)^2))
}

core_metric_spec_rmse <- function() {
  list(
    id = "rmse",
    fun = metric_rmse,
    name = "Root Mean Squared Error",
    description = "RMSE computed as the square root of mean squared error.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard RMSE definition in statistical error analysis texts.",
    version_added = "0.1.0",
    tags = c("core", "phase-2")
  )
}
