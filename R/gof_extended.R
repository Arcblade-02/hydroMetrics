.gof_default_ids <- function() {
  c(
    "me", "mae", "rmse", "ubrmse", "pbias", "rsr", "rsd", "nse", "r", "r2", "ve", "kge", "mnse", "cp",
    "alpha", "beta", "ccc",
    "mdae", "maxae", "smape",
    "low_flow_bias",
    "peak_timing_error", "extreme_event_ratio", "rising_limb_error",
    "baseflow_index_error",
    "rspearman", "wasserstein_distance", "distribution_overlap"
  )
}

.gof_hydrogof_ids <- function() {
  c(
    "me", "mae", "mse", "rmse", "ubrmse", "nrmse", "pbias", "rsr", "rsd",
    "nse", "mnse", "rnse", "wnse", "wsnse",
    "d", "md", "rd", "cp",
    "r", "r2", "br2", "ve",
    "kge", "kgelf", "kgenp", "kgekm"
  )
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

.gof_can_auto_run_peak_timing_error <- function(sim, obs) {
  !is.null(sim) && !is.null(obs) && length(sim) >= 2L && length(obs) >= 2L
}

.gof_can_auto_run_derivative_nse <- function(sim, obs) {
  !is.null(sim) &&
    !is.null(obs) &&
    length(sim) >= 3L &&
    length(obs) >= 3L &&
    isTRUE(sum((diff(obs) - mean(diff(obs)))^2) != 0)
}

.gof_can_auto_run_rising_limb_error <- function(obs) {
  tryCatch({
    idx <- .hm_b3_rising_limb_interval_idx(obs, "rising_limb_error")
    length(idx) > 0L
  }, error = function(e) FALSE)
}

.gof_can_auto_run_recession_constant <- function(sim, obs) {
  tryCatch({
    idx <- .hm_b3_recession_segment_idx(obs, "recession_constant")
    .hm_b3_fit_recession_constant(sim, idx, "recession_constant", "sim")
    .hm_b3_fit_recession_constant(obs, idx, "recession_constant", "obs")
    TRUE
  }, error = function(e) FALSE)
}

.gof_can_auto_run_baseflow_index_error <- function(sim, obs) {
  tryCatch({
    .hm_b3_baseflow_index_proxy(sim, "baseflow_index_error")
    .hm_b3_baseflow_index_proxy(obs, "baseflow_index_error")
    TRUE
  }, error = function(e) FALSE)
}

.gof_can_auto_run_event_nse <- function(obs) {
  tryCatch({
    idx <- .hm_b4_event_indices(obs, "event_nse")
    denom <- sum((obs[idx] - mean(obs[idx]))^2)
    is.finite(denom) && denom != 0
  }, error = function(e) FALSE)
}

.gof_can_auto_run_tail_dependence_score <- function(obs) {
  tryCatch({
    threshold <- .hm_c3_tail_threshold(obs, "upper_tail_conditional_exceedance")
    any(as.numeric(obs) > threshold)
  }, error = function(e) FALSE)
}

.gof_can_auto_run_extreme_event_ratio <- function(obs) {
  tryCatch({
    threshold <- .hm_c3_tail_threshold(obs, "extreme_event_ratio")
    windows <- .hm_c3_event_windows_from_threshold(obs, threshold, "extreme_event_ratio", "obs")
    length(windows) > 0L
  }, error = function(e) FALSE)
}

.gof_can_auto_run_quantile_shift_index <- function(obs) {
  tryCatch({
    length(obs) >= 3L && .hm_c1_type7_iqr(obs, "quantile_shift_index", "obs") != 0
  }, error = function(e) FALSE)
}

.gof_can_auto_run_metric <- function(metric_id, sim, obs, index = NULL) {
  if (is.null(sim) || is.null(obs)) {
    return(TRUE)
  }

  tryCatch({
    .get_engine()$evaluate(sim, obs, list(list(id = metric_id, params = list())))
    TRUE
  }, error = function(e) FALSE)
}

.gof_auto_applicable_ids <- function(available_ids, sim = NULL, obs = NULL, index = NULL) {
  ids <- available_ids
  if (!.gof_can_auto_run_hfb(obs)) {
    ids <- setdiff(ids, "hfb")
  }
  if (!.gof_can_auto_run_nrmse_range(obs)) {
    ids <- setdiff(ids, "nrmse_range")
  }
  if (!.gof_can_auto_run_low_flow_bias(obs)) {
    ids <- setdiff(ids, "low_flow_bias")
  }
  if (!.gof_can_auto_run_peak_timing_error(sim, obs)) {
    ids <- setdiff(ids, "peak_timing_error")
  }
  if (!.gof_can_auto_run_derivative_nse(sim, obs)) {
    ids <- setdiff(ids, "derivative_nse")
  }
  if (!.gof_can_auto_run_rising_limb_error(obs)) {
    ids <- setdiff(ids, "rising_limb_error")
  }
  if (!.gof_can_auto_run_recession_constant(sim, obs)) {
    ids <- setdiff(ids, "recession_constant")
  }
  if (!.gof_can_auto_run_baseflow_index_error(sim, obs)) {
    ids <- setdiff(ids, "baseflow_index_error")
  }
  if (!.gof_can_auto_run_event_nse(obs)) {
    ids <- setdiff(ids, "event_nse")
  }
  if (!.gof_can_auto_run_tail_dependence_score(obs)) {
    ids <- setdiff(ids, "upper_tail_conditional_exceedance")
  }
  if (!.gof_can_auto_run_extreme_event_ratio(obs)) {
    ids <- setdiff(ids, "extreme_event_ratio")
  }
  if (!.gof_can_auto_run_quantile_shift_index(obs)) {
    ids <- setdiff(ids, "quantile_shift_index")
  }
  if (!is.null(sim) && !is.null(obs)) {
    ids <- ids[vapply(
      ids,
      function(id) .gof_can_auto_run_metric(id, sim = sim, obs = obs, index = index),
      logical(1)
    )]
  }
  ids
}

.gof_filter_applicable_ids <- function(ids, available_ids, sim = NULL, obs = NULL, index = NULL) {
  ids <- ids[ids %in% available_ids]

  if (!is.null(sim) && !is.null(obs)) {
    ids <- ids[vapply(
      ids,
      function(id) .gof_can_auto_run_metric(id, sim = sim, obs = obs, index = index),
      logical(1)
    )]
  }

  ids
}

.gof_select_methods <- function(methods,
                                available_ids,
                                preset = NULL,
                                extended = FALSE,
                                sim = NULL,
                                obs = NULL,
                                index = NULL) {
  requested <- as.character(methods)
  requested <- requested[nzchar(requested)]

  if (length(requested) > 0L) {
    return(requested)
  }

  if (!is.null(preset)) {
    preset <- tolower(as.character(preset[[1L]]))

    if (identical(preset, "hydrogof")) {
      return(.gof_filter_applicable_ids(
        ids = .gof_hydrogof_ids(),
        available_ids = available_ids,
        sim = sim,
        obs = obs,
        index = index
      ))
    }

    if (identical(preset, "recommended")) {
      return(.gof_filter_applicable_ids(
        ids = .gof_default_ids(),
        available_ids = available_ids,
        sim = sim,
        obs = obs,
        index = index
      ))
    }

    stop("Unknown `preset`: ", preset, call. = FALSE)
  }

  if (isTRUE(extended)) {
    return(.gof_auto_applicable_ids(available_ids, sim = sim, obs = obs, index = index))
  }

  .gof_filter_applicable_ids(
    ids = .gof_default_ids(),
    available_ids = available_ids,
    sim = sim,
    obs = obs,
    index = index
  )
}
