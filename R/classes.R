#' Create an `hm_result` object
#'
#' @param x A data frame of metric results.
#'
#' @return An object with class `hm_result`.
#' @export
hm_result <- function(x) {
  if (!is.data.frame(x)) {
    stop("`x` must be a data.frame.", call. = FALSE)
  }
  structure(x, class = c("hm_result", "data.frame"))
}

#' Print an `hm_result`
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
#' @param x An `hm_result` object.
#' @param ... Unused.
#'
#' @return A plain data frame.
#' @export
as.data.frame.hm_result <- function(x, ...) {
  class(x) <- "data.frame"
  x
}
