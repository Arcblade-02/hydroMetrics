.hm_is_numeric_vector <- function(x) {
  is.atomic(x) && is.numeric(x) && is.null(dim(x))
}

.hm_as_numeric_vector <- function(x, name) {
  if (.hm_is_numeric_vector(x)) {
    return(as.numeric(x))
  }

  if (inherits(x, "ts")) {
    if (!is.null(dim(x)) && NCOL(x) != 1L) {
      stop(sprintf("`%s` must be a univariate ts series.", name), call. = FALSE)
    }
    return(as.numeric(x))
  }

  if (inherits(x, "zoo") || inherits(x, "xts")) {
    if (!requireNamespace("zoo", quietly = TRUE)) {
      stop("zoo/xts input requires the 'zoo' package to be installed.", call. = FALSE)
    }

    core <- zoo::coredata(x)
    if (!is.numeric(core)) {
      stop(sprintf("`%s` must be numeric.", name), call. = FALSE)
    }
    if (NCOL(core) != 1L) {
      stop(sprintf("`%s` must be a univariate zoo/xts series.", name), call. = FALSE)
    }

    if (is.null(dim(core))) {
      return(as.numeric(core))
    }

    return(as.numeric(core[, 1]))
  }

  stop(
    sprintf("`%s` must be numeric, ts, zoo, or xts.", name),
    call. = FALSE
  )
}

.hm_compute_epsilon <- function(sim, obs, epsilon_mode, epsilon, epsilon_factor) {
  if (!is.numeric(epsilon_factor) || length(epsilon_factor) != 1L || is.na(epsilon_factor)) {
    stop("`epsilon_factor` must be a non-missing numeric scalar.", call. = FALSE)
  }

  if (epsilon_mode == "constant") {
    if (is.null(epsilon)) {
      stop("`epsilon` must be provided when `epsilon_mode = 'constant'`.", call. = FALSE)
    }
    if (!is.numeric(epsilon) || length(epsilon) != 1L || is.na(epsilon)) {
      stop("`epsilon` must be a non-missing numeric scalar.", call. = FALSE)
    }
    return(as.numeric(epsilon))
  }

  if (epsilon_mode == "auto_min_positive") {
    positives <- c(sim[sim > 0], obs[obs > 0])
    if (length(positives) == 0L) {
      stop("No positive values available for `epsilon_mode = 'auto_min_positive'`.", call. = FALSE)
    }
    return(min(positives) * epsilon_factor)
  }

  # epsilon_mode == "obs_mean_factor"
  mean(obs) * epsilon_factor
}

.hm_apply_transform <- function(sim, obs, transform, epsilon_mode, epsilon, epsilon_factor) {
  if (transform == "none") {
    return(list(sim = sim, obs = obs))
  }

  needs_epsilon <- switch(
    transform,
    log = any(sim <= 0 | obs <= 0),
    sqrt = any(sim < 0 | obs < 0),
    reciprocal = any(sim == 0 | obs == 0)
  )

  sim_adj <- sim
  obs_adj <- obs
  if (needs_epsilon) {
    eps <- .hm_compute_epsilon(sim, obs, epsilon_mode, epsilon, epsilon_factor)
    if (!is.finite(eps)) {
      stop("Computed `epsilon` must be finite.", call. = FALSE)
    }
    sim_adj <- sim + eps
    obs_adj <- obs + eps
  }

  if (transform == "log") {
    if (any(sim_adj <= 0 | obs_adj <= 0)) {
      stop("log transform requires strictly positive values after epsilon adjustment.", call. = FALSE)
    }
    return(list(sim = log(sim_adj), obs = log(obs_adj)))
  }

  if (transform == "sqrt") {
    if (any(sim_adj < 0 | obs_adj < 0)) {
      stop("sqrt transform requires non-negative values after epsilon adjustment.", call. = FALSE)
    }
    return(list(sim = sqrt(sim_adj), obs = sqrt(obs_adj)))
  }

  if (any(sim_adj == 0 | obs_adj == 0)) {
    stop("reciprocal transform requires non-zero values after epsilon adjustment.", call. = FALSE)
  }
  list(sim = 1 / sim_adj, obs = 1 / obs_adj)
}

