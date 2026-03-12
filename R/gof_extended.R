.gof_compat10_ids <- function() {
  c("nse", "kge", "rmse", "pbias", "mae", "mse", "r2", "ve", "rsr", "nrmse")
}

.gof_can_auto_run_hfb <- function(obs, threshold_prob = 0.9) {
  if (is.null(obs) || length(obs) < 3L) {
    return(FALSE)
  }

  q_high <- tryCatch(
    as.numeric(stats::quantile(obs, probs = threshold_prob, type = 7, names = FALSE)),
    error = function(e) NA_real_
  )
  if (!is.finite(q_high)) {
    return(FALSE)
  }

  high_idx <- which(obs >= q_high)
  if (length(high_idx) < 3L) {
    return(FALSE)
  }

  den <- sum(obs[high_idx])
  is.finite(den) && den != 0
}

.gof_can_auto_run_apfb <- function(index) {
  if (is.null(index) || length(index) == 0L) {
    return(FALSE)
  }

  years <- tryCatch(
    suppressWarnings(as.integer(format(as.POSIXlt(index, tz = "UTC"), "%Y"))),
    error = function(e) rep(NA_integer_, length(index))
  )

  all(is.finite(years)) && length(unique(years)) >= 2L
}

.gof_auto_applicable_ids <- function(available_ids, sim = NULL, obs = NULL, index = NULL) {
  ids <- available_ids
  if (!.gof_can_auto_run_apfb(index)) {
    ids <- setdiff(ids, "apfb")
  }
  if (!.gof_can_auto_run_hfb(obs)) {
    ids <- setdiff(ids, "hfb")
  }
  ids
}

.gof_select_methods <- function(methods, available_ids, extended = FALSE, sim = NULL, obs = NULL, index = NULL) {
  requested <- as.character(methods)
  requested <- requested[nzchar(requested)]

  if (length(requested) > 0L) {
    return(requested)
  }

  if (isTRUE(extended)) {
    return(.gof_auto_applicable_ids(available_ids, sim = sim, obs = obs, index = index))
  }

  compat_ids <- .gof_compat10_ids()
  compat_ids[compat_ids %in% available_ids]
}
