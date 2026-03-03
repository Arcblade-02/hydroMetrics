.gof_alias_map <- function() {
  c(
    "nse" = "nse",
    "kge" = "kge",
    "rmse" = "rmse",
    "pbias" = "pbias",
    "cp" = "cp",
    "pfactor" = "pfactor",
    "rfactor" = "rfactor",
    "mae" = "mae",
    "mse" = "mse",
    "r2" = "r2",
    "ve" = "ve",
    "rsr" = "rsr",
    "nrmse" = "nrmse",
    "rpearson" = "rpearson",
    "rspearman" = "rspearman",
    "rsd" = "rsd",
    "rnse" = "rnse",
    "mnse" = "mnse",
    "wnse" = "wnse",
    "wsnse" = "wsnse",
    "ubrmse" = "ubrmse",
    "ssq" = "ssq",
    "kgekm" = "kgekm",
    "kgelf" = "kgelf",
    "kgenp" = "kgenp",
    "skge" = "skge",
    "pbiasfdc" = "pbiasfdc"
  )
}

.gof_default_methods <- function() {
  c("NSE", "KGE", "rmse", "pbias", "mae", "mse", "R2", "VE", "rsr", "nrmse")
}

.gof_resolve_methods <- function(requested) {
  available <- .get_registry()$list()
  available_ids <- as.character(available$id)
  available_map <- stats::setNames(available_ids, tolower(available_ids))

  alias <- available_map
  extra_alias <- .gof_alias_map()
  for (k in names(extra_alias)) {
    id <- extra_alias[[k]]
    if (id %in% available_ids) {
      alias[[k]] <- id
    }
  }

  keys <- tolower(requested)
  unknown <- requested[!keys %in% names(alias)]
  if (length(unknown) > 0) {
    stop(
      sprintf(
        "Unknown metric(s): %s. Use available metrics: %s",
        paste(unknown, collapse = ", "),
        paste(sort(available_ids), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  list(
    ids = unname(alias[keys]),
    labels = requested
  )
}

.gof_prepare_inputs <- function(x, y) {
  if (is.vector(x) && is.atomic(x) && is.vector(y) && is.atomic(y)) {
    return(list(type = "vector", sim = x, obs = y, series_names = NULL))
  }

  x_mat <- as.matrix(x)
  y_mat <- as.matrix(y)
  if (!is.numeric(x_mat) || !is.numeric(y_mat)) {
    stop("`sim` and `obs` must be numeric vectors/matrices/data.frames/ts/zoo.", call. = FALSE)
  }
  if (!all(dim(x_mat) == dim(y_mat))) {
    stop("`sim` and `obs` must have the same dimensions for multi-series gof().", call. = FALSE)
  }

  series_names <- colnames(x_mat)
  if (is.null(series_names)) {
    series_names <- paste0("series", seq_len(ncol(x_mat)))
  }

  list(type = "multi", sim = x_mat, obs = y_mat, series_names = series_names)
}

#' Compute Hydrological Goodness-of-Fit Metrics
#'
#' Computes one or more registered metrics for simulated (`sim`) and observed (`obs`) values.
#'
#' @param sim Numeric simulated values; a vector for a single series or a matrix/data.frame/ts/zoo for multiple series.
#' @param obs Numeric observed values with the same shape as `sim`.
#' @param fun Optional metric name(s), kept for hydroGOF compatibility.
#' @param methods Metric name(s) to evaluate. If both `methods` and `fun` are `NULL`, default methods are used.
#' @param ... Additional arguments reserved for compatibility.
#'
#' @details Argument order is `sim, obs` (simulation first, observation second).
#'
#' @return For single-series input, a named numeric vector. For multi-series input, a numeric matrix
#'   with metrics in rows and series in columns.
#' @export
gof <- function(sim, obs, fun = NULL, methods = NULL, ...) {
  available_ids <- as.character(.get_registry()$list()$id)
  available_alias <- .gof_alias_map()
  available_alias <- available_alias[available_alias %in% available_ids]

  requested <- unique(c(as.character(methods), as.character(fun)))
  if (length(requested) == 0L || all(!nzchar(requested))) {
    defaults <- .gof_default_methods()
    resolved_defaults <- defaults[tolower(defaults) %in% names(available_alias)]
    requested <- resolved_defaults
  }
  requested <- requested[nzchar(requested)]
  if (length(requested) == 0L) {
    stop("No valid methods available for gof().", call. = FALSE)
  }

  resolved <- .gof_resolve_methods(requested)
  prepared <- .gof_prepare_inputs(sim, obs)

  if (prepared$type == "vector") {
    out <- evaluate_metrics(prepared$sim, prepared$obs, resolved$ids)
    vals <- as.numeric(out$value)
    names(vals) <- resolved$labels
    return(vals)
  }

  res <- matrix(
    NA_real_,
    nrow = length(resolved$ids),
    ncol = ncol(prepared$sim),
    dimnames = list(resolved$labels, prepared$series_names)
  )

  for (j in seq_len(ncol(prepared$sim))) {
    out <- evaluate_metrics(prepared$sim[, j], prepared$obs[, j], resolved$ids)
    res[, j] <- as.numeric(out$value)
  }

  res
}
