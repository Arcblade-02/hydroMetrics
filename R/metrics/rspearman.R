metric_rspearman <- function(sim, obs) {
  r <- suppressWarnings(stats::cor(sim, obs, method = "spearman"))
  if (is.na(r)) {
    stop("rSpearman correlation undefined (constant series).", call. = FALSE)
  }
  r
}

core_metric_spec_rspearman <- function() {
  list(
    id = "rspearman",
    fun = metric_rspearman,
    name = "Spearman Correlation",
    description = "Spearman rank correlation coefficient.",
    category = "correlation",
    perfect = 1,
    range = c(-1, 1),
    references = "Spearman rank correlation (standard statistical definition).",
    version_added = "0.1.0",
    tags = character()
  )
}
