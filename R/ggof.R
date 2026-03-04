ggof <- function(sim,
                 obs,
                 methods = NULL,
                 na_strategy = c("fail", "remove", "pairwise"),
                 transform = c("none", "log", "sqrt", "reciprocal"),
                 epsilon_mode = c("constant", "auto_min_positive", "obs_mean_factor"),
                 epsilon = NULL,
                 epsilon_factor = 1,
                 include_meta = FALSE,
                 ...) {
  out <- gof(
    sim = sim,
    obs = obs,
    methods = methods,
    na_strategy = na_strategy,
    transform = transform,
    epsilon_mode = epsilon_mode,
    epsilon = epsilon,
    epsilon_factor = epsilon_factor,
    ...
  )

  metrics <- out$metrics
  if (is.matrix(metrics)) {
    model_names <- colnames(metrics)
    if (is.null(model_names)) {
      model_names <- paste0("model", seq_len(ncol(metrics)))
    }

    n_obs <- out$n_obs
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
      n_obs = rep(as.integer(out$n_obs), length(metrics)),
      stringsAsFactors = FALSE
    )
  }

  if (isTRUE(include_meta)) {
    res$transform <- out$meta$transform
    res$na_strategy <- out$meta$na_strategy
    res$epsilon_mode <- out$meta$epsilon_mode
  }

  class(res) <- c("hydro_metrics_batch", "data.frame")
  res
}

print.hydro_metrics_batch <- function(x, ...) {
  print.data.frame(x, ...)
  invisible(x)
}
