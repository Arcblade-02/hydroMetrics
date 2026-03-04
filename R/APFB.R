.hm_scalar_preproc_args <- function(dots) {
  dots[["as"]] <- NULL
  dots[["drop"]] <- NULL
  dots[["keep"]] <- NULL
  dots
}

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
  if (anyNA(years)) {
    stop("APFB could not derive calendar year from the time index.", call. = FALSE)
  }
  years
}

APFB <- function(sim, obs, ...) {
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

  sim_index <- zoo::index(sim)
  obs_index <- zoo::index(obs)
  aligned <- identical(sim_index, obs_index)

  dots <- list(...)
  na_method <- .hm_scalar_na_method(dots)
  dots <- .hm_scalar_preproc_args(dots)

  prepared <- do.call(
    preproc,
    c(
      list(
        sim = sim,
        obs = obs
      ),
      dots
    )
  )

  n_obs <- as.integer(length(prepared$sim))
  sim_used <- as.numeric(prepared$sim)
  obs_used <- as.numeric(prepared$obs)
  years_used <- .extract_calendar_year(prepared$index)
  n_years <- length(unique(years_used))
  if (n_years < 2L) {
    stop("APFB requires at least 2 years after preprocessing.", call. = FALSE)
  }

  sim_peak <- tapply(sim_used, years_used, max)
  obs_peak <- tapply(obs_used, years_used, max)
  if (any(obs_peak == 0)) {
    stop("APFB is undefined because annual observed peak includes zero.", call. = FALSE)
  }

  ratios <- (sim_peak - obs_peak) / obs_peak
  value <- if (length(ratios) == 0L || any(!is.finite(ratios))) {
    warning("APFB denominator invalid; returning NA.", call. = FALSE)
    NA_real_
  } else {
    mean(ratios) * 100
  }

  .new_hydro_metric_scalar(
    value = value,
    metric = "APFB",
    n_obs = n_obs,
    meta = list(
      years = as.integer(n_years),
      aligned = isTRUE(aligned),
      na_method = na_method
    ),
    call = match.call()
  )
}
