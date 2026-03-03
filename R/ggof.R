#' Plot Hydrological Goodness-of-Fit Metrics
#'
#' Computes goodness-of-fit metrics and returns a `ggplot2` visualization.
#'
#' @param sim Numeric simulated values; a vector for a single series or a matrix/data.frame/ts/zoo for multiple series.
#' @param obs Numeric observed values with the same shape as `sim`.
#' @param methods Metric name(s) to evaluate.
#' @param fun Optional metric name(s), kept for hydroGOF compatibility.
#' @param ... Additional arguments passed through to [gof()].
#'
#' @details Argument order is `sim, obs` (simulation first, observation second).
#'
#' @return A `ggplot2::ggplot` object visualizing selected metric values.
#' @export
ggof <- function(sim, obs, methods = NULL, fun = NULL, ...) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 is required for ggof(); install it or use gof().", call. = FALSE)
  }

  values <- gof(sim = sim, obs = obs, methods = methods, fun = fun, ...)

  if (is.numeric(values) && !is.matrix(values)) {
    plot_df <- data.frame(
      metric = names(values),
      value = as.numeric(values),
      series = "series1",
      stringsAsFactors = FALSE
    )

    return(
      ggplot2::ggplot(plot_df, ggplot2::aes(x = metric, y = value)) +
        ggplot2::geom_col(fill = "#2C7FB8") +
        ggplot2::labs(x = "Metric", y = "Value")
    )
  }

  plot_df <- data.frame(
    metric = rep(rownames(values), times = ncol(values)),
    value = as.numeric(values),
    series = rep(colnames(values), each = nrow(values)),
    stringsAsFactors = FALSE
  )

  ggplot2::ggplot(plot_df, ggplot2::aes(x = metric, y = value, fill = series)) +
    ggplot2::geom_col(position = "dodge") +
    ggplot2::labs(x = "Metric", y = "Value", fill = "Series")
}
