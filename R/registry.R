.hm_state <- new.env(parent = emptyenv())

register_core_metrics <- function(registry) {
  if (!inherits(registry, "MetricRegistry")) {
    stop("`registry` must be a MetricRegistry instance.", call. = FALSE)
  }

  specs <- list(
    core_metric_spec_nse(),
    core_metric_spec_rmse(),
    core_metric_spec_pbias(),
    core_metric_spec_cp(),
    core_metric_spec_pfactor(),
    core_metric_spec_rfactor(),
    core_metric_spec_mae(),
    core_metric_spec_mdae(),
    core_metric_spec_maxae(),
    core_metric_spec_smape(),
    core_metric_spec_mare(),
    core_metric_spec_mrb(),
    core_metric_spec_mse(),
    core_metric_spec_nrmse(),
    core_metric_spec_rrmse(),
    core_metric_spec_msle(),
    core_metric_spec_log_rmse(),
    core_metric_spec_nrmse_range(),
    core_metric_spec_fdc_slope_error(),
    core_metric_spec_fdc_highflow_bias(),
    core_metric_spec_fdc_lowflow_bias(),
    core_metric_spec_log_fdc_rmse(),
    core_metric_spec_low_flow_bias(),
    core_metric_spec_huber_loss(),
    core_metric_spec_quantile_loss(),
    core_metric_spec_trimmed_rmse(),
    core_metric_spec_winsor_rmse(),
    core_metric_spec_ks_statistic(),
    core_metric_spec_cdf_rmse(),
    core_metric_spec_quantile_deviation(),
    core_metric_spec_fdc_shape_distance(),
    core_metric_spec_anderson_darling_stat(),
    core_metric_spec_wasserstein_distance(),
    core_metric_spec_sqrt_nse(),
    core_metric_spec_weighted_kge(),
    core_metric_spec_quantile_kge(),
    core_metric_spec_derivative_nse(),
    core_metric_spec_peak_timing_error(),
    core_metric_spec_rising_limb_error(),
    core_metric_spec_recession_constant(),
    core_metric_spec_baseflow_index_error(),
    core_metric_spec_event_nse(),
    core_metric_spec_skewness_error(),
    core_metric_spec_kurtosis_error(),
    core_metric_spec_entropy_diff(),
    core_metric_spec_mutual_information_score(),
    core_metric_spec_mutual_information(),
    core_metric_spec_normalised_mi(),
    core_metric_spec_flow_duration_entropy(),
    core_metric_spec_tail_dependence_score(),
    core_metric_spec_extreme_event_ratio(),
    core_metric_spec_rank_turnover_score(),
    core_metric_spec_distribution_overlap(),
    core_metric_spec_quantile_shift_index(),
    core_metric_spec_extended_valindex(),
    core_metric_spec_rbias(),
    core_metric_spec_beta(),
    core_metric_spec_alpha(),
    core_metric_spec_r(),
    core_metric_spec_ccc(),
    core_metric_spec_r2(),
    core_metric_spec_kge(),
    core_metric_spec_e1(),
    core_metric_spec_rsr(),
    core_metric_spec_mape(),
    core_metric_spec_mpe(),
    core_metric_spec_ve(),
    core_metric_spec_nrmse_sd(),
    core_metric_spec_me(),
    core_metric_spec_d(),
    core_metric_spec_md(),
    core_metric_spec_rd(),
    core_metric_spec_dr(),
    core_metric_spec_br2(),
    core_metric_spec_rnse(),
    core_metric_spec_log_nse(),
    core_metric_spec_mnse(),
    core_metric_spec_wnse(),
    core_metric_spec_wsnse(),
    core_metric_spec_ubrmse(),
    core_metric_spec_ssq(),
    core_metric_spec_kgekm(),
    core_metric_spec_kgelf(),
    core_metric_spec_kgenp(),
    core_metric_spec_skge(),
    core_metric_spec_hfb(),
    core_metric_spec_rspearman(),
    core_metric_spec_rsd()
  )

  for (spec in specs) {
    if (!registry$exists(spec$id)) {
      registry$register(spec)
    }
  }

  invisible(TRUE)
}

.get_registry <- function() {
  if (!exists("registry", envir = .hm_state, inherits = FALSE)) {
    registry <- MetricRegistry$new()
    assign("registry", registry, envir = .hm_state)
  }

  registry <- get("registry", envir = .hm_state, inherits = FALSE)
  register_core_metrics(registry)
  registry
}

.get_engine <- function() {
  if (!exists("engine", envir = .hm_state, inherits = FALSE)) {
    engine <- HydroEngine$new(registry = .get_registry())
    assign("engine", engine, envir = .hm_state)
  }
  get("engine", envir = .hm_state, inherits = FALSE)
}

register_metric <- function(id, fun, name, description, references = NULL, tags = NULL) {
  if (is.null(references)) {
    references <- "User-defined metric registered at runtime; no external reference supplied."
  }
  if (is.null(tags)) {
    tags <- character()
  }

  spec <- list(
    id = id,
    fun = fun,
    name = name,
    description = description,
    category = "other",
    perfect = 0,
    range = NULL,
    references = paste(as.character(references), collapse = "; "),
    version_added = "0.1.0",
    tags = as.character(tags)
  )

  .get_registry()$register(spec)
}

.hm_recommended_metric_ids <- function() {
  # Stable curated shortlist aligned to the existing compat-10 defaults.
  c("nse", "kge", "rmse", "pbias", "mae", "mse", "r2", "ve", "rsr", "nrmse")
}

list_metrics <- function(recommended = FALSE) {
  if (!is.logical(recommended) || length(recommended) != 1L || is.na(recommended)) {
    stop("`recommended` must be TRUE or FALSE.", call. = FALSE)
  }

  metrics <- .get_registry()$list()
  if (!isTRUE(recommended)) {
    return(metrics)
  }

  metrics[metrics$id %in% .hm_recommended_metric_ids(), , drop = FALSE]
}

get_metric <- function(id) {
  .get_registry()$get(id)
}
