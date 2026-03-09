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

.extract_calendar_year <- function(index) {
  years <- suppressWarnings(as.integer(format(as.POSIXlt(index, tz = "UTC"), "%Y")))
  if (any(!is.finite(years))) {
    stop("APFB could not derive calendar year from the time index.", call. = FALSE)
  }
  years
}

#' Evaluate annual peak flow bias
#'
#' `APFB()` is an indexed compatibility wrapper over [gof()] for the registry
#' metric `"apfb"`. It requires univariate `zoo` or `xts` inputs with a time
#' index so yearly maxima can be derived deterministically.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar with class `"hydro_metric_scalar"`.
#'
#' @examples
#' if (requireNamespace("zoo", quietly = TRUE)) {
#'   dates <- as.Date("2020-01-01") + 0:729
#'   sim <- zoo::zoo(seq_along(dates), order.by = dates)
#'   obs <- zoo::zoo(seq_along(dates) + 1, order.by = dates)
#'   APFB(sim, obs)
#' }
#' @export
APFB <- function(sim, obs, na.rm = NULL, ...) {
  if (!(inherits(sim, "zoo") || inherits(sim, "xts")) ||
      !(inherits(obs, "zoo") || inherits(obs, "xts"))) {
    stop("APFB requires zoo/xts inputs with a time index.", call. = FALSE)
  }
  if (!requireNamespace("zoo", quietly = TRUE)) {
    stop("APFB requires the 'zoo' package for indexed inputs.", call. = FALSE)
  }

  sim_core <- zoo::coredata(sim)
  obs_core <- zoo::coredata(obs)
  if (!is.numeric(sim_core) || !is.numeric(obs_core)) {
    stop("APFB requires numeric zoo/xts inputs.", call. = FALSE)
  }
  if (NCOL(sim_core) != 1L || NCOL(obs_core) != 1L) {
    stop("APFB requires univariate zoo/xts inputs.", call. = FALSE)
  }

  aligned <- identical(zoo::index(sim), zoo::index(obs))
  dots <- .hm_scalar_sanitize_dots(list(...))
  na_method <- .hm_scalar_na_method(dots)

  out <- do.call(
    gof,
    c(
      list(sim = sim, obs = obs, methods = "apfb", na.rm = na.rm),
      dots
    )
  )

  years <- length(unique(.extract_calendar_year(out$meta$index)))
  .new_hydro_metric_scalar(
    value = out$apfb,
    metric = "APFB",
    n_obs = out$n_obs,
    meta = list(
      years = as.integer(years),
      aligned = isTRUE(aligned),
      na_method = na_method
    ),
    call = match.call()
  )
}
