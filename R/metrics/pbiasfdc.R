metric_pbiasfdc <- function(sim, obs) {
  if (any(sim < 0) || any(obs < 0)) {
    stop("pbiasfdc undefined because sim/obs contain negative values.", call. = FALSE)
  }

  p <- seq(0.01, 0.99, by = 0.01)
  qobs <- stats::quantile(obs, probs = 1 - p, type = 7, names = FALSE)
  qsim <- stats::quantile(sim, probs = 1 - p, type = 7, names = FALSE)

  if (sum(qobs) == 0) {
    stop("pbiasfdc undefined because sum(Qobs) == 0.", call. = FALSE)
  }

  100 * sum(qsim - qobs) / sum(qobs)
}

core_metric_spec_pbiasfdc <- function() {
  list(
    id = "pbiasfdc",
    fun = metric_pbiasfdc,
    name = "Percent Bias of Flow Duration Curve",
    description = "PBIASFDC using exceedance-quantile grid p = 0.01..0.99.",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Flow duration curve bias formulation implemented per project decision pending definitive citation.",
    version_added = "0.1.0",
    tags = character()
  )
}
