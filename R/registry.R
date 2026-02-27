.metric_registry <- new.env(parent = emptyenv())

register_metric <- function(id, fun, name, description, references = NULL, tags = NULL) {
  if (!is.character(id) || length(id) != 1L || !nzchar(id)) {
    stop("`id` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!is.function(fun)) {
    stop("`fun` must be a function.", call. = FALSE)
  }
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    stop("`name` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!is.character(description) || length(description) != 1L || !nzchar(description)) {
    stop("`description` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!is.null(references) && !is.character(references)) {
    stop("`references` must be NULL or a character vector.", call. = FALSE)
  }
  if (!is.null(tags) && !is.character(tags)) {
    stop("`tags` must be NULL or a character vector.", call. = FALSE)
  }
  if (exists(id, envir = .metric_registry, inherits = FALSE)) {
    stop(sprintf("Metric id '%s' is already registered.", id), call. = FALSE)
  }

  metric_def <- list(
    id = id,
    fun = fun,
    name = name,
    description = description,
    references = references,
    tags = tags
  )
  assign(id, metric_def, envir = .metric_registry)
  invisible(id)
}

list_metrics <- function() {
  ids <- sort(ls(envir = .metric_registry, all.names = FALSE))
  if (length(ids) == 0L) {
    return(data.frame(
      id = character(0),
      name = character(0),
      description = character(0),
      references = character(0),
      tags = character(0),
      stringsAsFactors = FALSE
    ))
  }

  defs <- lapply(ids, function(id) get(id, envir = .metric_registry, inherits = FALSE))
  data.frame(
    id = vapply(defs, `[[`, character(1), "id"),
    name = vapply(defs, `[[`, character(1), "name"),
    description = vapply(defs, `[[`, character(1), "description"),
    references = vapply(defs, function(x) paste(x$references %||% character(0), collapse = "; "), character(1)),
    tags = vapply(defs, function(x) paste(x$tags %||% character(0), collapse = "; "), character(1)),
    stringsAsFactors = FALSE
  )
}

get_metric <- function(id) {
  if (!is.character(id) || length(id) != 1L || !nzchar(id)) {
    stop("`id` must be a non-empty character scalar.", call. = FALSE)
  }
  if (!exists(id, envir = .metric_registry, inherits = FALSE)) {
    stop(sprintf("Unknown metric id '%s'.", id), call. = FALSE)
  }
  get(id, envir = .metric_registry, inherits = FALSE)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

.onLoad <- function(libname, pkgname) {
  if (!exists("mse", envir = .metric_registry, inherits = FALSE)) {
    register_metric(
      id = "mse",
      fun = function(sim, obs) mean((sim - obs)^2),
      name = "Mean Squared Error",
      description = "Textbook mean squared error placeholder metric for Phase-1 engine testing.",
      references = "TODO: add canonical MSE reference",
      tags = c("error", "placeholder")
    )
  }
}
