.valindex_score_one <- function(metric, value) {
  key <- tolower(metric)

  if (key %in% c("nse", "kge")) {
    return(pmax(pmin(value, 1), 0))
  }
  if (key == "rpearson") {
    return((pmax(pmin(value, 1), -1) + 1) / 2)
  }
  if (key == "rmse") {
    return(1 / (1 + pmax(value, 0)))
  }
  if (key == "pbias") {
    return(1 / (1 + abs(value)))
  }

  stop(
    sprintf(
      "Unsupported metric '%s' for valindex normalization. Supported: NSE, KGE, rmse, pbias, rPearson.",
      metric
    ),
    call. = FALSE
  )
}

.valindex_resolve_weights <- function(weights, n_metrics) {
  if (is.null(weights)) {
    return(rep(1 / n_metrics, n_metrics))
  }

  if (!is.numeric(weights) || length(weights) != n_metrics) {
    stop("`weights` must be a numeric vector with the same length as `metrics`.", call. = FALSE)
  }
  if (anyNA(weights) || any(weights < 0)) {
    stop("`weights` must be non-missing and nonnegative.", call. = FALSE)
  }

  total <- sum(weights)
  if (total <= 0) {
    stop("`weights` must have a positive sum.", call. = FALSE)
  }

  as.numeric(weights / total)
}

.valindex_combine <- function(values, labels, weights, na.rm) {
  scores <- mapply(
    FUN = .valindex_score_one,
    metric = labels,
    value = values,
    SIMPLIFY = TRUE,
    USE.NAMES = FALSE
  )

  if (anyNA(scores)) {
    if (!isTRUE(na.rm)) {
      stop("valindex encountered NA metric values and `na.rm` is FALSE.", call. = FALSE)
    }
    keep <- !is.na(scores)
    if (!any(keep)) {
      stop("valindex encountered only NA metric values for this series.", call. = FALSE)
    }
    scores <- scores[keep]
    weights <- weights[keep]
    weights <- weights / sum(weights)
  }

  sum(scores * weights)
}

valindex <- function(sim,
                     obs,
                     metrics = c("NSE", "KGE", "rmse", "pbias", "rPearson"),
                     weights = NULL,
                     na.rm = TRUE,
                     ...) {
  if (!is.character(metrics) || length(metrics) == 0L || any(!nzchar(metrics))) {
    stop("`metrics` must be a non-empty character vector.", call. = FALSE)
  }

  method_labels <- as.character(metrics)
  weights_norm <- .valindex_resolve_weights(weights, length(method_labels))
  values <- gof(sim = sim, obs = obs, methods = method_labels, ...)

  if (is.numeric(values) && !is.matrix(values)) {
    score <- .valindex_combine(
      values = as.numeric(values),
      labels = method_labels,
      weights = weights_norm,
      na.rm = na.rm
    )
    return(as.numeric(score))
  }

  series_scores <- apply(values, 2, function(col_values) {
    .valindex_combine(
      values = as.numeric(col_values),
      labels = method_labels,
      weights = weights_norm,
      na.rm = na.rm
    )
  })

  matrix(
    as.numeric(series_scores),
    nrow = 1L,
    dimnames = list("valindex", colnames(values))
  )
}
