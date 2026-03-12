metric_mdae <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("mdae requires at least 1 value.", call. = FALSE)
  }

  stats::median(abs(sim - obs))
}

core_metric_spec_mdae <- function() {
  list(
    id = "mdae",
    fun = metric_mdae,
    name = "Median Absolute Error",
    description = "Median absolute deviation between sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "NIST/SEMATECH e-Handbook of Statistical Methods; robust absolute-error summary.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_maxae <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("maxae requires at least 1 value.", call. = FALSE)
  }

  max(abs(sim - obs))
}

core_metric_spec_maxae <- function() {
  list(
    id = "maxae",
    fun = metric_maxae,
    name = "Maximum Absolute Error",
    description = "Maximum absolute deviation between sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "NIST/SEMATECH e-Handbook of Statistical Methods; absolute-error summary statistics.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_rbias <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rbias is undefined because obs contains zero.", call. = FALSE)
  }

  mean((sim - obs) / obs)
}

core_metric_spec_rbias <- function() {
  list(
    id = "rbias",
    fun = metric_rbias,
    name = "Relative Bias",
    description = "Mean paired relative bias computed as mean((sim - obs) / obs).",
    category = "bias",
    perfect = 0,
    range = c(-Inf, Inf),
    references = "Relative-error model-evaluation family described by Hwang et al. (2012).",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_ccc <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("ccc requires at least 2 values.", call. = FALSE)
  }

  var_sim <- stats::var(sim)
  var_obs <- stats::var(obs)
  mean_diff_sq <- (mean(sim) - mean(obs))^2
  denom <- var_sim + var_obs + mean_diff_sq

  if (denom == 0) {
    return(1)
  }

  (2 * stats::cov(sim, obs)) / denom
}

core_metric_spec_ccc <- function() {
  list(
    id = "ccc",
    fun = metric_ccc,
    name = "Concordance Correlation Coefficient",
    description = "Lin's concordance correlation coefficient for agreement between sim and obs.",
    category = "agreement",
    perfect = 1,
    range = c(-1, 1),
    references = "Lin, L.I.-K. (1989). A concordance correlation coefficient to evaluate reproducibility.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_e1 <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("e1 requires at least 1 value.", call. = FALSE)
  }

  denom <- sum(abs(obs - mean(obs)))
  if (denom == 0) {
    stop("e1 is undefined because sum(abs(obs - mean(obs))) == 0.", call. = FALSE)
  }

  1 - sum(abs(sim - obs)) / denom
}

core_metric_spec_e1 <- function() {
  list(
    id = "e1",
    fun = metric_e1,
    name = "Modified Coefficient of Efficiency",
    description = "Legates-McCabe absolute-error efficiency statistic.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Legates, D.R. & McCabe, G.J. (1999). Evaluating the use of goodness-of-fit measures in hydrologic and hydroclimatic model validation.",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}

metric_rrmse <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rrmse is undefined because obs contains zero.", call. = FALSE)
  }

  sqrt(mean(((sim - obs) / obs)^2))
}

core_metric_spec_rrmse <- function() {
  list(
    id = "rrmse",
    fun = metric_rrmse,
    name = "Relative Root Mean Squared Error",
    description = "Root mean squared paired relative error computed as sqrt(mean(((sim - obs) / obs)^2)).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Relative-error model-evaluation family described by Hwang et al. (2012).",
    version_added = "0.2.0",
    tags = c("phase-3", "layer-a", "batch-a1")
  )
}
