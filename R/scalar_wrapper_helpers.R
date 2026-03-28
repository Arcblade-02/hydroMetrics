.hm_scalar_na_method <- function(dots) {
  if (!is.null(dots$na_strategy)) {
    return(as.character(dots$na_strategy[[1]]))
  }

  na_rm <- dots[["na.rm"]]
  if (is.null(na_rm)) {
    return("remove")
  }
  if (!is.logical(na_rm) || length(na_rm) != 1L || is.na(na_rm)) {
    return("unknown")
  }
  if (isTRUE(na_rm)) "remove" else "keep"
}

.hm_scalar_sanitize_dots <- function(dots) {
  dots[["as"]] <- NULL
  dots[["drop"]] <- NULL
  dots[["keep"]] <- NULL
  dots
}

.hm_merge_metric_params <- function(dots, metric_id, params) {
  metric_params <- dots$metric_params
  if (is.null(metric_params)) {
    metric_params <- list()
  }
  existing <- metric_params[[metric_id]]
  if (is.null(existing)) {
    existing <- list()
  }
  metric_params[[metric_id]] <- utils::modifyList(existing, params)
  dots$metric_params <- metric_params
  dots
}

.new_hydro_metric_scalar <- function(value, metric, n_obs, meta, call) {
  structure(
    as.numeric(value),
    class = c("hydro_metric_scalar", "numeric"),
    metric = metric,
    n_obs = as.integer(n_obs),
    meta = meta,
    call = call
  )
}
