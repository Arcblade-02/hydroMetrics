.preproc_is_vector <- function(x) {
  is.atomic(x) && is.numeric(x) && is.null(dim(x))
}

.preproc_to_matrix <- function(x, name) {
  if (.preproc_is_vector(x)) {
    return(matrix(as.numeric(x), ncol = 1))
  }

  if (inherits(x, "zoo")) {
    if (!requireNamespace("zoo", quietly = TRUE)) {
      stop("zoo input requires the 'zoo' package to be installed.", call. = FALSE)
    }
    mat <- as.matrix(zoo::coredata(x))
  } else if (is.data.frame(x)) {
    mat <- as.matrix(x)
  } else if (is.matrix(x)) {
    mat <- x
  } else {
    stop(
      sprintf("`%s` must be a numeric vector, matrix, data.frame, or zoo object.", name),
      call. = FALSE
    )
  }

  if (!is.numeric(mat)) {
    stop(sprintf("`%s` must be numeric after coercion.", name), call. = FALSE)
  }

  mat
}

.preproc_format_output <- function(x, as, drop) {
  if (as == "matrix") {
    return(x)
  }

  if (as == "data.frame") {
    return(as.data.frame(x, stringsAsFactors = FALSE))
  }

  if (ncol(x) == 1L && isTRUE(drop)) {
    return(as.numeric(x[, 1]))
  }

  x
}

preproc <- function(sim,
                    obs,
                    na.rm = TRUE,
                    keep = c("complete", "pairwise"),
                    as = "numeric",
                    drop = TRUE,
                    ...) {
  keep <- match.arg(keep)
  as <- match.arg(as, choices = c("numeric", "matrix", "data.frame"))

  sim_is_vector <- .preproc_is_vector(sim)
  obs_is_vector <- .preproc_is_vector(obs)
  vector_mode <- sim_is_vector && obs_is_vector

  if (xor(sim_is_vector, obs_is_vector)) {
    stop("`sim` and `obs` must both be vectors or both be matrix-like inputs.", call. = FALSE)
  }

  sim_mat <- .preproc_to_matrix(sim, "sim")
  obs_mat <- .preproc_to_matrix(obs, "obs")

  if (vector_mode) {
    if (nrow(sim_mat) != nrow(obs_mat)) {
      stop("`sim` and `obs` must have the same length.", call. = FALSE)
    }
  } else if (!identical(dim(sim_mat), dim(obs_mat))) {
    stop("`sim` and `obs` must have identical dimensions.", call. = FALSE)
  }

  if (nrow(sim_mat) == 0L) {
    stop("No rows available for preprocessing.", call. = FALSE)
  }

  removed <- 0L
  if (isTRUE(na.rm)) {
    if (keep == "pairwise") {
      # Current pairwise mode is an explicit complete-case fallback.
      keep <- "complete"
    }
    keep_rows <- stats::complete.cases(sim_mat, obs_mat)
    removed <- sum(!keep_rows)
    sim_mat <- sim_mat[keep_rows, , drop = FALSE]
    obs_mat <- obs_mat[keep_rows, , drop = FALSE]
  }

  if (nrow(sim_mat) == 0L) {
    stop("No valid rows remain after preprocessing.", call. = FALSE)
  }

  n_used <- if (vector_mode) {
    as.integer(nrow(sim_mat))
  } else {
    out <- rep(as.integer(nrow(sim_mat)), ncol(sim_mat))
    nm <- colnames(sim_mat)
    if (!is.null(nm)) {
      names(out) <- nm
    }
    out
  }

  list(
    sim = .preproc_format_output(sim_mat, as = as, drop = drop),
    obs = .preproc_format_output(obs_mat, as = as, drop = drop),
    n = n_used,
    removed = as.integer(removed)
  )
}
