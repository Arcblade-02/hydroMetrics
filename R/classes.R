#' Create an `hm_result` object
#'
#' Stable low-level utility constructor for `hm_result` S3 objects. This is
#' primarily used by the metric engine, but it remains part of the documented
#' exported API for callers that need to build or validate `hm_result` payloads
#' explicitly.
#' Stable condition contract: `hm_result()` errors when `x` is not a
#' `data.frame` and otherwise returns the payload unchanged apart from the
#' `hm_result` S3 class decoration.
#'
#' @param x A data frame of metric results.
#'
#' @return A base `data.frame` with class `c("hm_result", "data.frame")`.
#' @export
hm_result <- function(x) {
  if (!is.data.frame(x)) {
    stop("`x` must be a data.frame.", call. = FALSE)
  }
  structure(x, class = c("hm_result", "data.frame"))
}

#' Print an `hm_result`
#'
#' Stable S3 print method for objects created by [hm_result()].
#'
#' @param x An `hm_result` object.
#' @param ... Additional arguments passed to [print()].
#'
#' @return The input object, invisibly.
#' @export
print.hm_result <- function(x, ...) {
  n_metrics <- nrow(x)
  cat(sprintf("<hm_result: %d metric(s)>\n", n_metrics))
  print(utils::head(as.data.frame.hm_result(x)), ...)
  invisible(x)
}

#' Convert an `hm_result` to data frame
#'
#' Stable S3 coercion method for objects created by [hm_result()].
#'
#' @param x An `hm_result` object.
#' @param ... Unused.
#'
#' @return A plain data frame.
#' @export
as.data.frame.hm_result <- function(x, ...) {
  class(x) <- "data.frame"
  x
}
