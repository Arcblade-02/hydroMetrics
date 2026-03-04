rfactor <- function(sim, obs, na.rm = TRUE, ...) {
  if (.hm_is_numeric_vector(sim) && .hm_is_numeric_vector(obs)) {
    processed <- preproc(
      sim = sim,
      obs = obs,
      na_strategy = if (isTRUE(na.rm)) "remove" else "fail",
      ...
    )
    return(compute_rfactor(processed$sim, processed$obs, na.rm = FALSE))
  }

  sim_mat <- as.matrix(sim)
  obs_mat <- as.matrix(obs)
  if (!is.numeric(sim_mat) || !is.numeric(obs_mat) || !all(dim(sim_mat) == dim(obs_mat))) {
    stop("`sim` and `obs` must be numeric and have matching dimensions.", call. = FALSE)
  }

  values <- vapply(seq_len(ncol(sim_mat)), function(j) {
    processed <- preproc(
      sim = sim_mat[, j],
      obs = obs_mat[, j],
      na_strategy = if (isTRUE(na.rm)) "remove" else "fail",
      ...
    )
    compute_rfactor(processed$sim, processed$obs, na.rm = FALSE)
  }, numeric(1))

  if (length(values) == 1L) {
    return(as.numeric(values[[1]]))
  }

  if (!is.null(colnames(sim_mat))) {
    names(values) <- colnames(sim_mat)
  }
  values
}
