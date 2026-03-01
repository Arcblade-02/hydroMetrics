metric_mape <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("MAPE undefined because obs contains zero.", call. = FALSE)
  }
  100 * mean(abs((sim - obs) / obs))
}

core_metric_spec_mape <- function() {
  list(
    id = "mape",
    fun = metric_mape,
    name = "Mean Absolute Percentage Error",
    description = "MAPE computed as 100 * mean(abs((sim - obs) / obs)).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard mean absolute percentage error definition in forecasting and error-analysis literature.",
    version_added = "0.1.0",
    tags = character()
  )
}
