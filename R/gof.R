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
    "hfb" = "hfb"
  )
}

.gof_hydrogof_labels <- function() {
  c(
    "me" = "ME",
    "mae" = "MAE",
    "mse" = "MSE",
    "rmse" = "RMSE",
    "ubrmse" = "ubRMSE",
    "nrmse" = "NRMSE %",
    "pbias" = "PBIAS %",
    "rsr" = "RSR",
    "rsd" = "rSD",
    "nse" = "NSE",
    "mnse" = "mNSE",
    "rnse" = "rNSE",
    "wnse" = "wNSE",
    "wsnse" = "wsNSE",
    "d" = "d",
    "dr" = "dr",
    "md" = "md",
    "rd" = "rd",
    "cp" = "cp",
    "r" = "r",
    "r2" = "R2",
    "br2" = "bR2",
    "ve" = "VE",
    "kge" = "KGE",
    "kgelf" = "KGElf",
    "kgenp" = "KGEnp",
    "kgekm" = "KGEkm"
  )
}

.gof_professional_labels <- function() {
  c(
    "alpha" = "Alpha",
    "anderson_darling_stat" = "Anderson-Darling",
    "baseflow_index_error" = "BFI Error",
    "beta" = "Beta",
    "br2" = "bR2",
    "ccc" = "CCC",
    "cdf_rmse" = "CDF-RMSE",
    "cp" = "CP",
    "d" = "d",
    "distribution_overlap" = "Distribution Overlap",
    "dr" = "dr",
    "e1" = "E1",
    "entropy_diff" = "Entropy Difference",
    "extended_valindex" = "Extended ValIndex",
    "extreme_event_ratio" = "Extreme Event Ratio",
    "fdc_highflow_bias" = "FDC High-Flow Bias",
    "fdc_lowflow_bias" = "FDC Low-Flow Bias",
    "fdc_shape_distance" = "FDC Shape Distance",
    "fdc_slope_error" = "FDC Slope Error",
    "flow_duration_entropy" = "Flow Duration Entropy",
    "huber_loss" = "Huber Loss",
    "hydrograph_slope_error" = "Hydrograph Slope Error",
    "iqr_error" = "IQR Error",
    "js_divergence" = "JS Divergence",
    "kge" = "KGE",
    "kgekm" = "KGEkm",
    "kgelf" = "KGElf",
    "kgenp" = "KGEnp",
    "kl_divergence" = "KL Divergence",
    "kl_divergence_flow" = "KL Divergence (Flow)",
    "ks_statistic" = "KS Statistic",
    "kurtosis_error" = "Kurtosis Error",
    "log_fdc_rmse" = "Log-FDC RMSE",
    "log_nse" = "Log-NSE",
    "log_rmse" = "Log-RMSE",
    "low_flow_bias" = "Low-Flow Bias",
    "mae" = "MAE",
    "mape" = "MAPE",
    "mare" = "MARE",
    "maxae" = "MaxAE",
    "md" = "md",
    "mdae" = "MdAE",
    "me" = "ME",
    "mnse" = "mNSE",
    "mpe" = "MPE",
    "mrb" = "MRB",
    "mse" = "MSE",
    "msle" = "MSLE",
    "mutual_information" = "Mutual Information",
    "mutual_information_score" = "MI Score",
    "normalised_mi" = "Normalized MI",
    "nrmse" = "NRMSE",
    "nrmse_range" = "NRMSE (Range)",
    "nrmse_sd" = "NRMSE (SD)",
    "nse" = "NSE",
    "pbias" = "PBIAS",
    "pbiasfdc" = "PBIAS-FDC",
    "peak_timing_error" = "Peak Timing Error",
    "pfactor" = "P-Factor",
    "quantile_deviation" = "Quantile Deviation",
    "quantile_kge" = "Quantile KGE",
    "quantile_loss" = "Quantile Loss",
    "quantile_shift_index" = "Quantile Shift Index",
    "r" = "r",
    "r2" = "R2",
    "rank_turnover_score" = "Rank Turnover Score",
    "rbias" = "RBias",
    "rd" = "rd",
    "rfactor" = "R-Factor",
    "rising_limb_error" = "Rising Limb Error",
    "rmse" = "RMSE",
    "rnse" = "rNSE",
    "rrmse" = "RRMSE",
    "rsd" = "rSD",
    "rspearman" = "Spearman rho",
    "rsr" = "RSR",
    "skewness_error" = "Skewness Error",
    "skge" = "sKGE",
    "smape" = "SMAPE",
    "sqrt_nse" = "Sqrt-NSE",
    "ssq" = "SSQ",
    "tail_dependence_score" = "Tail Dependence Score",
    "trimmed_rmse" = "Trimmed RMSE",
    "ubrmse" = "ubRMSE",
    "ve" = "VE",
    "wasserstein_distance" = "Wasserstein Distance",
    "weighted_kge" = "Weighted KGE",
    "winsor_rmse" = "Winsor RMSE",
    "wnse" = "wNSE",
    "wsnse" = "wsNSE"
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
  if (length(unknown) > 0L) {
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
    return(metric_params[[direct[[1L]]]])
  }

  lower <- tolower(nms)
  idx <- which(lower %in% c(tolower(metric_id), tolower(label)))
  if (length(idx) == 0L) {
    return(NULL)
  }

  metric_params[[idx[[1L]]]]
}

.gof_normalize_metric_calls <- function(ids, labels, metric_params = NULL) {
  if (length(ids) != length(labels)) {
    stop("Internal error: metric id/label length mismatch.", call. = FALSE)
  }

  if (!is.null(metric_params) && length(ids) == 1L && is.null(names(metric_params))) {
    if (!is.list(metric_params)) {
      stop("`metric_params` must be a list.", call. = FALSE)
    }
    return(list(list(id = ids[[1L]], params = metric_params)))
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
      if (!isTRUE(epsilon_missing) &&
          !is.null(epsilon) &&
          !isTRUE(all.equal(as.numeric(epsilon), as.numeric(epsilon.value)))) {
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

.gof_normalize_preset <- function(preset) {
  if (is.null(preset)) {
    return(NULL)
  }

  if (!is.character(preset) || length(preset) != 1L || is.na(preset) || !nzchar(preset)) {
    stop("`preset` must be NULL or a non-empty character scalar.", call. = FALSE)
  }

  preset <- tolower(preset)
  if (!preset %in% c("recommended", "hydrogof")) {
    stop("`preset` must be one of 'recommended' or 'hydrogof'.", call. = FALSE)
  }

  preset
}

.gof_apply_legacy_defaults <- function(
  preset = NULL,
  output = c("vector", "matrix"),
  labels = c("requested", "canonical", "hydrogof", "professional")
) {
  preset <- .gof_normalize_preset(preset)
  output <- match.arg(output)
  labels <- match.arg(labels)

  if (identical(preset, "hydrogof")) {
    output <- "matrix"
    labels <- "hydrogof"
  }

  list(preset = preset, output = output, labels = labels)
}

.gof_output_labels <- function(ids, requested, labels = c("requested", "canonical", "hydrogof", "professional")) {
  labels <- match.arg(labels)

  if (identical(labels, "canonical")) {
    return(ids)
  }

  if (identical(labels, "requested")) {
    return(requested)
  }

  if (identical(labels, "hydrogof")) {
    map <- .gof_hydrogof_labels()
    out <- unname(map[ids])
    missing <- is.na(out)
    out[missing] <- requested[missing]
    return(out)
  }

  map <- .gof_professional_labels()
  out <- unname(map[ids])
  missing <- is.na(out)
  out[missing] <- requested[missing]
  out
}

.gof_format_single_output <- function(vals,
                                      ids,
                                      requested,
                                      output = c("vector", "matrix"),
                                      labels = c("requested", "canonical", "hydrogof", "professional")) {
  output <- match.arg(output)
  out_labels <- .gof_output_labels(ids, requested, labels = labels)

  if (identical(output, "vector")) {
    names(vals) <- out_labels
    return(vals)
  }

  mat <- matrix(vals, ncol = 1L)
  rownames(mat) <- out_labels
  colnames(mat) <- NULL
  mat
}

.gof_format_multi_output <- function(metrics_mat,
                                     ids,
                                     requested,
                                     labels = c("requested", "canonical", "hydrogof", "professional")) {
  out_labels <- .gof_output_labels(ids, requested, labels = labels)
  rownames(metrics_mat) <- out_labels
  metrics_mat
}

#' Evaluate hydrological metrics
#'
#' Stable orchestration entry point that preprocesses aligned series and
#' dispatches registered metric implementations without embedding metric
#' formulas in the public API layer. Uppercase hydroGOF-style method labels
#' such as `"NSE"` and `"KGE"` are accepted as orchestration labels only and
#' are not exported standalone functions. Deprecated labels such as
#' `"rPearson"` resolve to canonical metric ids during method selection.
#'
#' Stable condition contract: `gof()` errors on invalid `extended` values,
#' invalid `preset`, unknown metric labels, incompatible single-series versus
#' matrix-like input shapes, multi-series dimension mismatch, invalid
#' compatibility alias values, and preprocessing or metric-domain failures
#' inherited from [preproc()] and the selected metrics. Missing-data handling
#' follows `na_strategy`; plain `"fail"` preserves missing-value errors,
#' `"remove"` drops incomplete pairs, and `"pairwise"` keeps aligned vectors
#' for downstream pairwise-capable metrics.
#'
#' @param sim Simulated values supplied as a numeric vector, `ts`, matrix-like
#'   object, or aligned `zoo`/`xts` series.
#' @param obs Observed values with the same shape contract as `sim`.
#' @param methods Metric names to evaluate. When omitted, the package default
#'   curated hydrology summary set is used unless `preset` is supplied or
#'   `extended = TRUE`.
#' @param preset Optional preset method bundle. Use `"hydrogof"` for a
#'   hydroGOF-style legacy metric bundle or `"recommended"` for the package
#'   default set.
#' @param extended Whether omitted/`NULL` method selection should expand from
#'   the default summary set to all registered metrics that are applicable to
#'   the current input context.
#' @param output Output shape for single-series results: `"vector"` or
#'   `"matrix"`. `preset = "hydrogof"` forces `"matrix"`.
#' @param labels Label style for reported metrics: `"requested"`,
#'   `"canonical"`, `"hydrogof"`, or `"professional"`.
#'   `preset = "hydrogof"` forces `"hydrogof"` labels.
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
#' @return A numeric vector or matrix, depending on input shape and `output`,
#'   with class `"hydro_metrics"`. Single-series inputs return a named vector
#'   by default and can return a 1-column matrix when `output = "matrix"`.
#'   Multi-series inputs return a named numeric matrix. Additional metadata is
#'   attached via the `n_obs`, `meta`, and `call` attributes.
#'
#' @examples
#' sim <- c(1, 2, 3, 4)
#' obs <- c(1, 2, 2, 4)
#'
#' gof(sim, obs, methods = c("NSE", "rmse"))
#' gof(sim, obs, fun = "rmse", na.rm = FALSE)
#' gof(sim, obs, preset = "hydrogof")
#' gof(sim, obs, extended = TRUE)
#' gof(sim, obs, extended = TRUE, output = "matrix", labels = "professional")
#' @export
gof <- function(sim,
                obs,
                methods = NULL,
                preset = NULL,
                extended = FALSE,
                output = c("vector", "matrix"),
                labels = c("requested", "canonical", "hydrogof", "professional"),
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

  legacy <- .gof_apply_legacy_defaults(
    preset = preset,
    output = output,
    labels = labels
  )
  preset <- legacy$preset
  output <- legacy$output
  labels <- legacy$labels

  na_strategy <- match.arg(na_strategy)
  transform <- match.arg(transform)
  epsilon_mode <- match.arg(epsilon_mode)

  dots <- list(...)
  metric_params <- dots$metric_params

  prepared <- .gof_prepare_inputs(sim, obs)
  engine <- .get_engine()
  available_ids <- as.character(.get_registry()$list()$id)

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
      preset = preset,
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

    formatted <- .gof_format_single_output(
      vals = as.numeric(out$value),
      ids = resolved$ids,
      requested = resolved$labels,
      output = output,
      labels = labels
    )

    return(
      .new_hydro_metrics(
        metrics = formatted,
        n_obs = as.integer(length(runtime_payload$sim)),
        meta = list(
          transform = transform,
          na_strategy = na_strategy,
          epsilon_mode = epsilon_mode,
          components = isTRUE(components),
          preset = preset,
          output = output,
          labels = labels,
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
    preset = preset,
    extended = extended,
    sim = prepared$sim[, 1L],
    obs = prepared$obs[, 1L],
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

  metrics_mat <- .gof_format_multi_output(
    metrics_mat = metrics_mat,
    ids = resolved$ids,
    requested = resolved$labels,
    labels = labels
  )

  .new_hydro_metrics(
    metrics = metrics_mat,
    n_obs = n_obs,
    meta = list(
      transform = transform,
      na_strategy = na_strategy,
      epsilon_mode = epsilon_mode,
      components = isTRUE(components),
      preset = preset,
      output = output,
      labels = labels
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
  payload <- .hydro_metrics_payload(x)

  attr(payload, "n_obs") <- NULL
  attr(payload, "meta") <- NULL
  attr(payload, "call") <- NULL

  print(payload, ...)
  invisible(x)
}
#' Data-frame coercion for hydro_metrics
#'
#' @param x A `"hydro_metrics"` object.
#' @param row.names `NULL` or a character vector of row names.
#' @param optional Unused.
#' @param ... Unused.
#'
#' @return A data frame representation of `x`.
#'   Single-series vector outputs become a two-column data frame with
#'   `metric` and `value`. Single-series 1-column matrix outputs also become
#'   a two-column data frame. Multi-series matrix outputs become a data frame
#'   with metric names as row names.
#' @rdname hydro-orchestration-methods
#' @export
as.data.frame.hydro_metrics <- function(x, row.names = NULL, optional = FALSE, ...) {
  payload <- .hydro_metrics_payload(x)

  attr(payload, "n_obs") <- NULL
  attr(payload, "meta") <- NULL
  attr(payload, "call") <- NULL

  if (is.null(dim(payload))) {
    out <- data.frame(
      metric = names(payload),
      value = as.numeric(payload),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    if (!is.null(row.names)) {
      rownames(out) <- row.names
    }
    return(out)
  }

  if (is.matrix(payload) && ncol(payload) == 1L) {
    out <- data.frame(
      metric = rownames(payload),
      value = as.numeric(payload[, 1]),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    if (!is.null(row.names)) {
      rownames(out) <- row.names
    }
    return(out)
  }

  as.data.frame(payload, row.names = row.names, optional = optional, ...)
}
