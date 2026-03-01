metric_ve <- function(sim, obs) {
  obs_sum <- sum(obs)
  if (obs_sum == 0) {
    stop("VE undefined because sum(obs) == 0.", call. = FALSE)
  }
  1 - sum(abs(sim - obs)) / obs_sum
}

core_metric_spec_ve <- function() {
  list(
    id = "ve",
    fun = metric_ve,
    name = "Volumetric Efficiency",
    description = "VE computed as 1 - sum(abs(sim - obs)) / sum(obs).",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts.",
    version_added = "0.1.0",
    tags = character()
  )
}
