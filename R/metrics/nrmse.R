metric_nrmse <- function(sim, obs) {
  obs_mean <- mean(obs)
  if (obs_mean == 0) {
    stop("NRMSE is undefined when mean(obs) is 0 (divide by zero).", call. = FALSE)
  }
  sqrt(mean((sim - obs)^2)) / obs_mean
}

core_metric_spec_nrmse <- function() {
  list(
    id = "nrmse",
    fun = metric_nrmse,
    name = "Normalized Root Mean Squared Error",
    description = "NRMSE computed as RMSE divided by mean(obs).",
    category = "error",
    perfect = 0,
    range = NULL,
    references = "Common NRMSE normalization by mean(obs) in model-evaluation practice.",
    version_added = "0.1.0",
    tags = character()
  )
}
