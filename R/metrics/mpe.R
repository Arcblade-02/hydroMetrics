metric_mpe <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("MPE undefined because obs contains zero.", call. = FALSE)
  }
  100 * mean((sim - obs) / obs)
}

core_metric_spec_mpe <- function() {
  list(
    id = "mpe",
    fun = metric_mpe,
    name = "Mean Percentage Error",
    description = "MPE computed as 100 * mean((sim - obs) / obs).",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Standard mean percentage error definition in forecasting and error-analysis literature.",
    version_added = "0.1.0",
    tags = character()
  )
}
