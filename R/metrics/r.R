metric_r <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("r requires at least 2 values.", call. = FALSE)
  }

  if (stats::sd(sim) == 0 || stats::sd(obs) == 0) {
    stop("zero variance; correlation undefined", call. = FALSE)
  }

  stats::cor(sim, obs, method = "pearson")
}

core_metric_spec_r <- function() {
  list(
    id = "r",
    fun = metric_r,
    name = "Pearson Correlation",
    description = "Pearson product-moment correlation coefficient between sim and obs.",
    category = "correlation",
    perfect = 1,
    range = c(-1, 1),
    references = "Pearson correlation coefficient (standard definition).",
    version_added = "0.1.0",
    tags = character()
  )
}
