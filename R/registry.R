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
    core_metric_spec_seasonal_bias(),
    core_metric_spec_huber_loss(),
    core_metric_spec_quantile_loss(),
    core_metric_spec_trimmed_rmse(),
    core_metric_spec_winsor_rmse(),
    core_metric_spec_crps(),
    core_metric_spec_picp(),
    core_metric_spec_mwpi(),
    core_metric_spec_skill_score(),
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
    core_metric_spec_pbiasfdc(),
    core_metric_spec_apfb(),
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
    references <- "User-defined metric (reference not provided)."
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

list_metrics <- function() {
  .get_registry()$list()
}

get_metric <- function(id) {
  .get_registry()$get(id)
}
