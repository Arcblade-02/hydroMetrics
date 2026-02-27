evaluate_metrics <- function(sim, obs, metrics) {
  validate_numeric_vector(sim, "sim")
  validate_numeric_vector(obs, "obs")
  validate_equal_length(sim, obs)
  validate_finite(sim, obs, allow_inf = FALSE)

  if (!is.character(metrics) || length(metrics) == 0L || any(!nzchar(metrics))) {
    stop("`metrics` must be a non-empty character vector of metric ids.", call. = FALSE)
  }

  records <- lapply(metrics, function(metric_id) {
    metric <- get_metric(metric_id)
    value <- metric$fun(sim, obs)
    if (!is.numeric(value) || length(value) != 1L) {
      stop(sprintf("Metric '%s' must return a numeric scalar.", metric_id), call. = FALSE)
    }

    data.frame(
      metric = metric$id,
      name = metric$name,
      value = as.numeric(value),
      stringsAsFactors = FALSE
    )
  })

  out <- do.call(rbind, records)
  as_hydrometrics_result(out, metadata = list(n = length(sim)))
}
