.preproc_apply_na_compat <- function(na_strategy, dots, na_strategy_missing) {
  if (!is.null(dots$na.rm)) {
    na_rm <- dots$na.rm
    if (!is.logical(na_rm) || length(na_rm) != 1L || is.na(na_rm)) {
      stop("`na.rm` must be TRUE or FALSE.", call. = FALSE)
    }
    return(if (isTRUE(na_rm)) "remove" else "fail")
  }

  if (!is.null(dots$keep) && isTRUE(na_strategy_missing)) {
    keep <- match.arg(dots$keep, choices = c("complete", "pairwise"))
    return(if (identical(keep, "pairwise")) "pairwise" else "remove")
  }

  na_strategy
}

.epsilon_details <- function(transform, epsilon_mode, epsilon, epsilon_factor, sim, obs) {
  needs_epsilon <- switch(
    transform,
    none = FALSE,
    log = any(sim <= 0 | obs <= 0),
    sqrt = any(sim < 0 | obs < 0),
    reciprocal = any(sim == 0 | obs == 0)
  )

  epsilon_used <- if (needs_epsilon) {
    .hm_compute_epsilon(sim, obs, epsilon_mode, epsilon, epsilon_factor)
  } else {
    0
  }

  list(
    mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor,
    epsilon_used = as.numeric(epsilon_used),
    applied = isTRUE(needs_epsilon)
  )
}

.new_hydro_preproc <- function(payload, transform, epsilon_mode, epsilon, epsilon_factor) {
  structure(
    list(
      sim = payload$sim,
      obs = payload$obs,
      n_original = as.integer(payload$meta$n_original),
      n_aligned = as.integer(payload$meta$n_aligned),
      n_removed_na = as.integer(payload$meta$n_removed_na),
      transform_applied = transform,
      epsilon_details = .epsilon_details(
        transform = transform,
        epsilon_mode = epsilon_mode,
        epsilon = epsilon,
        epsilon_factor = epsilon_factor,
        sim = payload$sim,
        obs = payload$obs
      ),
      index = payload$index,
      n = as.integer(length(payload$sim)),
      removed = as.integer(payload$meta$n_removed_na)
    ),
    class = "hydro_preproc"
  )
}

hm_prepare <- function(sim,
                       obs,
                       na_strategy = c("fail", "remove", "pairwise"),
                       transform = c("none", "log", "sqrt", "reciprocal"),
                       epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                       epsilon = NULL,
                       epsilon_factor = 1,
                       ...) {
  preproc(
    sim = sim,
    obs = obs,
    na_strategy = na_strategy,
    transform = transform,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor,
    ...
  )
}

#' Preprocess hydrological series
#'
#' Public clean-room preprocessing wrapper used by the orchestration layer. The
#' current exported contract supports single-series numeric, `ts`, `zoo`, and
#' `xts` inputs and intentionally rejects matrix/data.frame inputs.
#'
#' @param sim Simulated values as a numeric vector or supported indexed
#'   single-series object.
#' @param obs Observed values with the same shape contract as `sim`.
#' @param na_strategy Missing-value strategy used by the preprocessing engine.
#' @param transform Optional transform applied after NA handling.
#' @param epsilon_mode Epsilon policy used when a transform requires adjustment.
#' @param epsilon Constant epsilon value used when
#'   `epsilon_mode = "constant"`.
#' @param epsilon_factor Scaling factor for automatic epsilon modes.
#' @param na.rm Optional compatibility alias for NA handling. `TRUE` maps to
#'   `na_strategy = "remove"` and `FALSE` maps to `"fail"`.
#' @param keep Optional compatibility alias for NA handling. `"complete"` maps
#'   to `na_strategy = "remove"` and `"pairwise"` maps to `"pairwise"`.
#' @param epsilon.type Optional compatibility alias for `epsilon_mode`.
#' @param epsilon.value Optional compatibility alias for the epsilon numeric
#'   value. It maps to `epsilon` when `epsilon_mode = "constant"` and to
#'   `epsilon_factor` otherwise.
#' @param ... Additional compatibility arguments retained for forward
#'   compatibility.
#'
#' @return A list with class `"hydro_preproc"` containing processed vectors and
#'   metadata, including `sim`, `obs`, `n_original`, `n_aligned`,
#'   `n_removed_na`, `transform_applied`, and `epsilon_details`.
#'
#' @examples
#' preproc(c(1, NA, 3), c(1, 2, 3), na.rm = TRUE)
#' @export
preproc <- function(sim,
                    obs,
                    na_strategy = c("fail", "remove", "pairwise"),
                    transform = c("none", "log", "sqrt", "reciprocal"),
                    epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                    epsilon = NULL,
                    epsilon_factor = 1,
                    na.rm = NULL,
                    keep = NULL,
                    epsilon.type = NULL,
                    epsilon.value = NULL,
                    ...) {
  na_strategy_missing <- missing(na_strategy)
  epsilon_mode_missing <- missing(epsilon_mode)
  epsilon_missing <- missing(epsilon)
  epsilon_factor_missing <- missing(epsilon_factor)

  compat <- .hm_apply_orchestration_compat(
    methods = NULL,
    na_strategy = na_strategy,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor,
    na.rm = na.rm,
    keep = keep,
    epsilon.type = epsilon.type,
    epsilon.value = epsilon.value,
    na_strategy_missing = na_strategy_missing,
    epsilon_mode_missing = epsilon_mode_missing,
    epsilon_missing = epsilon_missing,
    epsilon_factor_missing = epsilon_factor_missing
  )
  na_strategy <- compat$na_strategy
  epsilon_mode <- compat$epsilon_mode
  epsilon <- compat$epsilon
  epsilon_factor <- compat$epsilon_factor

  na_strategy <- match.arg(na_strategy)
  transform <- match.arg(transform)
  epsilon_mode <- match.arg(epsilon_mode)

  dots <- list(...)
  na_strategy <- .preproc_apply_na_compat(na_strategy, dots, na_strategy_missing = na_strategy_missing)

  payload <- .hm_prepare_inputs(
    sim = sim,
    obs = obs,
    na_strategy = na_strategy,
    transform = transform,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor
  )

  .new_hydro_preproc(
    payload = payload,
    transform = transform,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor
  )
}

#' Print a hydro_preproc object
#'
#' @param x A `"hydro_preproc"` object.
#' @param ... Unused.
#'
#' @return The input object, invisibly.
#' @rdname hydro-orchestration-methods
#' @export
print.hydro_preproc <- function(x, ...) {
  cat(
    sprintf(
      "<hydro_preproc: n_original=%d, n_aligned=%d, n_removed_na=%d, n_used=%d>\n",
      as.integer(x$n_original),
      as.integer(x$n_aligned),
      as.integer(x$n_removed_na),
      as.integer(length(x$sim))
    )
  )
  invisible(x)
}
