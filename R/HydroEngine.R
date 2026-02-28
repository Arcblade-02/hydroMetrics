HydroEngine <- R6::R6Class(
  "HydroEngine",
  public = list(
    registry = NULL,

    initialize = function(registry) {
      if (!inherits(registry, "MetricRegistry")) {
        stop("`registry` must be a MetricRegistry instance.", call. = FALSE)
      }
      self$registry <- registry
    },

    validate_inputs = function(sim, obs) {
      validate_numeric_vector(sim, "sim")
      validate_numeric_vector(obs, "obs")
      validate_equal_length(sim, obs)
      validate_finite(sim, obs, allow_inf = FALSE)
      invisible(TRUE)
    },

    evaluate = function(sim, obs, metrics) {
      self$validate_inputs(sim, obs)

      if (!is.character(metrics) || length(metrics) == 0L || any(!nzchar(metrics))) {
        stop("`metrics` must be a non-empty character vector of metric ids.", call. = FALSE)
      }

      rows <- lapply(metrics, function(metric_id) {
        spec <- self$registry$get(metric_id)
        value <- spec$fun(sim, obs)

        if (!is.numeric(value) || length(value) != 1L || is.na(value)) {
          stop(sprintf("Metric '%s' must return a non-missing numeric scalar.", metric_id), call. = FALSE)
        }

        data.frame(
          metric = spec$id,
          name = spec$name,
          value = as.numeric(value),
          stringsAsFactors = FALSE
        )
      })

      hm_result(do.call(rbind, rows))
    }
  )
)
