hm_result <- function(x) {
  if (!is.data.frame(x)) {
    stop("`x` must be a data.frame.", call. = FALSE)
  }
  structure(x, class = c("hm_result", "data.frame"))
}

print.hm_result <- function(x, ...) {
  n_metrics <- nrow(x)
  cat(sprintf("<hm_result: %d metric(s)>\n", n_metrics))
  print(utils::head(as.data.frame.hm_result(x)), ...)
  invisible(x)
}

as.data.frame.hm_result <- function(x, ...) {
  class(x) <- "data.frame"
  x
}
