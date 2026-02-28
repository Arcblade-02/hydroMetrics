compute_pfactor <- function(sim, obs, tol = 0.10, na.rm = TRUE) {
  if (!is.numeric(tol) || length(tol) != 1L || is.na(tol) || tol < 0) {
    stop("`tol` must be a non-negative numeric scalar.", call. = FALSE)
  }
  if (!is.logical(na.rm) || length(na.rm) != 1L || is.na(na.rm)) {
    stop("`na.rm` must be TRUE or FALSE.", call. = FALSE)
  }

  if (na.rm) {
    keep <- stats::complete.cases(sim, obs)
    sim <- sim[keep]
    obs <- obs[keep]
  } else if (anyNA(sim) || anyNA(obs)) {
    stop("pfactor input contains NA values; set `na.rm = TRUE` to remove missing pairs.", call. = FALSE)
  }

  if (length(sim) == 0L) {
    stop("pfactor requires at least 1 non-NA paired value.", call. = FALSE)
  }

  threshold <- tol * abs(obs)
  threshold[obs == 0] <- tol
  mean(abs(sim - obs) <= threshold)
}

metric_pfactor <- function(sim, obs) {
  compute_pfactor(sim, obs, tol = 0.10, na.rm = FALSE)
}

core_metric_spec_pfactor <- function() {
  list(
    id = "pfactor",
    fun = metric_pfactor,
    name = "P-factor",
    description = "Proportion of paired values within a relative tolerance band around observations.",
    category = "efficiency",
    perfect = 1,
    range = c(0, 1),
    references = "Project-defined compatibility pfactor using tolerance-band hit proportion.",
    version_added = "0.1.0",
    tags = character()
  )
}
