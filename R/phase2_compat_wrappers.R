.phase2_metric_wrapper <- function(metric_id, sim, obs, na.rm = NULL, ...) {
  out <- gof(sim = sim, obs = obs, methods = metric_id, na.rm = na.rm, ...)
  metrics <- out$metrics

  if (is.matrix(metrics)) {
    return(as.numeric(metrics[1, , drop = TRUE]))
  }

  as.numeric(metrics[[1]])
}

#' Evaluate the legacy NSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"nse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' NSE(c(1, 2, 3), c(1, 2, 2))
#' @export
NSE <- function(sim, obs, na.rm = NULL, ...) {
  .phase2_metric_wrapper("nse", sim = sim, obs = obs, na.rm = na.rm, ...)
}

#' Evaluate the legacy KGE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"kge"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' KGE(c(1, 2, 3), c(1, 2, 2))
#' @export
KGE <- function(sim, obs, na.rm = NULL, ...) {
  .phase2_metric_wrapper("kge", sim = sim, obs = obs, na.rm = na.rm, ...)
}

#' Evaluate the legacy MAE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"mae"`.
#'
#' @name MAE
#' @rdname MAE-wrapper
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' MAE(c(1, 2, 3), c(1, 3, 2))
#' @export
MAE <- function(sim, obs, na.rm = NULL, ...) {
  .phase2_metric_wrapper("mae", sim = sim, obs = obs, na.rm = na.rm, ...)
}

#' Evaluate the legacy RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"rmse"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' RMSE(c(1, 2, 3), c(1, 2, 2))
#' @export
RMSE <- function(sim, obs, na.rm = NULL, ...) {
  .phase2_metric_wrapper("rmse", sim = sim, obs = obs, na.rm = na.rm, ...)
}

#' Evaluate the legacy percent bias wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"pbias"`.
#'
#' @name PBIAS
#' @rdname PBIAS-wrapper
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' PBIAS(c(1, 2, 3), c(1, 2, 4))
#' @export
PBIAS <- function(sim, obs, na.rm = NULL, ...) {
  .phase2_metric_wrapper("pbias", sim = sim, obs = obs, na.rm = na.rm, ...)
}

#' Evaluate the legacy R-squared wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"r2"`.
#'
#' @inheritParams gof
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' R2(c(1, 2, 3), c(1, 2, 2))
#' @export
R2 <- function(sim, obs, na.rm = NULL, ...) {
  .phase2_metric_wrapper("r2", sim = sim, obs = obs, na.rm = na.rm, ...)
}

#' Evaluate the legacy normalized RMSE wrapper
#'
#' Thin exported wrapper over [gof()] for the registry metric `"nrmse"`.
#' Phase 2 freezes the public `norm` contract at `norm = "mean"` to represent
#' CV-RMSE style normalization by `mean(obs)`.
#'
#' @inheritParams gof
#' @param norm Normalization method. Phase 2 supports `"mean"` only.
#'
#' @return A numeric scalar for single-series inputs or a numeric vector for
#'   multi-series inputs.
#'
#' @examples
#' NRMSE(c(1, 2, 3), c(1, 2, 2), norm = "mean")
#' @export
NRMSE <- function(sim, obs, norm = c("mean"), na.rm = NULL, ...) {
  if (!is.character(norm) || length(norm) != 1L || is.na(norm) || !nzchar(norm)) {
    stop("`norm` must be a non-empty character scalar.", call. = FALSE)
  }

  if (!identical(norm, "mean")) {
    stop("Phase 2 supports `NRMSE(norm = 'mean')` only.", call. = FALSE)
  }

  .phase2_metric_wrapper("nrmse", sim = sim, obs = obs, na.rm = na.rm, ...)
}
