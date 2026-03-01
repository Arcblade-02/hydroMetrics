metric_rpearson <- function(sim, obs) {
  r <- suppressWarnings(stats::cor(sim, obs, method = "pearson"))
  if (is.na(r)) {
    stop("rPearson correlation undefined (constant series).", call. = FALSE)
  }
  r
}

core_metric_spec_rpearson <- function() {
  list(
    id = "rpearson",
    fun = metric_rpearson,
    name = "Pearson Correlation",
    description = "Pearson product-moment correlation coefficient.",
    category = "correlation",
    perfect = 1,
    range = c(-1, 1),
    references = "Pearson correlation coefficient (standard statistical definition).",
    version_added = "0.1.0",
    tags = character()
  )
}
