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
    "rpearson" = "r",
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
    "pbiasfdc" = "pbiasfdc",
    "apfb" = "apfb",
    "hfb" = "hfb"
  )
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
    ids = .hm_canonicalize_metric_ids(unname(alias[keys]), warn = TRUE),
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
    return(list(type = "single", sim = x, obs = y, series_names = "model1"))
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
    series_names <- paste0("model", seq_len(ncol(x_mat)))
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

.new_hydro_metrics <- function(metrics, n_obs, meta, call) {
  out <- metrics
  attr(out, "n_obs") <- n_obs
  attr(out, "meta") <- meta
  attr(out, "call") <- call

  base_class <- class(metrics)
  if (length(base_class) > 0L) {
    class(out) <- c("hydro_metrics", base_class)
  } else {
    class(out) <- "hydro_metrics"
  }

  out
}

.hydro_metrics_payload <- function(x) {
  class(x) <- setdiff(class(x), "hydro_metrics")
  x
}

.gof_preproc_call <- function(sim, obs, na_strategy, transform, epsilon_mode, epsilon, epsilon_factor) {
  payload <- preproc(
    sim = sim,
    obs = obs,
    na_strategy = na_strategy,
    transform = transform,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor
  )

  list(
    sim = payload$sim,
    obs = payload$obs,
    index = payload$index,
    meta = list(
      n_original = payload$n_original,
      n_aligned = payload$n_aligned,
      n_used = payload$n,
      n_removed_na = payload$n_removed_na,
      transform = transform,
      epsilon_mode = epsilon_mode
    )
  )
}

.gof_runtime_metric_calls <- function(metric_calls, payload) {
  lapply(metric_calls, function(call) {
    params <- call$params
    if (call$id %in% c("apfb", "seasonal_bias") && is.null(params$index)) {
      params$index <- payload$index
    }
    call$params <- params
    call
  })
}

.gof_materialize_payload <- function(payload, na_strategy) {
  if (!identical(na_strategy, "pairwise")) {
    return(payload)
  }

  .hm_materialize_pairwise_payload(payload)
}

.hm_resolve_epsilon_type <- function(epsilon_type, epsilon_mode, epsilon_mode_missing) {
  if (is.null(epsilon_type)) {
    return(epsilon_mode)
  }

  if (!is.character(epsilon_type) || length(epsilon_type) != 1L || is.na(epsilon_type) || !nzchar(epsilon_type)) {
    stop("`epsilon.type` must be a non-empty character scalar.", call. = FALSE)
  }

  alias_map <- c(
    constant = "constant",
    othervalue = "constant",
    auto_min_positive = "auto_min_positive",
    obs_mean_factor = "obs_mean_factor",
    otherfactor = "obs_mean_factor"
  )
  key <- tolower(epsilon_type)
  if (!key %in% names(alias_map)) {
    stop(
      "`epsilon.type` must be one of 'constant', 'auto_min_positive', 'obs_mean_factor', 'otherValue', or 'otherFactor'.",
      call. = FALSE
    )
  }

  mapped <- unname(alias_map[[key]])
  if (!isTRUE(epsilon_mode_missing) && !identical(mapped, epsilon_mode)) {
    stop("`epsilon.type` conflicts with `epsilon_mode`.", call. = FALSE)
  }

  mapped
}

.hm_apply_orchestration_compat <- function(methods,
                                           na_strategy,
                                           epsilon_mode,
                                           epsilon,
                                           epsilon_factor,
                                           fun = NULL,
                                           na.rm = NULL,
                                           keep = NULL,
                                           epsilon.type = NULL,
                                           epsilon.value = NULL,
                                           na_strategy_missing = FALSE,
                                           epsilon_mode_missing = FALSE,
                                           epsilon_missing = FALSE,
                                           epsilon_factor_missing = FALSE) {
  if (is.null(methods) && !is.null(fun)) {
    methods <- fun
  }

  if (!is.null(na.rm)) {
    if (!is.logical(na.rm) || length(na.rm) != 1L || is.na(na.rm)) {
      stop("`na.rm` must be TRUE or FALSE.", call. = FALSE)
    }
    na_strategy <- if (isTRUE(na.rm)) "remove" else "fail"
  } else if (!is.null(keep) && isTRUE(na_strategy_missing)) {
    keep <- match.arg(keep, choices = c("complete", "pairwise"))
    na_strategy <- if (identical(keep, "pairwise")) "pairwise" else "remove"
  }

  epsilon_mode <- .hm_resolve_epsilon_type(
    epsilon_type = epsilon.type,
    epsilon_mode = epsilon_mode,
    epsilon_mode_missing = epsilon_mode_missing
  )

  if (!is.null(epsilon.value)) {
    if (!is.numeric(epsilon.value) || length(epsilon.value) != 1L || is.na(epsilon.value)) {
      stop("`epsilon.value` must be a non-missing numeric scalar.", call. = FALSE)
    }

    if (identical(epsilon_mode, "constant")) {
      if (!isTRUE(epsilon_missing) && !is.null(epsilon) && !isTRUE(all.equal(as.numeric(epsilon), as.numeric(epsilon.value)))) {
        stop("`epsilon.value` conflicts with `epsilon`.", call. = FALSE)
      }
      epsilon <- as.numeric(epsilon.value)
    } else {
      if (!isTRUE(epsilon_factor_missing) &&
          !isTRUE(all.equal(as.numeric(epsilon_factor), as.numeric(epsilon.value)))) {
        stop("`epsilon.value` conflicts with `epsilon_factor`.", call. = FALSE)
      }
      epsilon_factor <- as.numeric(epsilon.value)
    }
  }

  list(
    methods = methods,
    na_strategy = na_strategy,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor
  )
}

