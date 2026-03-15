.hm_validate_plot_label <- function(x, name, allow_null = FALSE) {
  if (is.null(x) && isTRUE(allow_null)) {
    return(NULL)
  }

  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop(sprintf("`%s` must be %scharacter scalar.", name, if (isTRUE(allow_null)) "NULL or a non-empty " else "a non-empty "), call. = FALSE)
  }

  x
}

.hm_plot_require_ggplot2 <- function(helper_name = "plot_hydrograph") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      sprintf("%s() requires the 'ggplot2' package. Install it to use plotting helpers.", helper_name),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Plot an observed vs simulated hydrograph comparison
#'
#' `plot_hydrograph()` is the first lightweight static plotting helper for the
#' package. It keeps plotting separate from [ggof()] and reuses [preproc()] for
#' supported single-series alignment and NA handling before constructing a
#' simple observed-vs-simulated line plot.
#'
#' The helper is intentionally modest for Phase 4: it returns a `ggplot2`
#' object when `ggplot2` is available through `Suggests`, and it errors
#' clearly when that optional dependency is unavailable.
#'
#' @param sim Simulated values as a supported single-series input accepted by
#'   [preproc()].
#' @param obs Observed values with the same shape contract as `sim`.
#' @param na_strategy Missing-value strategy forwarded to [preproc()].
#' @param sim_label Legend label used for the simulated series.
#' @param obs_label Legend label used for the observed series.
#' @param title Optional plot title.
#' @param x_lab Optional x-axis label. Defaults to `"Index"`.
#' @param y_lab Y-axis label. Defaults to `"Value"`.
#'
#' @return A `ggplot` object.
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   sim <- c(1.1, 1.9, 3.2, 4.1)
#'   obs <- c(1.0, 2.0, 3.0, 4.0)
#'
#'   plot_hydrograph(sim, obs)
#' }
#' @export
plot_hydrograph <- function(sim,
                            obs,
                            na_strategy = c("fail", "remove", "pairwise"),
                            sim_label = "Simulated",
                            obs_label = "Observed",
                            title = NULL,
                            x_lab = "Index",
                            y_lab = "Value") {
  .hm_plot_require_ggplot2("plot_hydrograph")

  sim_label <- .hm_validate_plot_label(sim_label, "sim_label")
  obs_label <- .hm_validate_plot_label(obs_label, "obs_label")
  title <- .hm_validate_plot_label(title, "title", allow_null = TRUE)
  x_lab <- .hm_validate_plot_label(x_lab, "x_lab")
  y_lab <- .hm_validate_plot_label(y_lab, "y_lab")

  prep <- preproc(sim = sim, obs = obs, na_strategy = na_strategy)

  x <- prep$index
  if (is.null(x)) {
    x <- seq_along(prep$sim)
  }

  plot_data <- rbind(
    data.frame(x = x, series = obs_label, value = prep$obs, stringsAsFactors = FALSE),
    data.frame(x = x, series = sim_label, value = prep$sim, stringsAsFactors = FALSE)
  )
  plot_data$series <- factor(plot_data$series, levels = c(obs_label, sim_label))

  palette <- c("#1f78b4", "#d95f02")
  names(palette) <- c(obs_label, sim_label)

  ggplot2::ggplot(plot_data, ggplot2::aes(x = x, y = value, color = series)) +
    ggplot2::geom_line(linewidth = 0.6, na.rm = TRUE) +
    ggplot2::scale_color_manual(values = palette) +
    ggplot2::labs(title = title, x = x_lab, y = y_lab, color = NULL) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(legend.position = "top")
}