.hm_prepare_inputs <- function(sim,
                               obs,
                               na_strategy = c("fail", "remove", "pairwise"),
                               transform = c("none", "log", "sqrt", "reciprocal"),
                               epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                               epsilon = NULL,
                               epsilon_factor = 1) {
  na_strategy <- match.arg(na_strategy)
  transform <- match.arg(transform)
  epsilon_mode <- match.arg(epsilon_mode)

  n_original <- NA_integer_
  n_aligned <- NA_integer_

  if (inherits(sim, "zoo") || inherits(sim, "xts") || inherits(obs, "zoo") || inherits(obs, "xts")) {
    if (!inherits(sim, "zoo") && !inherits(sim, "xts")) {
      stop("`sim` and `obs` must both be zoo/xts objects when either is zoo/xts.", call. = FALSE)
    }
    if (!inherits(obs, "zoo") && !inherits(obs, "xts")) {
      stop("`sim` and `obs` must both be zoo/xts objects when either is zoo/xts.", call. = FALSE)
    }
    if (!requireNamespace("zoo", quietly = TRUE)) {
      stop("zoo/xts input requires the 'zoo' package to be installed.", call. = FALSE)
    }

    sim_core <- zoo::coredata(sim)
    obs_core <- zoo::coredata(obs)
    if (!is.numeric(sim_core) || !is.numeric(obs_core)) {
      stop("`sim` and `obs` must be numeric zoo/xts series.", call. = FALSE)
    }
    if (NCOL(sim_core) != 1L || NCOL(obs_core) != 1L) {
      stop("`sim` and `obs` must be univariate zoo/xts series.", call. = FALSE)
    }

    n_original <- as.integer(min(NROW(sim_core), NROW(obs_core)))
    common_index <- sort(intersect(zoo::index(sim), zoo::index(obs)))
    sim <- sim[common_index]
    obs <- obs[common_index]
    sim <- sim[order(zoo::index(sim))]
    obs <- obs[order(zoo::index(obs))]

    sim_aligned_core <- zoo::coredata(sim)
    obs_aligned_core <- zoo::coredata(obs)
    sim_vec <- if (is.null(dim(sim_aligned_core))) {
      as.numeric(sim_aligned_core)
    } else {
      as.numeric(sim_aligned_core[, 1])
    }
    obs_vec <- if (is.null(dim(obs_aligned_core))) {
      as.numeric(obs_aligned_core)
    } else {
      as.numeric(obs_aligned_core[, 1])
    }
    n_aligned <- as.integer(length(sim_vec))
  } else if (inherits(sim, "ts") || inherits(obs, "ts")) {
    if (!inherits(sim, "ts") || !inherits(obs, "ts")) {
      stop("`sim` and `obs` must both be ts objects when either is ts.", call. = FALSE)
    }
    if (stats::frequency(sim) != stats::frequency(obs) || length(sim) != length(obs)) {
      stop("`sim` and `obs` ts inputs must have identical frequency and length.", call. = FALSE)
    }
    sim_vec <- .hm_as_numeric_vector(sim, "sim")
    obs_vec <- .hm_as_numeric_vector(obs, "obs")
    n_original <- as.integer(length(sim_vec))
    n_aligned <- as.integer(length(sim_vec))
  } else {
    sim_vec <- .hm_as_numeric_vector(sim, "sim")
    obs_vec <- .hm_as_numeric_vector(obs, "obs")
    if (length(sim_vec) != length(obs_vec)) {
      stop("`sim` and `obs` must have the same length.", call. = FALSE)
    }
    n_original <- as.integer(length(sim_vec))
    n_aligned <- as.integer(length(sim_vec))
  }

  if (length(sim_vec) == 0L || length(obs_vec) == 0L) {
    stop("At least 1 paired value is required after alignment.", call. = FALSE)
  }
  if (length(sim_vec) != length(obs_vec)) {
    stop("Aligned `sim` and `obs` must have equal length.", call. = FALSE)
  }

  n_removed_na <- 0L
  if (na_strategy == "fail") {
    if (anyNA(sim_vec) || anyNA(obs_vec)) {
      stop("Missing values found; use `na_strategy = 'remove'` to drop NA pairs.", call. = FALSE)
    }
  } else {
    keep <- stats::complete.cases(sim_vec, obs_vec)
    n_removed_na <- as.integer(sum(!keep))
    sim_vec <- sim_vec[keep]
    obs_vec <- obs_vec[keep]
  }

  if (length(sim_vec) == 0L) {
    stop("At least 1 valid paired value is required after NA handling.", call. = FALSE)
  }

  transformed <- .hm_apply_transform(
    sim = sim_vec,
    obs = obs_vec,
    transform = transform,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor
  )

  sim_out <- as.numeric(transformed$sim)
  obs_out <- as.numeric(transformed$obs)
  if (length(sim_out) == 0L || length(obs_out) == 0L) {
    stop("At least 1 paired value is required after transformation.", call. = FALSE)
  }
  if (anyNA(sim_out) || anyNA(obs_out) || any(!is.finite(sim_out)) || any(!is.finite(obs_out))) {
    stop("Transformation produced non-finite values.", call. = FALSE)
  }

  list(
    sim = sim_out,
    obs = obs_out,
    meta = list(
      n_original = as.integer(n_original),
      n_aligned = as.integer(n_aligned),
      n_used = as.integer(length(sim_out)),
      n_removed_na = as.integer(n_removed_na),
      transform = transform,
      epsilon_mode = epsilon_mode
    )
  )
}
