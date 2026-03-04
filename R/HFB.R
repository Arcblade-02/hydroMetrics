HFB <- function(sim, obs, threshold_prob = 0.9, ...) {
  if (!is.numeric(threshold_prob) ||
      length(threshold_prob) != 1L ||
      is.na(threshold_prob) ||
      threshold_prob <= 0 ||
      threshold_prob >= 1) {
    stop("`threshold_prob` must be a numeric scalar in (0, 1).", call. = FALSE)
  }

  dots <- list(...)
  na_method <- .hm_scalar_na_method(dots)
  dots <- .hm_scalar_preproc_args(dots)

  prepared <- do.call(
    preproc,
    c(
      list(
        sim = sim,
        obs = obs,
        as = "numeric",
        drop = TRUE
      ),
      dots
    )
  )

  sim_used <- prepared$sim
  obs_used <- prepared$obs
  if (!.hm_is_numeric_vector(sim_used) || !.hm_is_numeric_vector(obs_used)) {
    stop("HFB requires single-series inputs.", call. = FALSE)
  }

  n_obs <- if (length(prepared$n) > 1L) as.integer(unname(prepared$n[[1]])) else as.integer(prepared$n)
  q_high <- as.numeric(stats::quantile(obs_used, probs = threshold_prob, type = 7, names = FALSE))
  high_idx <- which(obs_used >= q_high)
  n_high <- length(high_idx)
  if (n_high < 3L) {
    stop("HFB requires at least 3 points at or above the high-flow threshold.", call. = FALSE)
  }

  sim_high <- sim_used[high_idx]
  obs_high <- obs_used[high_idx]
  den <- sum(obs_high)
  value <- if (!is.finite(den) || den == 0) {
    warning("HFB denominator is zero; returning NA.", call. = FALSE)
    NA_real_
  } else {
    out <- (sum(sim_high - obs_high) / den) * 100
    if (!is.finite(out)) {
      warning("HFB denominator invalid; returning NA.", call. = FALSE)
      NA_real_
    } else {
      out
    }
  }

  .new_hydro_metric_scalar(
    value = value,
    metric = "HFB",
    n_obs = n_obs,
    meta = list(
      threshold_prob = as.numeric(threshold_prob),
      n_high = as.integer(n_high),
      aligned = TRUE,
      na_method = na_method
    ),
    call = match.call()
  )
}
