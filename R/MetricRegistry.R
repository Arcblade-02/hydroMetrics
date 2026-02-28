MetricRegistry <- R6::R6Class(
  "MetricRegistry",
  private = list(
    store = NULL
  ),
  public = list(
    initialize = function() {
      private$store <- new.env(parent = emptyenv())
    },

    validate_spec = function(spec) {
      required_fields <- c(
        "id", "fun", "name", "description", "category",
        "perfect", "range", "references", "version_added"
      )

      if (!is.list(spec)) {
        stop("`spec` must be a list.", call. = FALSE)
      }

      missing_fields <- setdiff(required_fields, names(spec))
      if (length(missing_fields) > 0L) {
        stop(
          sprintf("Missing required field(s): %s", paste(missing_fields, collapse = ", ")),
          call. = FALSE
        )
      }

      if (!is.character(spec$id) || length(spec$id) != 1L || !nzchar(spec$id)) {
        stop("`spec$id` must be a non-empty character scalar.", call. = FALSE)
      }
      if (!is.function(spec$fun)) {
        stop("`spec$fun` must be a function.", call. = FALSE)
      }
      if (!is.character(spec$name) || length(spec$name) != 1L || !nzchar(spec$name)) {
        stop("`spec$name` must be a non-empty character scalar.", call. = FALSE)
      }
      if (!is.character(spec$description) || length(spec$description) != 1L || !nzchar(spec$description)) {
        stop("`spec$description` must be a non-empty character scalar.", call. = FALSE)
      }
      if (!is.character(spec$category) || length(spec$category) != 1L || !nzchar(spec$category)) {
        stop("`spec$category` must be a non-empty character scalar.", call. = FALSE)
      }
      if (!is.numeric(spec$perfect) || length(spec$perfect) != 1L || is.na(spec$perfect)) {
        stop("`spec$perfect` must be a non-missing numeric scalar.", call. = FALSE)
      }
      if (!is.null(spec$range)) {
        if (!is.numeric(spec$range) || length(spec$range) != 2L || any(is.na(spec$range))) {
          stop("`spec$range` must be NULL or a numeric vector of length 2.", call. = FALSE)
        }
      }
      if (!is.character(spec$references)) {
        stop("`spec$references` must be a character vector.", call. = FALSE)
      }
      if (!is.character(spec$version_added) || length(spec$version_added) != 1L || !nzchar(spec$version_added)) {
        stop("`spec$version_added` must be a non-empty character scalar.", call. = FALSE)
      }

      invisible(TRUE)
    },

    register = function(spec) {
      self$validate_spec(spec)
      if (self$exists(spec$id)) {
        stop(sprintf("Metric id '%s' is already registered.", spec$id), call. = FALSE)
      }
      assign(spec$id, spec, envir = private$store)
      invisible(spec$id)
    },

    get = function(id) {
      if (!is.character(id) || length(id) != 1L || !nzchar(id)) {
        stop("`id` must be a non-empty character scalar.", call. = FALSE)
      }
      if (!self$exists(id)) {
        stop(sprintf("Unknown metric id '%s'.", id), call. = FALSE)
      }
      get(id, envir = private$store, inherits = FALSE)
    },

    list = function() {
      ids <- sort(ls(envir = private$store, all.names = FALSE))
      if (length(ids) == 0L) {
        return(data.frame(
          id = character(0),
          name = character(0),
          description = character(0),
          category = character(0),
          perfect = numeric(0),
          range = character(0),
          references = character(0),
          version_added = character(0),
          stringsAsFactors = FALSE
        ))
      }

      specs <- lapply(ids, function(id) get(id, envir = private$store, inherits = FALSE))

      data.frame(
        id = vapply(specs, `[[`, character(1), "id"),
        name = vapply(specs, `[[`, character(1), "name"),
        description = vapply(specs, `[[`, character(1), "description"),
        category = vapply(specs, `[[`, character(1), "category"),
        perfect = vapply(specs, `[[`, numeric(1), "perfect"),
        range = vapply(specs, function(x) {
          if (is.null(x$range)) "" else paste(x$range, collapse = ",")
        }, character(1)),
        references = vapply(specs, function(x) paste(x$references, collapse = "; "), character(1)),
        version_added = vapply(specs, `[[`, character(1), "version_added"),
        stringsAsFactors = FALSE
      )
    },

    exists = function(id) {
      if (!is.character(id) || length(id) != 1L || !nzchar(id)) {
        stop("`id` must be a non-empty character scalar.", call. = FALSE)
      }
      exists(id, envir = private$store, inherits = FALSE)
    }
  )
)
