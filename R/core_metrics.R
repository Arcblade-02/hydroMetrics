metric_nse <- function(sim, obs) {
  1 - (sum((sim - obs)^2) / sum((obs - mean(obs))^2))
}

core_metric_spec_nse <- function() {
  list(
    id = "nse",
    fun = metric_nse,
    name = "Nash-Sutcliffe Efficiency",
    description = "NSE computed as 1 - SSE/SST using observed values as baseline.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles.",
    version_added = "0.1.0",
    tags = c("core", "phase-2")
  )
}

metric_rmse <- function(sim, obs) {
  sqrt(mean((sim - obs)^2))
}

core_metric_spec_rmse <- function() {
  list(
    id = "rmse",
    fun = metric_rmse,
    name = "Root Mean Squared Error",
    description = "RMSE computed as the square root of mean squared error.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard RMSE definition in statistical error analysis texts.",
    version_added = "0.1.0",
    tags = c("core", "phase-2")
  )
}

metric_pbias <- function(sim, obs) {
  100 * sum(sim - obs) / sum(obs)
}

core_metric_spec_pbias <- function() {
  list(
    id = "pbias",
    fun = metric_pbias,
    name = "Percent Bias",
    description = "PBIAS computed as 100 * sum(sim - obs) / sum(obs).",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations.",
    version_added = "0.1.0",
    tags = c("core", "phase-2")
  )
}

metric_mae <- function(sim, obs) {
  mean(abs(sim - obs))
}

core_metric_spec_mae <- function() {
  list(
    id = "mae",
    fun = metric_mae,
    name = "Mean Absolute Error",
    description = "MAE computed as mean absolute deviation between sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard MAE definition in statistical error analysis literature.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_mse <- function(sim, obs) {
  mean((sim - obs)^2)
}

core_metric_spec_mse <- function() {
  list(
    id = "mse",
    fun = metric_mse,
    name = "Mean Squared Error",
    description = "MSE computed as mean squared deviation between sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard MSE definition in statistical error analysis literature.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_nrmse <- function(sim, obs) {
  obs_mean <- mean(obs)
  if (obs_mean == 0) {
    stop("NRMSE is undefined when mean(obs) is 0 (divide by zero).", call. = FALSE)
  }
  sqrt(mean((sim - obs)^2)) / obs_mean
}

core_metric_spec_nrmse <- function() {
  list(
    id = "nrmse",
    fun = metric_nrmse,
    name = "Normalized Root Mean Squared Error",
    description = "NRMSE computed as RMSE divided by mean(obs).",
    category = "error",
    perfect = 0,
    range = NULL,
    references = "Common NRMSE normalization by mean(obs) in model-evaluation practice.",
    version_added = "0.1.0",
    tags = character()
  )
}

validate_non_constant_series <- function(sim, obs, metric_id) {
  sd_sim <- stats::sd(sim)
  sd_obs <- stats::sd(obs)

  if (is.na(sd_sim) || is.na(sd_obs) || sd_sim == 0 || sd_obs == 0) {
    stop(sprintf("%s is undefined for constant series.", metric_id), call. = FALSE)
  }
}

metric_r <- function(sim, obs) {
  validate_non_constant_series(sim, obs, "R")
  stats::cor(sim, obs)
}

core_metric_spec_r <- function() {
  list(
    id = "r",
    fun = metric_r,
    name = "Pearson Correlation",
    description = "Pearson product-moment correlation coefficient between sim and obs.",
    category = "correlation",
    perfect = 1,
    range = c(-1, 1),
    references = "Pearson correlation coefficient (standard definition).",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_r2 <- function(sim, obs) {
  validate_non_constant_series(sim, obs, "R2")
  stats::cor(sim, obs)^2
}

core_metric_spec_r2 <- function() {
  list(
    id = "r2",
    fun = metric_r2,
    name = "Squared Pearson Correlation",
    description = "R2 defined as squared Pearson correlation cor(sim, obs)^2.",
    category = "correlation",
    perfect = 1,
    range = c(0, 1),
    references = "R-squared defined as squared Pearson correlation.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_kge <- function(sim, obs) {
  obs_sd <- stats::sd(obs)
  obs_mean <- mean(obs)
  sim_sd <- stats::sd(sim)

  if (obs_sd == 0) {
    stop("KGE undefined because sd(obs) == 0.", call. = FALSE)
  }
  if (obs_mean == 0) {
    stop("KGE undefined because mean(obs) == 0.", call. = FALSE)
  }
  if (sim_sd == 0) {
    stop("KGE undefined for constant sim series.", call. = FALSE)
  }

  r <- stats::cor(sim, obs)
  alpha <- sim_sd / obs_sd
  beta <- mean(sim) / obs_mean

  1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)
}

core_metric_spec_kge <- function() {
  list(
    id = "kge",
    fun = metric_kge,
    name = "Kling-Gupta Efficiency",
    description = "KGE (2009) using r, alpha=sd(sim)/sd(obs), and beta=mean(sim)/mean(obs).",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_rsr <- function(sim, obs) {
  obs_sd <- stats::sd(obs)
  if (obs_sd == 0) {
    stop("RSR undefined because sd(obs) == 0.", call. = FALSE)
  }
  metric_rmse(sim, obs) / obs_sd
}

core_metric_spec_rsr <- function() {
  list(
    id = "rsr",
    fun = metric_rsr,
    name = "RSR",
    description = "RSR computed as RMSE(sim, obs) divided by sd(obs).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_mape <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("MAPE undefined because obs contains zero.", call. = FALSE)
  }
  100 * mean(abs((sim - obs) / obs))
}

core_metric_spec_mape <- function() {
  list(
    id = "mape",
    fun = metric_mape,
    name = "Mean Absolute Percentage Error",
    description = "MAPE computed as 100 * mean(abs((sim - obs) / obs)).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard mean absolute percentage error definition in forecasting and error-analysis literature.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_mpe <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("MPE undefined because obs contains zero.", call. = FALSE)
  }
  100 * mean((sim - obs) / obs)
}

core_metric_spec_mpe <- function() {
  list(
    id = "mpe",
    fun = metric_mpe,
    name = "Mean Percentage Error",
    description = "MPE computed as 100 * mean((sim - obs) / obs).",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Standard mean percentage error definition in forecasting and error-analysis literature.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_ve <- function(sim, obs) {
  obs_sum <- sum(obs)
  if (obs_sum == 0) {
    stop("VE undefined because sum(obs) == 0.", call. = FALSE)
  }
  1 - sum(abs(sim - obs)) / obs_sum
}

core_metric_spec_ve <- function() {
  list(
    id = "ve",
    fun = metric_ve,
    name = "Volumetric Efficiency",
    description = "VE computed as 1 - sum(abs(sim - obs)) / sum(obs).",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_nrmse_sd <- function(sim, obs) {
  obs_sd <- stats::sd(obs)
  if (obs_sd == 0) {
    stop("NRMSE_SD undefined because sd(obs) == 0.", call. = FALSE)
  }
  metric_rmse(sim, obs) / obs_sd
}

core_metric_spec_nrmse_sd <- function() {
  list(
    id = "nrmse_sd",
    fun = metric_nrmse_sd,
    name = "NRMSE by SD",
    description = "NRMSE_SD computed as RMSE(sim, obs) divided by sd(obs).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Project-defined NRMSE variant normalized by sd(obs).",
    version_added = "0.1.0",
    tags = character()
  )
}
