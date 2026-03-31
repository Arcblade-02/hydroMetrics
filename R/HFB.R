#' Evaluate the high-flow percent bias wrapper
#'
#' `high_flow_percent_bias()` is the canonical exported wrapper over [gof()]
#' for the registry metric `"high_flow_percent_bias"`. The exact failure mode
#' for sparse high-flow support is preserved as part of the public wrapper
#' contract. Stable condition contract: it errors on invalid `threshold_prob`,
#' on downstream preprocessing failures, and when fewer than three high-flow
#' points remain; it warns and returns `NA` when the high-flow denominator is
#' zero.
#'
#' @inheritParams gof
#' @param threshold_prob Probability threshold used to define the high-flow
#'   subset from `obs`.
#'
#' @return A numeric scalar with class `"hydro_metric_scalar"`.
#'
#' @examples
#' high_flow_percent_bias(1:30 + 1, 1:30)
#' @export
high_flow_percent_bias <- function(sim, obs, threshold_prob = 0.9, na.rm = NULL, ...) {
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
    metric_id = "high_flow_percent_bias",
    params = list(threshold_prob = threshold_prob)
  )

  out <- tryCatch(
    do.call(
      gof,
      c(
        list(sim = sim, obs = obs, methods = "high_flow_percent_bias", na.rm = na.rm),
        dots
      )
    ),
    error = function(e) {
      msg <- conditionMessage(e)
      if (grepl("high_flow_percent_bias denominator is zero\\.", msg)) {
        warning("high_flow_percent_bias denominator is zero; returning NA.", call. = FALSE)
        return(NULL)
      }
      stop(e)
    }
  )

  if (is.null(out)) {
    return(
      .new_hydro_metric_scalar(
        value = NA_real_,
        metric = "high_flow_percent_bias",
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

  meta <- attr(out, "meta", exact = TRUE)
  obs_used <- meta$obs_used
  q_high <- as.numeric(stats::quantile(obs_used, probs = threshold_prob, type = 7, names = FALSE))
  n_high <- as.integer(sum(obs_used >= q_high))

  .new_hydro_metric_scalar(
    value = as.numeric(out[["high_flow_percent_bias"]]),
    metric = "high_flow_percent_bias",
    n_obs = attr(out, "n_obs", exact = TRUE),
    meta = list(
      threshold_prob = as.numeric(threshold_prob),
      n_high = n_high,
      aligned = TRUE,
      na_method = na_method
    ),
    call = match.call()
  )
}

#' Evaluate high-flow bias
#'
#' Deprecated forwarding wrapper for [high_flow_percent_bias()].
#'
#' `HFB()` remains exported temporarily for compatibility, but `"hfb"` is no
#' longer a live canonical registry metric id. Each call warns once and then
#' forwards directly to canonical [high_flow_percent_bias()].
#'
#' @inheritParams gof
#' @param threshold_prob Probability threshold used to define the high-flow
#'   subset from `obs`.
#'
#' @return A numeric scalar with class `"hydro_metric_scalar"`.
#'
#' @examples
#' HFB(1:30 + 1, 1:30)
#' @export
HFB <- function(sim, obs, threshold_prob = 0.9, na.rm = NULL, ...) {
  warning(
    "`HFB()` is deprecated; use `high_flow_percent_bias()`.",
    call. = FALSE
  )
  high_flow_percent_bias(sim = sim, obs = obs, threshold_prob = threshold_prob, na.rm = na.rm, ...)
}
