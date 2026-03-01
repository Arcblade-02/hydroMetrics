pfactor <- function(sim, obs, tol = 0.10, na.rm = TRUE, ...) {
  processed <- preproc(
    sim = sim,
    obs = obs,
    na.rm = na.rm,
    keep = "complete",
    as = "matrix",
    drop = FALSE
  )

  sim_mat <- processed$sim
  obs_mat <- processed$obs
  values <- vapply(seq_len(ncol(sim_mat)), function(j) {
    compute_pfactor(sim_mat[, j], obs_mat[, j], tol = tol, na.rm = FALSE)
  }, numeric(1))

  if (length(values) == 1L) {
    return(as.numeric(values[[1]]))
  }

  if (!is.null(colnames(sim_mat))) {
    names(values) <- colnames(sim_mat)
  }
  values
}
