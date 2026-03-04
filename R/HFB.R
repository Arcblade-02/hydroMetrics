HFB <- function(sim, obs, threshold_prob = 0.9, ...) {
  if (!is.numeric(threshold_prob) ||
      length(threshold_prob) != 1L ||
      is.na(threshold_prob) ||
      threshold_prob <= 0 ||
      threshold_prob >= 1) {
    stop("`threshold_prob` must be a numeric scalar in (0, 1).", call. = FALSE)
  }

  dots <- .hm_scalar_sanitize_dots(list(...))
  na_method <- .hm_scalar_na_method(dots)
  dots <- .hm_merge_metric_params(
    dots = dots,
    metric_id = "hfb",
    params = list(threshold_prob = threshold_prob)
  )

  out <- tryCatch(
    do.call(
      gof,
      c(
        list(sim = sim, obs = obs, methods = "hfb"),
        dots
      )
    ),
    error = function(e) {
      msg <- conditionMessage(e)
      if (grepl("HFB denominator is zero\\.", msg)) {
        warning("HFB denominator is zero; returning NA.", call. = FALSE)
        return(NULL)
      }
      stop(e)
    }
  )

  if (is.null(out)) {
    return(
      .new_hydro_metric_scalar(
        value = NA_real_,
        metric = "HFB",
        n_obs = length(obs),
        meta = list(
          threshold_prob = as.numeric(threshold_prob),
          n_high = 0L,
          aligned = TRUE,
          na_method = na_method
        ),
        call = match.call()
      )
    )
  }

  obs_used <- out$meta$obs_used
  q_high <- as.numeric(stats::quantile(obs_used, probs = threshold_prob, type = 7, names = FALSE))
  n_high <- as.integer(sum(obs_used >= q_high))

  .new_hydro_metric_scalar(
    value = out$hfb,
    metric = "HFB",
    n_obs = out$n_obs,
    meta = list(
      threshold_prob = as.numeric(threshold_prob),
      n_high = n_high,
      aligned = TRUE,
      na_method = na_method
    ),
    call = match.call()
  )
}
