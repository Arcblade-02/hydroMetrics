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
