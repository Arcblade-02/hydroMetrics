metric_kgelf <- function(sim, obs) {
  if (any(sim < 0) || any(obs < 0)) {
    stop("KGElf undefined because sim/obs contain negative values for low-flow log transform.", call. = FALSE)
  }

  sim_lf <- log1p(sim)
  obs_lf <- log1p(obs)
  if (stats::sd(obs_lf) == 0) {
    stop("KGElf undefined because sd(log1p(obs)) == 0.", call. = FALSE)
  }

  metric_kge(sim_lf, obs_lf)
}

core_metric_spec_kgelf <- function() {
  list(
    id = "kgelf",
    fun = metric_kgelf,
    name = "KGE Low-Flow",
    description = "Low-flow KGE using log1p-transformed series prior to KGE computation.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "KGE low-flow emphasis variants in hydrology practice; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
