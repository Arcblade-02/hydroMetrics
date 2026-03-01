metric_skge <- function(sim, obs) {
  if (!inherits(sim, "ts") || !inherits(obs, "ts")) {
    stop("sKGE requires ts inputs with monthly frequency for seasonal grouping.", call. = FALSE)
  }
  if (stats::frequency(sim) != 12 || stats::frequency(obs) != 12) {
    stop("sKGE requires monthly ts inputs (frequency = 12).", call. = FALSE)
  }

  sim_month <- stats::cycle(sim)
  obs_month <- stats::cycle(obs)
  group_scores <- rep(NA_real_, 12)

  for (m in 1:12) {
    idx <- which(sim_month == m & obs_month == m)
    if (length(idx) < 2) {
      next
    }
    group_scores[m] <- tryCatch(
      metric_kge(as.numeric(sim[idx]), as.numeric(obs[idx])),
      error = function(e) NA_real_
    )
  }

  if (all(is.na(group_scores))) {
    stop("sKGE has no valid seasonal groups for KGE computation.", call. = FALSE)
  }

  mean(group_scores, na.rm = TRUE)
}

core_metric_spec_skge <- function() {
  list(
    id = "skge",
    fun = metric_skge,
    name = "Seasonal KGE",
    description = "Seasonal KGE as mean monthly KGE over ts groups with frequency 12.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Seasonal KGE variant definition implemented per project decision pending definitive citation.",
    version_added = "0.1.0",
    tags = character()
  )
}
