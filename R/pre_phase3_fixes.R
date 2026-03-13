.hm_skge_month_groups_from_index <- function(index) {
  if (is.null(index) || length(index) == 0L) {
    return(NULL)
  }

  if (inherits(index, "Date") || inherits(index, "POSIXt")) {
    idx <- as.POSIXlt(index, tz = "UTC")
    serial <- (idx$year + 1900L) * 12L + idx$mon
    if (length(serial) < 2L || all(diff(serial) == 1L)) {
      return(as.integer(idx$mon + 1L))
    }
    return(NULL)
  }

  if (inherits(index, "yearmon")) {
    serial <- as.integer(floor(as.numeric(index) * 12 + 1e-8))
    if (length(serial) < 2L || all(diff(serial) == 1L)) {
      return(as.integer((serial %% 12L) + 1L))
    }
    return(NULL)
  }

  if (is.numeric(index)) {
    steps <- diff(index)
    months <- as.integer(round((index - floor(index)) * 12)) + 1L
    if (
      all(months >= 1L & months <= 12L) &&
      (length(steps) == 0L || all(abs((steps * 12) - 1) < 1e-6))
    ) {
      return(months)
    }
  }

  NULL
}

.hm_skge_grouped_mean <- function(sim, obs, groups) {
  group_scores <- numeric()

  for (m in 1:12) {
    idx <- which(groups == m)
    if (length(idx) < 2L) {
      next
    }

    score <- tryCatch(
      metric_kge(as.numeric(sim[idx]), as.numeric(obs[idx])),
      error = function(e) NULL
    )
    if (!is.null(score) && is.finite(score)) {
      group_scores <- c(group_scores, score)
    }
  }

  if (length(group_scores) == 0L) {
    stop("sKGE has no valid seasonal groups for KGE computation.", call. = FALSE)
  }

  mean(group_scores)
}

metric_skge <- function(sim, obs, index = NULL) {
  if (inherits(sim, "ts") || inherits(obs, "ts")) {
    if (!inherits(sim, "ts") || !inherits(obs, "ts")) {
      stop("sKGE requires both inputs to share the same time context.", call. = FALSE)
    }
    if (stats::frequency(sim) != 12 || stats::frequency(obs) != 12) {
      stop("sKGE requires monthly ts inputs (frequency = 12).", call. = FALSE)
    }

    return(.hm_skge_grouped_mean(sim, obs, stats::cycle(sim)))
  }

  groups <- .hm_skge_month_groups_from_index(index)
  if (is.null(groups)) {
    return(metric_kge(as.numeric(sim), as.numeric(obs)))
  }

  .hm_skge_grouped_mean(sim, obs, groups)
}

core_metric_spec_skge <- function() {
  list(
    id = "skge",
    fun = metric_skge,
    name = "Seasonal KGE",
    description = "Seasonal KGE using monthly groups when monthly time context is available, otherwise falling back to KGE.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Seasonal KGE variant definition implemented per project decision pending definitive citation.",
    version_added = "0.1.0",
    tags = character()
  )
}

skge <- function(sim, obs, na.rm = NULL, ...) {
  payload <- preproc(sim = sim, obs = obs, na.rm = na.rm, ...)
  has_time_context <- inherits(sim, "ts") || inherits(obs, "ts") ||
    inherits(sim, "zoo") || inherits(sim, "xts") ||
    inherits(obs, "zoo") || inherits(obs, "xts")

  metric_skge(
    sim = payload$sim,
    obs = payload$obs,
    index = if (has_time_context) payload$index else NULL
  )
}
