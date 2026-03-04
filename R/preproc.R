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

preproc <- function(sim,
                    obs,
                    na_strategy = c("fail", "remove", "pairwise"),
                    transform = c("none", "log", "sqrt", "reciprocal"),
                    epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                    epsilon = NULL,
                    epsilon_factor = 1,
                    ...) {
  na_strategy_missing <- missing(na_strategy)
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