#' Evaluate hydrological metrics
#'
#' Clean-room orchestration wrapper that preprocesses aligned series and
#' dispatches registered metric implementations without embedding metric
#' formulas in the public API layer.
#'
#' @param sim Simulated values supplied as a numeric vector, `ts`, matrix-like
#'   object, or aligned `zoo`/`xts` series.
#' @param obs Observed values with the same shape contract as `sim`.
#' @param methods Metric names to evaluate. When omitted, the package default
#'   compat-10 set is used unless `extended = TRUE`.
#' @param extended Whether omitted/`NULL` method selection should expand from
#'   the compat-10 default set to all registered metrics that are applicable to
#'   the current input context.
#' @param na_strategy Missing-value strategy forwarded to [preproc()].
#' @param transform Transform mode forwarded to [preproc()].
#' @param epsilon_mode Epsilon policy forwarded to [preproc()].
#' @param epsilon Optional constant epsilon value used when
#'   `epsilon_mode = "constant"`.
#' @param epsilon_factor Scaling factor for automatic epsilon modes.
#' @param components Compatibility flag retained in output metadata.
#' @param fun Optional compatibility alias for `methods`.
#' @param na.rm Optional compatibility alias for NA handling. `TRUE` maps to
#'   `na_strategy = "remove"` and `FALSE` maps to `"fail"`.
#' @param keep Optional compatibility alias for NA handling. `"complete"` maps
#'   to `na_strategy = "remove"` and `"pairwise"` maps to `"pairwise"`.
#' @param epsilon.type Optional compatibility alias for `epsilon_mode`. Supported
#'   local spellings are `"constant"`, `"auto_min_positive"`,
#'   `"obs_mean_factor"`, `"otherValue"`, and `"otherFactor"`.
#' @param epsilon.value Optional compatibility alias for the epsilon numeric
#'   value. It maps to `epsilon` when `epsilon_mode = "constant"` and to
#'   `epsilon_factor` otherwise.
#' @param ... Additional compatibility arguments, including `metric_params`.
#'
#' @return A named numeric vector for single-series inputs or a named numeric
#'   matrix for multi-series inputs, with class `"hydro_metrics"`. Additional
#'   metadata is attached via the `n_obs`, `meta`, and `call` attributes.
#'
#' @examples
#' sim <- c(1, 2, 3, 4)
#' obs <- c(1, 2, 2, 4)
#'
#' gof(sim, obs, methods = c("NSE", "rmse"))
#' gof(sim, obs, fun = "rmse", na.rm = FALSE)
#' @export
gof <- function(sim,
                obs,
                methods = NULL,
                extended = FALSE,
                na_strategy = c("fail", "remove", "pairwise"),
                transform = c("none", "log", "sqrt", "reciprocal"),
                epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                epsilon = NULL,
                epsilon_factor = 1,
                components = FALSE,
                fun = NULL,
                na.rm = NULL,
                keep = NULL,
                epsilon.type = NULL,
                epsilon.value = NULL,
                ...) {
  na_strategy_missing <- missing(na_strategy)
  epsilon_mode_missing <- missing(epsilon_mode)
  epsilon_missing <- missing(epsilon)
  epsilon_factor_missing <- missing(epsilon_factor)

  compat <- .hm_apply_orchestration_compat(
    methods = methods,
    na_strategy = na_strategy,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor,
    fun = fun,
    na.rm = na.rm,
    keep = keep,
    epsilon.type = epsilon.type,
    epsilon.value = epsilon.value,
    na_strategy_missing = na_strategy_missing,
    epsilon_mode_missing = epsilon_mode_missing,
    epsilon_missing = epsilon_missing,
    epsilon_factor_missing = epsilon_factor_missing
  )
  methods <- compat$methods
  na_strategy <- compat$na_strategy
  epsilon_mode <- compat$epsilon_mode
  epsilon <- compat$epsilon
  epsilon_factor <- compat$epsilon_factor

  if (!is.logical(extended) || length(extended) != 1L || is.na(extended)) {
    stop("`extended` must be TRUE or FALSE.", call. = FALSE)
  }

  na_strategy <- match.arg(na_strategy)
  transform <- match.arg(transform)
  epsilon_mode <- match.arg(epsilon_mode)

  dots <- list(...)
  metric_params <- dots$metric_params

  prepared <- .gof_prepare_inputs(sim, obs)
  engine <- .get_engine()
  available_ids <- as.character(.get_registry()$list()$id)
  available_alias <- .gof_alias_map()
  available_alias <- available_alias[available_alias %in% available_ids]

  if (identical(prepared$type, "single")) {
    payload <- .gof_preproc_call(
      sim = prepared$sim,
      obs = prepared$obs,
      na_strategy = na_strategy,
      transform = transform,
      epsilon_mode = epsilon_mode,
      epsilon = epsilon,
      epsilon_factor = epsilon_factor
    )
    runtime_payload <- .gof_materialize_payload(payload, na_strategy = na_strategy)
    requested <- .gof_select_methods(
      methods = methods,
      available_ids = available_ids,
      extended = extended,
      sim = runtime_payload$sim,
      obs = runtime_payload$obs,
      index = runtime_payload$index
    )
    if (length(requested) == 0L) {
      stop("No valid methods available for gof().", call. = FALSE)
    }
    resolved <- .gof_resolve_methods(requested)
    metric_calls <- .gof_normalize_metric_calls(
      ids = resolved$ids,
      labels = resolved$labels,
      metric_params = metric_params
    )
    runtime_calls <- .gof_runtime_metric_calls(metric_calls, runtime_payload)
    out <- engine$evaluate(runtime_payload$sim, runtime_payload$obs, runtime_calls)
    vals <- as.numeric(out$value)
    names(vals) <- resolved$labels

    return(
      .new_hydro_metrics(
        metrics = vals,
        n_obs = as.integer(length(runtime_payload$sim)),
        meta = list(
          transform = transform,
          na_strategy = na_strategy,
          epsilon_mode = epsilon_mode,
          components = isTRUE(components),
          n_original = as.integer(runtime_payload$meta$n_original),
          n_aligned = as.integer(runtime_payload$meta$n_aligned),
          n_removed_na = as.integer(runtime_payload$meta$n_removed_na),
          aligned = isTRUE(runtime_payload$meta$n_original == runtime_payload$meta$n_aligned),
          index = runtime_payload$index,
          sim_used = runtime_payload$sim,
          obs_used = runtime_payload$obs
        ),
        call = match.call()
      )
    )
  }

  requested <- .gof_select_methods(
    methods = methods,
    available_ids = available_ids,
    extended = extended,
    sim = NULL,
    obs = NULL,
    index = NULL
  )
  if (length(requested) == 0L) {
    stop("No valid methods available for gof().", call. = FALSE)
  }
  resolved <- .gof_resolve_methods(requested)
  metric_calls <- .gof_normalize_metric_calls(
    ids = resolved$ids,
    labels = resolved$labels,
    metric_params = metric_params
  )

  metrics_mat <- matrix(
    NA_real_,
    nrow = length(resolved$labels),
    ncol = ncol(prepared$sim),
    dimnames = list(resolved$labels, prepared$series_names)
  )
  n_obs <- rep(NA_integer_, ncol(prepared$sim))
  names(n_obs) <- prepared$series_names

  for (j in seq_len(ncol(prepared$sim))) {
    payload <- .gof_preproc_call(
      sim = prepared$sim[, j],
      obs = prepared$obs[, j],
      na_strategy = na_strategy,
      transform = transform,
      epsilon_mode = epsilon_mode,
      epsilon = epsilon,
      epsilon_factor = epsilon_factor
    )
    runtime_payload <- .gof_materialize_payload(payload, na_strategy = na_strategy)
    runtime_calls <- .gof_runtime_metric_calls(metric_calls, runtime_payload)
    out <- engine$evaluate(runtime_payload$sim, runtime_payload$obs, runtime_calls)
    metrics_mat[, j] <- as.numeric(out$value)
    n_obs[[j]] <- as.integer(length(runtime_payload$sim))
  }

  .new_hydro_metrics(
    metrics = metrics_mat,
    n_obs = n_obs,
    meta = list(
      transform = transform,
      na_strategy = na_strategy,
      epsilon_mode = epsilon_mode,
      components = isTRUE(components)
    ),
    call = match.call()
  )
}

#' Numeric coercion for hydro_metrics
#'
#' @param x A `"hydro_metrics"` object.
#' @param ... Unused.
#'
#' @return The numeric metric values carried by `x`.
#' @rdname hydro-orchestration-methods
#' @export
as.numeric.hydro_metrics <- function(x, ...) {
  as.numeric(.hydro_metrics_payload(x))
}

#' Double coercion for hydro_metrics
#'
#' @param x A `"hydro_metrics"` object.
#' @param ... Unused.
#'
#' @return The numeric metric values carried by `x`.
#' @rdname hydro-orchestration-methods
#' @export
as.double.hydro_metrics <- function(x, ...) {
  as.double(.hydro_metrics_payload(x))
}

#' Print a hydro_metrics object
#'
#' @param x A `"hydro_metrics"` object.
#' @param ... Additional arguments passed to [print()].
#'
#' @return The input object, invisibly.
#' @rdname hydro-orchestration-methods
#' @export
print.hydro_metrics <- function(x, ...) {
  print(.hydro_metrics_payload(x), ...)
  invisible(x)
}
