.hm_fdc_plot_data <- function(values, label) {
  n <- length(values)
  exceedance <- 100 * seq_len(n) / (n + 1)

  data.frame(
    exceedance = exceedance,
    value = sort(values, decreasing = TRUE),
    series = label,
    stringsAsFactors = FALSE
  )
}

#' Plot an observed vs simulated flow duration curve
#'
#' `plot_fdc()` is a lightweight static plotting helper for comparing observed
#' and simulated flow duration curves. It reuses [preproc()] for supported
#' single-series alignment and missing-value handling, then constructs a simple
#' empirical exceedance-probability plot from the aligned values.
#'
#' Exceedance probability is computed deterministically as
#' `100 * i / (n + 1)` on the descending sorted aligned values of each series.
#' The helper returns a `ggplot2` object when `ggplot2` is available through
#' `Suggests`, and it errors clearly when that optional dependency is
#' unavailable.
#'
#' If `log_scale = TRUE`, all aligned values must be strictly positive. The
#' helper errors otherwise rather than silently dropping or shifting values.
#'
#' @param sim Simulated values as a supported single-series input accepted by
#'   [preproc()].
#' @param obs Observed values with the same shape contract as `sim`.
#' @param na_strategy Missing-value strategy forwarded to [preproc()].
#' @param sim_label Legend label used for the simulated FDC.
#' @param obs_label Legend label used for the observed FDC.
#' @param title Optional plot title.
#' @param x_lab X-axis label. Defaults to `"Exceedance probability (%)"`.
#' @param y_lab Y-axis label. Defaults to `"Flow"`.
#' @param log_scale Logical; if `TRUE`, use a log-scaled y-axis.
#'
#' @return A `ggplot` object.
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   sim <- c(1.1, 1.9, 3.2, 4.1)
#'   obs <- c(1.0, 2.0, 3.0, 4.0)
#'
#'   plot_fdc(sim, obs)
#'   plot_fdc(sim, obs, log_scale = TRUE)
#' }
#' @export
plot_fdc <- function(sim,
                     obs,
                     na_strategy = c("fail", "remove", "pairwise"),
                     sim_label = "Simulated",
                     obs_label = "Observed",
                     title = NULL,
                     x_lab = "Exceedance probability (%)",
                     y_lab = "Flow",
                     log_scale = FALSE) {
  .hm_plot_require_ggplot2("plot_fdc")

  sim_label <- .hm_validate_plot_label(sim_label, "sim_label")
  obs_label <- .hm_validate_plot_label(obs_label, "obs_label")
  title <- .hm_validate_plot_label(title, "title", allow_null = TRUE)
  x_lab <- .hm_validate_plot_label(x_lab, "x_lab")
  y_lab <- .hm_validate_plot_label(y_lab, "y_lab")

  if (!is.logical(log_scale) || length(log_scale) != 1L || is.na(log_scale)) {
    stop("`log_scale` must be a single TRUE or FALSE value.", call. = FALSE)
  }

  prep <- preproc(sim = sim, obs = obs, na_strategy = na_strategy)

  if (isTRUE(log_scale) && (any(prep$sim <= 0) || any(prep$obs <= 0))) {
    stop("plot_fdc(log_scale = TRUE) requires strictly positive aligned values.", call. = FALSE)
  }

  plot_data <- rbind(
    .hm_fdc_plot_data(prep$obs, obs_label),
    .hm_fdc_plot_data(prep$sim, sim_label)
  )
  conventions <- .hm_plot_series_conventions(obs_label, sim_label)
  plot_data <- .hm_plot_apply_series_conventions(plot_data, conventions)
  exceedance <- NULL

  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = exceedance, y = value, color = series)
  ) +
    ggplot2::geom_line(linewidth = 0.6, na.rm = TRUE) +
    .hm_plot_common_layers(
      title = title,
      x_lab = x_lab,
      y_lab = y_lab,
      conventions = conventions
    )

  if (isTRUE(log_scale)) {
    p <- p + ggplot2::scale_y_log10()
  }

  p
}
