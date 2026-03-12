#' Return a tabular compatibility summary
#'
#' `ggof()` is a non-plotting compatibility helper. It returns a tidy
#' `data.frame` with class `"hydro_metrics_batch"` and does not open or mutate
#' graphics devices.
#'
#' @inheritParams gof
#' @param include_meta Whether to append orchestration metadata columns.
#'
#' @return A `data.frame` with class `c("hydro_metrics_batch", "data.frame")`
#'   containing `model`, `metric`, `value`, and `n_obs` columns.
#'
#' @examples
#' sim <- c(1, 2, 3, 4)
#' obs <- c(1, 2, 2, 4)
#'
#' ggof(sim, obs, methods = c("NSE", "rmse"))
#' @export
ggof <- function(sim,
                 obs,
                 methods = NULL,
                 extended = FALSE,
                 na_strategy = c("fail", "remove", "pairwise"),
                 transform = c("none", "log", "sqrt", "reciprocal"),
                 epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                 epsilon = NULL,
                 epsilon_factor = 1,
                 include_meta = FALSE,
                 fun = NULL,
                 na.rm = NULL,
                 keep = NULL,
                 epsilon.type = NULL,
                 epsilon.value = NULL,
                 ...) {
  out <- gof(
    sim = sim,
    obs = obs,
    methods = methods,
    extended = extended,
    na_strategy = na_strategy,
    transform = transform,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor,
    fun = fun,
    na.rm = na.rm,
    keep = keep,
    epsilon.type = epsilon.type,
    epsilon.value = epsilon.value,
    ...
  )

  metrics <- out
  n_obs <- attr(out, "n_obs", exact = TRUE)
  meta <- attr(out, "meta", exact = TRUE)

  if (is.matrix(metrics)) {
    model_names <- colnames(metrics)
    if (is.null(model_names)) {
      model_names <- paste0("model", seq_len(ncol(metrics)))
    }

    if (length(n_obs) == 1L) {
      n_obs <- rep(as.integer(n_obs), length(model_names))
      names(n_obs) <- model_names
    }

    res <- data.frame(
      model = rep(model_names, each = nrow(metrics)),
      metric = rep(rownames(metrics), times = ncol(metrics)),
      value = as.numeric(metrics),
      n_obs = rep(as.integer(n_obs[model_names]), each = nrow(metrics)),
      stringsAsFactors = FALSE
    )
  } else {
    model_name <- "model1"
    res <- data.frame(
      model = rep(model_name, length(metrics)),
      metric = names(metrics),
      value = as.numeric(metrics),
      n_obs = rep(as.integer(n_obs), length(metrics)),
      stringsAsFactors = FALSE
    )
  }

  if (isTRUE(include_meta)) {
    res$transform <- meta$transform
    res$na_strategy <- meta$na_strategy
    res$epsilon_mode <- meta$epsilon_mode
  }

  class(res) <- c("hydro_metrics_batch", "data.frame")
  res
}

#' Print a hydro_metrics_batch result
#'
#' @param x A `"hydro_metrics_batch"` object returned by [ggof()].
#' @param ... Additional arguments passed to [print.data.frame()].
#'
#' @return The input object, invisibly.
#' @rdname hydro-orchestration-methods
#' @export
print.hydro_metrics_batch <- function(x, ...) {
  print.data.frame(x, ...)
  invisible(x)
}
