compute_rfactor <- function(sim, obs, na.rm = TRUE) {
  if (!is.logical(na.rm) || length(na.rm) != 1L || is.na(na.rm)) {
    stop("`na.rm` must be TRUE or FALSE.", call. = FALSE)
  }

  if (na.rm) {
    keep <- stats::complete.cases(sim, obs)
    sim <- sim[keep]
    obs <- obs[keep]
  } else if (anyNA(sim) || anyNA(obs)) {
    stop("rfactor input contains NA values; set `na.rm = TRUE` to remove missing pairs.", call. = FALSE)
  }

  if (length(sim) == 0L) {
    stop("rfactor requires at least 1 non-NA paired value.", call. = FALSE)
  }

  denom <- mean(abs(obs))
  if (denom == 0) {
    stop("rfactor is undefined because mean(abs(obs)) is zero.", call. = FALSE)
  }

  mean(abs(sim - obs)) / denom
}

metric_rfactor <- function(sim, obs) {
  compute_rfactor(sim, obs, na.rm = FALSE)
}

core_metric_spec_rfactor <- function() {
  list(
    id = "rfactor",
    fun = metric_rfactor,
    name = "R-factor",
    description = "Mean absolute error normalized by mean absolute observations.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Project-defined compatibility rfactor: mean(abs(sim - obs)) / mean(abs(obs)).",
    version_added = "0.1.0",
    tags = character()
  )
}
