metric_me <- function(sim, obs) {
  mean(sim - obs)
}

core_metric_spec_me <- function() {
  list(
    id = "me",
    fun = metric_me,
    name = "Mean Error",
    description = "ME computed as mean(sim - obs).",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Standard mean error definition in forecast error analysis.",
    version_added = "0.1.0",
    tags = character()
  )
}
