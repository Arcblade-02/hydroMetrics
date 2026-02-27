as_hydrometrics_result <- function(x, metadata = list()) {
  if (!is.data.frame(x)) {
    stop("`x` must be a data.frame.", call. = FALSE)
  }
  if (!is.list(metadata)) {
    stop("`metadata` must be a list.", call. = FALSE)
  }
  structure(x, metadata = metadata, class = c("hydrometrics_result", class(x)))
}

print.hydrometrics_result <- function(x, ...) {
  cat("<hydrometrics_result>\n")
  NextMethod("print")
  invisible(x)
}
