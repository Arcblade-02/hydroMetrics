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

.gof_can_auto_run_positive <- function(sim, obs) {
  !is.null(sim) &&
    !is.null(obs) &&
    length(sim) > 0L &&
    length(obs) > 0L &&
    all(is.finite(sim)) &&
    all(is.finite(obs)) &&
    all(sim > 0) &&
    all(obs > 0)
}

.gof_can_auto_run_nrmse_range <- function(obs) {
  !is.null(obs) && length(obs) > 0L && isTRUE(diff(range(obs)) != 0)
}

.gof_can_auto_run_fdc_highflow_bias <- function(obs) {
  if (is.null(obs) || length(obs) < 1L) {
    return(FALSE)
  }

  n_high <- max(1L, ceiling(length(obs) * 0.02))
  denom <- sum(sort(obs, decreasing = TRUE)[seq_len(n_high)])
  is.finite(denom) && denom != 0
}

.gof_can_auto_run_fdc_lowflow_bias <- function(sim, obs) {
  if (!.gof_can_auto_run_positive(sim, obs) || length(obs) < 2L) {
    return(FALSE)
  }

  n_low <- max(2L, ceiling(length(obs) * 0.30))
  obs_low <- utils::tail(sort(obs, decreasing = TRUE), n_low)
  obs_terms <- log(obs_low) - log(obs_low[[n_low]])
  denom <- sum(obs_terms)
  is.finite(denom) && denom != 0
}

.gof_can_auto_run_fdc_slope_error <- function(sim, obs) {
  if (!.gof_can_auto_run_positive(sim, obs) || length(obs) < 3L) {
    return(FALSE)
  }

  obs_sorted <- sort(obs, decreasing = TRUE)
  p <- seq_along(obs_sorted) / (length(obs_sorted) + 1)
  obs_q <- stats::approx(x = p, y = obs_sorted, xout = c(0.2, 0.7), rule = 2, ties = "ordered")$y
  obs_slope <- abs(log(obs_q[[1L]]) - log(obs_q[[2L]]))
  is.finite(obs_slope) && obs_slope != 0
}

.gof_can_auto_run_low_flow_bias <- function(obs) {
  if (is.null(obs) || length(obs) < 1L) {
    return(FALSE)
  }

  q_low <- tryCatch(
    as.numeric(stats::quantile(obs, probs = 0.3, type = 7, names = FALSE)),
    error = function(e) NA_real_
  )
  if (!is.finite(q_low)) {
    return(FALSE)
  }

  idx <- which(obs <= q_low)
  length(idx) > 0L && is.finite(sum(obs[idx])) && sum(obs[idx]) != 0
}

.gof_can_auto_run_fdc_shape_distance <- function(sim, obs) {
  !is.null(sim) &&
    !is.null(obs) &&
    length(sim) > 0L &&
    length(obs) > 0L &&
    isTRUE(diff(range(sim)) != 0) &&
    isTRUE(diff(range(obs)) != 0)
}

.gof_can_auto_run_seasonal_bias <- function(index) {
  groups <- tryCatch(.hm_skge_month_groups_from_index(index), error = function(e) NULL)
  !is.null(groups) && length(groups) >= 12L && all(1:12 %in% groups)
}

.gof_auto_applicable_ids <- function(available_ids, sim = NULL, obs = NULL, index = NULL) {
  ids <- available_ids
  ids <- setdiff(ids, c("crps", "picp", "mwpi", "skill_score"))
  if (!.gof_can_auto_run_apfb(index)) {
    ids <- setdiff(ids, "apfb")
  }
  if (!.gof_can_auto_run_hfb(obs)) {
    ids <- setdiff(ids, "hfb")
  }
  if (!.gof_can_auto_run_nrmse_range(obs)) {
    ids <- setdiff(ids, "nrmse_range")
  }
  if (!.gof_can_auto_run_fdc_slope_error(sim, obs)) {
    ids <- setdiff(ids, "fdc_slope_error")
  }
  if (!.gof_can_auto_run_fdc_highflow_bias(obs)) {
    ids <- setdiff(ids, "fdc_highflow_bias")
  }
  if (!.gof_can_auto_run_fdc_lowflow_bias(sim, obs)) {
    ids <- setdiff(ids, "fdc_lowflow_bias")
  }
  if (!.gof_can_auto_run_positive(sim, obs)) {
    ids <- setdiff(ids, "log_fdc_rmse")
  }
  if (!.gof_can_auto_run_low_flow_bias(obs)) {
    ids <- setdiff(ids, "low_flow_bias")
  }
  if (!.gof_can_auto_run_fdc_shape_distance(sim, obs)) {
    ids <- setdiff(ids, "fdc_shape_distance")
  }
  if (!.gof_can_auto_run_seasonal_bias(index)) {
    ids <- setdiff(ids, "seasonal_bias")
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
