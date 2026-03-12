.hm_metric_id_aliases <- function() {
  c(rpearson = "r")
}

.hm_canonicalize_metric_ids <- function(metric_ids, warn = TRUE) {
  if (!length(metric_ids)) {
    return(metric_ids)
  }

  aliases <- .hm_metric_id_aliases()
  keys <- tolower(metric_ids)
  deprecated <- unique(keys[keys %in% names(aliases)])

  if (isTRUE(warn) && length(deprecated) > 0L) {
    for (id in deprecated) {
      warning(
        sprintf("`%s` is deprecated; use `%s`.", id, aliases[[id]]),
        call. = FALSE
      )
    }
  }

  resolved <- metric_ids
  if (length(deprecated) > 0L) {
    resolved[keys %in% names(aliases)] <- unname(aliases[keys[keys %in% names(aliases)]])
  }

  resolved
}

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
      validate_numeric_vector(sim, "sim", allow_na = TRUE)
      validate_numeric_vector(obs, "obs", allow_na = TRUE)
      validate_equal_length(sim, obs)
      invisible(TRUE)
    },

    normalize_metrics = function(metrics) {
      if (is.character(metrics)) {
        if (length(metrics) == 0L || any(!nzchar(metrics))) {
          stop("`metrics` must be a non-empty character vector of metric ids.", call. = FALSE)
        }
        metrics <- .hm_canonicalize_metric_ids(metrics, warn = TRUE)
        return(lapply(metrics, function(metric_id) {
          list(id = metric_id, params = list())
        }))
      }

      if (!is.list(metrics) || length(metrics) == 0L) {
        stop("`metrics` must be a non-empty character vector or metric-call list.", call. = FALSE)
      }

      lapply(metrics, function(metric) {
        if (!is.list(metric)) {
          stop("Each metric call must be a list.", call. = FALSE)
        }

        metric_id <- metric$id
        if (!is.character(metric_id) || length(metric_id) != 1L || !nzchar(metric_id)) {
          stop("Each metric call must include a non-empty character `id`.", call. = FALSE)
        }
        metric_id <- .hm_canonicalize_metric_ids(metric_id, warn = TRUE)

        params <- metric$params
        if (is.null(params)) {
          params <- list()
        }
        if (!is.list(params)) {
          stop(sprintf("Metric params for '%s' must be a list.", metric_id), call. = FALSE)
        }

        list(id = metric_id[[1L]], params = params)
      })
    },

    evaluate = function(sim, obs, metrics) {
      self$validate_inputs(sim, obs)
      metric_calls <- self$normalize_metrics(metrics)

      rows <- lapply(metric_calls, function(metric) {
        spec <- self$registry$get(metric$id)
        value <- do.call(spec$fun, c(list(sim, obs), metric$params))

        if (!is.numeric(value) || length(value) != 1L || is.na(value)) {
          stop(sprintf("Metric '%s' must return a non-missing numeric scalar.", metric$id), call. = FALSE)
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
