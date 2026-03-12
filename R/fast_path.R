.hm_fast_path_metric_fun <- function(metric_id) {
  switch(
    metric_id,
    nse = metric_nse,
    kge = metric_kge,
    rmse = metric_rmse,
    r2 = metric_r2,
    nrmse = metric_nrmse,
    pbias = metric_pbias,
    mae = metric_mae,
    r = metric_r,
    rsr = metric_rsr,
    alpha = metric_alpha,
    beta = metric_beta,
    mnse = metric_mnse,
    rnse = metric_rnse,
    wsnse = metric_wsnse,
    NULL
  )
}

.hm_fast_path_eligible <- function(sim, obs, na.rm = NULL, dots = list()) {
  if (!is.null(na.rm) || length(dots) > 0L) {
    return(FALSE)
  }

  if (!.hm_is_numeric_vector(sim) || !.hm_is_numeric_vector(obs)) {
    return(FALSE)
  }

  if (!is.null(attr(sim, "class", exact = TRUE)) || !is.null(attr(obs, "class", exact = TRUE))) {
    return(FALSE)
  }

  if (length(sim) != length(obs) || anyNA(sim) || anyNA(obs)) {
    return(FALSE)
  }

  if (any(is.nan(sim)) || any(is.nan(obs))) {
    return(FALSE)
  }

  if (any(!is.finite(sim)) || any(!is.finite(obs))) {
    return(FALSE)
  }

  TRUE
}

.hm_try_fast_path <- function(metric_id, sim, obs, na.rm = NULL, dots = list()) {
  metric_fun <- .hm_fast_path_metric_fun(metric_id)
  if (is.null(metric_fun) || !.hm_fast_path_eligible(sim, obs, na.rm = na.rm, dots = dots)) {
    return(NULL)
  }

  sim_vec <- as.numeric(sim)
  obs_vec <- as.numeric(obs)
  validate_numeric_vector(sim_vec, "sim")
  validate_numeric_vector(obs_vec, "obs")
  validate_equal_length(sim_vec, obs_vec)
  validate_finite(sim_vec, obs_vec)

  value <- tryCatch(
    as.numeric(metric_fun(sim_vec, obs_vec)),
    error = function(e) NULL
  )
  if (is.null(value) || length(value) != 1L || is.na(value) || !is.finite(value)) {
    return(NULL)
  }

  value
}

.hm_run_single_metric_wrapper <- function(metric_id, sim, obs, na.rm = NULL, dots = list()) {
  fast_value <- .hm_try_fast_path(metric_id, sim, obs, na.rm = na.rm, dots = dots)
  if (!is.null(fast_value)) {
    return(fast_value)
  }

  out <- do.call(
    gof,
    c(
      list(sim = sim, obs = obs, methods = metric_id, na.rm = na.rm),
      dots
    )
  )

  if (is.matrix(out)) {
    return(out)
  }

  as.numeric(out[[1]])
}
