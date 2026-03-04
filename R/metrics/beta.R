metric_beta <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("beta requires at least 1 value.", call. = FALSE)
  }

  obs_mean <- mean(obs)
  if (obs_mean == 0) {
    stop("mean(obs) is zero; beta undefined", call. = FALSE)
  }

  mean(sim) / obs_mean
}

core_metric_spec_beta <- function() {
  list(
    id = "beta",
    fun = metric_beta,
    name = "Bias Ratio",
    description = "Beta component computed as mean(sim) / mean(obs).",
    category = "bias",
    perfect = 1,
    range = c(-Inf, Inf),
    references = "KGE component definition in hydrology literature using bias ratio mean(sim)/mean(obs).",
    version_added = "0.1.0",
    tags = c("kge-component")
  )
}
