.hm_state <- new.env(parent = emptyenv())

register_core_metrics <- function(registry) {
  if (!inherits(registry, "MetricRegistry")) {
    stop("`registry` must be a MetricRegistry instance.", call. = FALSE)
  }

  specs <- list(
    core_metric_spec_nse(),
    core_metric_spec_rmse(),
    core_metric_spec_pbias(),
    core_metric_spec_mae(),
    core_metric_spec_mse(),
    core_metric_spec_nrmse(),
    core_metric_spec_r(),
    core_metric_spec_r2(),
    core_metric_spec_kge(),
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
    core_metric_spec_mnse(),
    core_metric_spec_wnse(),
    core_metric_spec_wsnse(),
    core_metric_spec_ubrmse(),
    core_metric_spec_ssq(),
    core_metric_spec_kgekm(),
    core_metric_spec_kgelf(),
    core_metric_spec_kgenp(),
    core_metric_spec_skge(),
    core_metric_spec_pbiasfdc()
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
