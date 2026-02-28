metric_ssq <- function(sim, obs) {
  sum((sim - obs)^2)
}

core_metric_spec_ssq <- function() {
  list(
    id = "ssq",
    fun = metric_ssq,
    name = "Sum of Squared Errors",
    description = "SSQ computed as sum((sim - obs)^2).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard least-squares objective definition.",
    version_added = "0.1.0",
    tags = character()
  )
}
