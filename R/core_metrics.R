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

metric_me <- function(sim, obs) {
  mean(sim - obs)
}

core_metric_spec_me <- function() {
  list(
    id = "me",
    fun = metric_me,
    name = "Mean Error",
    description = "ME computed as mean(sim - obs).",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Standard mean error definition in forecast error analysis.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_d <- function(sim, obs) {
  obs_mean <- mean(obs)
  denom <- sum((abs(sim - obs_mean) + abs(obs - obs_mean))^2)
  if (denom == 0) {
    stop("d is undefined (denominator is 0; constant series).", call. = FALSE)
  }
  1 - sum((sim - obs)^2) / denom
}

core_metric_spec_d <- function() {
  list(
    id = "d",
    fun = metric_d,
    name = "Willmott Index of Agreement",
    description = "Willmott d (1981) using squared-error agreement formulation.",
    category = "agreement",
    perfect = 1,
    range = c(0, 1),
    references = "Willmott, C.J. (1981). On the validation of models.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_md <- function(sim, obs) {
  obs_mean <- mean(obs)
  denom <- sum(abs(sim - obs_mean) + abs(obs - obs_mean))
  if (denom == 0) {
    stop("md is undefined (denominator is 0; constant series).", call. = FALSE)
  }
  1 - sum(abs(sim - obs)) / denom
}

core_metric_spec_md <- function() {
  list(
    id = "md",
    fun = metric_md,
    name = "Modified Index of Agreement",
    description = "Modified Willmott agreement index using absolute deviations.",
    category = "agreement",
    perfect = 1,
    range = NULL,
    references = "Willmott, C.J., Robeson, S.M., & Matsuura, K. (2012). A refined index of model performance.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_rd <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rd undefined because obs contains zero.", call. = FALSE)
  }
  obs_mean <- mean(obs)
  rel_err <- (sim - obs) / obs
  denom <- sum((abs((sim - obs_mean) / obs) + abs((obs - obs_mean) / obs))^2)
  if (denom == 0) {
    stop("rd is undefined (denominator is 0).", call. = FALSE)
  }
  1 - sum(rel_err^2) / denom
}

core_metric_spec_rd <- function() {
  list(
    id = "rd",
    fun = metric_rd,
    name = "Relative Index of Agreement",
    description = "Relative squared-error agreement index using obs-normalized terms.",
    category = "agreement",
    perfect = 1,
    range = NULL,
    references = "Willmott agreement-index family with relative normalization by observations.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_dr <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("dr undefined because obs contains zero.", call. = FALSE)
  }
  obs_mean <- mean(obs)
  rel_abs <- abs(sim - obs) / abs(obs)
  denom <- sum(abs(sim - obs_mean) / abs(obs) + abs(obs - obs_mean) / abs(obs))
  if (denom == 0) {
    stop("dr is undefined (denominator is 0).", call. = FALSE)
  }
  1 - sum(rel_abs) / denom
}

core_metric_spec_dr <- function() {
  list(
    id = "dr",
    fun = metric_dr,
    name = "Relative Absolute Index of Agreement",
    description = "Relative absolute-error agreement index using obs-normalized terms.",
    category = "agreement",
    perfect = 1,
    range = NULL,
    references = "Willmott agreement-index family with relative absolute-error normalization.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_br2 <- function(sim, obs) {
  sd_sim <- stats::sd(sim)
  sd_obs <- stats::sd(obs)
  mean_sim <- mean(sim)
  mean_obs <- mean(obs)

  if (sd_sim == 0 || sd_obs == 0) {
    stop("br2 undefined because sd == 0.", call. = FALSE)
  }
  if (mean_sim == 0 || mean_obs == 0) {
    stop("br2 undefined because mean == 0.", call. = FALSE)
  }

  r <- stats::cor(sim, obs)
  if (is.na(r)) {
    stop("br2 undefined because cor(sim, obs) is NA.", call. = FALSE)
  }

  sd_penalty <- min(sd_sim, sd_obs) / max(sd_sim, sd_obs)
  mean_penalty <- min(mean_sim, mean_obs) / max(mean_sim, mean_obs)

  (r^2) * (sd_penalty^2) * (mean_penalty^2)
}

core_metric_spec_br2 <- function() {
  list(
    id = "br2",
    fun = metric_br2,
    name = "Bias-Corrected R-squared",
    description = "Bias-penalized Pearson r^2 using variability and mean-ratio penalties.",
    category = "correlation",
    perfect = 1,
    range = c(0, 1),
    references = "Project-defined bias-corrected R2 variant pending dedicated paper citation.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_ssq <- function(sim, obs) {
  sum((sim - obs)^2)
}

core_metric_spec_ssq <- function() {
  list(
    id = "ssq",
    fun = metric_ssq,
    name = "Sum of Squared Errors",
    description = "SSQ computed as sum((sim - obs)^2).",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard least-squares objective definition.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_ubrmse <- function(sim, obs) {
  sqrt(mean(((sim - mean(sim)) - (obs - mean(obs)))^2))
}

core_metric_spec_ubrmse <- function() {
  list(
    id = "ubrmse",
    fun = metric_ubrmse,
    name = "Unbiased RMSE",
    description = "ubRMSE computed from anomalies relative to each series mean.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Standard unbiased RMSE definition in model-evaluation literature.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_wnse <- function(sim, obs) {
  if (any(obs < 0)) {
    stop("wNSE undefined because obs contains negative values (weights must be nonnegative).", call. = FALSE)
  }
  obs_mean <- mean(obs)
  num <- sum(obs * (sim - obs)^2)
  den <- sum(obs * (obs - obs_mean)^2)
  if (den == 0) {
    stop("wNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - num / den
}

core_metric_spec_wnse <- function() {
  list(
    id = "wnse",
    fun = metric_wnse,
    name = "Weighted NSE",
    description = "Weighted NSE using observation weights w = obs.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE weighted variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_wsnse <- function(sim, obs) {
  if (any(obs < 0)) {
    stop("wsNSE undefined because obs contains negative values (weights must be nonnegative).", call. = FALSE)
  }
  obs_mean <- mean(obs)
  w <- obs^2
  num <- sum(w * (sim - obs)^2)
  den <- sum(w * (obs - obs_mean)^2)
  if (den == 0) {
    stop("wsNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - num / den
}

core_metric_spec_wsnse <- function() {
  list(
    id = "wsnse",
    fun = metric_wsnse,
    name = "Weighted Squared NSE",
    description = "Weighted NSE variant using squared observation weights w = obs^2.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE weighted variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_rnse <- function(sim, obs) {
  if (any(obs == 0)) {
    stop("rNSE undefined because obs contains zero.", call. = FALSE)
  }
  rel <- (sim - obs) / obs
  den <- sum(((obs - mean(obs)) / obs)^2)
  if (den == 0) {
    stop("rNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - sum(rel^2) / den
}

core_metric_spec_rnse <- function() {
  list(
    id = "rnse",
    fun = metric_rnse,
    name = "Relative NSE",
    description = "Relative NSE using observation-scaled errors.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE relative variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_mnse <- function(sim, obs) {
  num <- sum(abs(sim - obs))
  den <- sum(abs(obs - mean(obs)))
  if (den == 0) {
    stop("mNSE undefined (denominator is 0).", call. = FALSE)
  }
  1 - num / den
}

core_metric_spec_mnse <- function() {
  list(
    id = "mnse",
    fun = metric_mnse,
    name = "Modified NSE",
    description = "Modified NSE using absolute-error numerator and denominator.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "NSE modified variants in hydrology literature; exact citation to be refined.",
    version_added = "0.1.0",
    tags = character()
  )
}
