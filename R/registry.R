.hm_state <- new.env(parent = emptyenv())

.register_default_metrics <- function(registry) {
  if (!registry$exists("mse")) {
    registry$register(list(
      id = "mse",
      fun = function(sim, obs) mean((sim - obs)^2),
      name = "Mean Squared Error",
      description = "Textbook mean squared error placeholder metric for architecture testing.",
      category = "error",
      perfect = 0,
      range = c(0, Inf),
      references = "TODO: add canonical MSE reference",
      version_added = "0.1.0"
    ))
  }
  invisible(TRUE)
}

.get_registry <- function() {
  if (!exists("registry", envir = .hm_state, inherits = FALSE)) {
    registry <- MetricRegistry$new()
    .register_default_metrics(registry)
    assign("registry", registry, envir = .hm_state)
  }
  get("registry", envir = .hm_state, inherits = FALSE)
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
    references <- "TODO: add reference"
  }

  spec <- list(
    id = id,
    fun = fun,
    name = name,
    description = description,
    category = if (is.null(tags) || length(tags) == 0L) "general" else as.character(tags[[1]]),
    perfect = 0,
    range = NULL,
    references = as.character(references),
    version_added = "0.1.0"
  )

  .get_registry()$register(spec)
}

list_metrics <- function() {
  .get_registry()$list()
}

get_metric <- function(id) {
  .get_registry()$get(id)
}
