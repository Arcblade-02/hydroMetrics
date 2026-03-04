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

.gof_is_single_series <- function(x, arg_name) {
  if (.hm_is_numeric_vector(x)) {
    return(TRUE)
  }

  if (inherits(x, "ts")) {
    return(is.null(dim(x)) || NCOL(x) == 1L)
  }

  if (inherits(x, "zoo") || inherits(x, "xts")) {
    if (!requireNamespace("zoo", quietly = TRUE)) {
      stop("zoo/xts input requires the 'zoo' package to be installed.", call. = FALSE)
    }
    core <- zoo::coredata(x)
    if (!is.numeric(core)) {
      stop(sprintf("`%s` must be numeric.", arg_name), call. = FALSE)
    }
    return(NCOL(core) == 1L)
  }

  FALSE
}

.gof_prepare_inputs <- function(x, y) {
  x_single <- .gof_is_single_series(x, "sim")
  y_single <- .gof_is_single_series(y, "obs")

  if (xor(x_single, y_single)) {
    stop("`sim` and `obs` must both be single-series or both be matrix-like inputs.", call. = FALSE)
  }

  if (x_single && y_single) {
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

.gof_lookup_metric_params <- function(metric_params, metric_id, label) {
  if (is.null(metric_params)) {
    return(NULL)
  }

  if (!is.list(metric_params)) {
    stop("`metric_params` must be a list.", call. = FALSE)
  }

  nms <- names(metric_params)
  if (is.null(nms)) {
    return(NULL)
  }

  direct <- which(nms %in% c(metric_id, label))
  if (length(direct) > 0L) {
    return(metric_params[[direct[[1]]]])
  }

  lower <- tolower(nms)
  idx <- which(lower %in% c(tolower(metric_id), tolower(label)))
  if (length(idx) == 0L) {
    return(NULL)
  }

  metric_params[[idx[[1]]]]
}

.gof_normalize_metric_calls <- function(ids, labels, metric_params = NULL) {
  if (length(ids) != length(labels)) {
    stop("Internal error: metric id/label length mismatch.", call. = FALSE)
  }

  if (!is.null(metric_params) && length(ids) == 1L && is.null(names(metric_params))) {
    if (!is.list(metric_params)) {
      stop("`metric_params` must be a list.", call. = FALSE)
    }
    return(list(list(id = ids[[1]], params = metric_params)))
  }

  lapply(seq_along(ids), function(i) {
    params <- .gof_lookup_metric_params(metric_params, metric_id = ids[[i]], label = labels[[i]])
    if (is.null(params)) {
      params <- list()
    }
    if (!is.list(params)) {
      stop(sprintf("`metric_params` for '%s' must be a list.", labels[[i]]), call. = FALSE)
    }
    list(id = ids[[i]], params = params)
  })
}

gof <- function(sim,
                obs,
                fun = NULL,
                methods = NULL,
                na.rm = FALSE,
                keep = c("complete", "pairwise"),
                na_strategy = c("fail", "remove", "pairwise"),
                transform = c("none", "log", "sqrt", "reciprocal"),
                epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                epsilon = NULL,
                epsilon_factor = 1,
                ...) {
  keep <- match.arg(keep)
  na_strategy <- match.arg(na_strategy)
  transform <- match.arg(transform)
  epsilon_mode <- match.arg(epsilon_mode)

  if (!missing(na.rm)) {
    if (!is.logical(na.rm) || length(na.rm) != 1L || is.na(na.rm)) {
      stop("`na.rm` must be TRUE or FALSE.", call. = FALSE)
    }
    na_strategy <- if (isTRUE(na.rm)) "remove" else "fail"
  } else if (missing(na_strategy) && identical(keep, "pairwise")) {
    na_strategy <- "pairwise"
  }

  dots <- list(...)
  metric_params <- dots$metric_params

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
  metric_calls <- .gof_normalize_metric_calls(
    ids = resolved$ids,
    labels = resolved$labels,
    metric_params = metric_params
  )
  prepared <- .gof_prepare_inputs(sim, obs)

  if (prepared$type == "vector") {
    payload <- .hm_prepare_inputs(
      sim = prepared$sim,
      obs = prepared$obs,
      na_strategy = na_strategy,
      transform = transform,
      epsilon_mode = epsilon_mode,
      epsilon = epsilon,
      epsilon_factor = epsilon_factor
    )
    out <- .get_engine()$evaluate(payload$sim, payload$obs, metric_calls)
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
    payload <- .hm_prepare_inputs(
      sim = prepared$sim[, j],
      obs = prepared$obs[, j],
      na_strategy = na_strategy,
      transform = transform,
      epsilon_mode = epsilon_mode,
      epsilon = epsilon,
      epsilon_factor = epsilon_factor
    )
    out <- .get_engine()$evaluate(payload$sim, payload$obs, metric_calls)
    res[, j] <- as.numeric(out$value)
  }

  res
}
