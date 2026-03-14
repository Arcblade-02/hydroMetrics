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
  obs_sum <- sum(obs)
  if (obs_sum == 0) {
    stop("sum(obs) is zero; PBIAS undefined", call. = FALSE)
  }

  100 * sum(sim - obs) / obs_sum
}

core_metric_spec_pbias <- function() {
  list(
    id = "pbias",
    fun = metric_pbias,
    name = "Percent Bias",
    description = "PBIAS computed as 100 * sum(sim - obs) / sum(obs).",
    category = "bias",
    perfect = 0,
    range = c(-Inf, Inf),
    references = "Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations.",
    version_added = "0.1.0",
    tags = c("core", "phase-2")
  )
}

metric_cp <- function(sim, obs) {
  if (length(obs) < 2) {
    stop("cp requires at least 2 observations.", call. = FALSE)
  }

  obs_t <- obs[-1]
  sim_t <- sim[-1]
  obs_lag <- obs[-length(obs)]

  num <- sum((obs_t - sim_t)^2)
  den <- sum((obs_t - obs_lag)^2)

  if (den == 0) {
    stop("cp is undefined because persistence baseline variance is zero.", call. = FALSE)
  }

  1 - num / den
}

core_metric_spec_cp <- function() {
  list(
    id = "cp",
    fun = metric_cp,
    name = "Coefficient of Persistence",
    description = "Persistence skill score against one-step observed persistence baseline.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Persistence skill-score definition from hydrology model-evaluation literature.",
    version_added = "0.1.0",
    tags = character()
  )
}

compute_rfactor <- function(sim, obs) {
  if (length(sim) == 0L) {
    stop("rfactor requires at least 1 paired value.", call. = FALSE)
  }

  denom <- mean(abs(obs))
  if (denom == 0) {
    stop("rfactor is undefined because mean(abs(obs)) is zero.", call. = FALSE)
  }

  mean(abs(sim - obs)) / denom
}

metric_rfactor <- function(sim, obs) {
  compute_rfactor(sim, obs)
}

core_metric_spec_rfactor <- function() {
  list(
    id = "rfactor",
    fun = metric_rfactor,
    name = "R-factor",
    description = "Mean absolute error normalized by mean absolute observations.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Project-defined compatibility rfactor: mean(abs(sim - obs)) / mean(abs(obs)).",
    version_added = "0.1.0",
    tags = character()
  )
}

compute_pfactor <- function(sim, obs, tol = 0.10) {
  if (!is.numeric(tol) || length(tol) != 1L || !is.finite(tol) || tol < 0) {
    stop("`tol` must be a non-negative numeric scalar.", call. = FALSE)
  }

  if (length(sim) == 0L) {
    stop("pfactor requires at least 1 paired value.", call. = FALSE)
  }

  threshold <- tol * abs(obs)
  threshold[obs == 0] <- tol
  mean(abs(sim - obs) <= threshold)
}

metric_pfactor <- function(sim, obs, tol = 0.10) {
  compute_pfactor(sim, obs, tol = tol)
}

core_metric_spec_pfactor <- function() {
  list(
    id = "pfactor",
    fun = metric_pfactor,
    name = "P-factor",
    description = "Proportion of paired values within a relative tolerance band around observations.",
    category = "efficiency",
    perfect = 1,
    range = c(0, 1),
    references = "Project-defined compatibility pfactor using tolerance-band hit proportion.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_mae <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("MAE requires at least 1 value.", call. = FALSE)
  }

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

metric_beta <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("beta requires at least 1 value.", call. = FALSE)
  }

  obs_mean <- mean(obs)
  if (obs_mean == 0) {
    stop("mean(obs) is zero; beta undefined", call. = FALSE)
  }

  mean(sim) / obs_mean
}

core_metric_spec_beta <- function() {
  list(
    id = "beta",
    fun = metric_beta,
    name = "Bias Ratio",
    description = "Beta component computed as mean(sim) / mean(obs).",
    category = "bias",
    perfect = 1,
    range = c(-Inf, Inf),
    references = "Gupta, H. V., Kling, H., Yilmaz, K. K., & Martinez, G. F. (2009). KGE-family component definition using the bias ratio mean(sim)/mean(obs).",
    version_added = "0.1.0",
    tags = c("kge-component")
  )
}

metric_alpha <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("alpha requires at least 2 values.", call. = FALSE)
  }

  obs_sd <- stats::sd(obs)
  if (obs_sd == 0) {
    stop("sd(obs) is zero; alpha undefined", call. = FALSE)
  }

  stats::sd(sim) / obs_sd
}

core_metric_spec_alpha <- function() {
  list(
    id = "alpha",
    fun = metric_alpha,
    name = "Variability Ratio",
    description = "Alpha component computed as sd(sim) / sd(obs).",
    category = "scale",
    perfect = 1,
    range = c(0, Inf),
    references = "Gupta, H. V., Kling, H., Yilmaz, K. K., & Martinez, G. F. (2009). KGE-family component definition using the variability ratio sd(sim)/sd(obs).",
    version_added = "0.1.0",
    tags = c("kge-component")
  )
}

validate_non_constant_series <- function(sim, obs, metric_id) {
  sd_sim <- stats::sd(sim)
  sd_obs <- stats::sd(obs)

  if (!is.finite(sd_sim) || !is.finite(sd_obs) || sd_sim == 0 || sd_obs == 0) {
    stop(sprintf("%s is undefined for constant series.", metric_id), call. = FALSE)
  }
}

metric_r <- function(sim, obs) {
  if (length(obs) < 2L) {
    stop("r requires at least 2 values.", call. = FALSE)
  }

  if (stats::sd(sim) == 0 || stats::sd(obs) == 0) {
    stop("zero variance; correlation undefined", call. = FALSE)
  }

  stats::cor(sim, obs, method = "pearson")
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
    references = "Gupta, H. V., Kling, H., Yilmaz, K. K., & Martinez, G. F. (2009). KGE-family component definition using the Pearson correlation term.",
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
  if (length(obs) < 2L) {
    stop("RSR requires at least 2 values.", call. = FALSE)
  }

  obs_sd <- stats::sd(obs)
  if (obs_sd == 0) {
    stop("sd(obs) is zero; RSR undefined", call. = FALSE)
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
  if (stats::sd(obs) == 0) {
    stop("br2 undefined because sd(obs) == 0.", call. = FALSE)
  }

  r <- stats::cor(sim, obs)
  if (!is.finite(r)) {
    stop("br2 undefined because cor(sim, obs) is NA.", call. = FALSE)
  }

  slope <- unname(stats::coef(stats::lm(sim ~ obs))[2])
  if (!is.finite(slope)) {
    stop("br2 undefined because lm(sim ~ obs) slope is NA.", call. = FALSE)
  }

  abs(slope) * (r^2)
}

core_metric_spec_br2 <- function() {
  list(
    id = "br2",
    fun = metric_br2,
    name = "Bias-Corrected R-squared",
    description = "Bias-corrected R-squared computed as abs(slope(sim ~ obs)) * cor(sim, obs)^2.",
    category = "correlation",
    perfect = 1,
    range = c(0, Inf),
    references = "Krause, P., Boyle, D. P., & Baese, F. (2005). Comparison of different efficiency criteria for hydrological model assessment.",
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
    references = "Based on Nash & Sutcliffe (1970) NSE, using observation weights w = obs in the numerator and denominator.",
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
    references = "Based on Nash & Sutcliffe (1970) NSE, using squared observation weights w = obs^2 in the numerator and denominator.",
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
    references = "Based on Nash & Sutcliffe (1970) NSE, using observation-scaled relative errors.",
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
    references = "Based on Nash & Sutcliffe (1970) NSE, using absolute-error numerator and denominator terms.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_kgekm <- function(sim, obs) {
  mean_sim <- mean(sim)
  mean_obs <- mean(obs)
  sd_obs <- stats::sd(obs)

  if (mean_sim == 0 || mean_obs == 0) {
    stop("KGEkm undefined because mean(sim) == 0 or mean(obs) == 0.", call. = FALSE)
  }
  if (sd_obs == 0) {
    stop("KGEkm undefined because sd(obs) == 0.", call. = FALSE)
  }

  r <- stats::cor(sim, obs)
  if (!is.finite(r)) {
    stop("KGEkm undefined because cor(sim, obs) is NA.", call. = FALSE)
  }

  cv_sim <- stats::sd(sim) / mean_sim
  cv_obs <- sd_obs / mean_obs
  gamma <- cv_sim / cv_obs
  beta <- mean_sim / mean_obs

  1 - sqrt((r - 1)^2 + (gamma - 1)^2 + (beta - 1)^2)
}

core_metric_spec_kgekm <- function() {
  list(
    id = "kgekm",
    fun = metric_kgekm,
    name = "KGE Modified Variability",
    description = "KGE variant using gamma = CV(sim)/CV(obs) and beta = mean(sim)/mean(obs).",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Kling, H., Fuchs, M., & Paulin, M. (2012). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_kgelf <- function(sim, obs) {
  if (any(sim < 0) || any(obs < 0)) {
    stop("KGElf undefined because sim/obs contain negative values for low-flow log transform.", call. = FALSE)
  }

  sim_lf <- log1p(sim)
  obs_lf <- log1p(obs)
  if (stats::sd(obs_lf) == 0) {
    stop("KGElf undefined because sd(log1p(obs)) == 0.", call. = FALSE)
  }

  metric_kge(sim_lf, obs_lf)
}

core_metric_spec_kgelf <- function() {
  list(
    id = "kgelf",
    fun = metric_kgelf,
    name = "KGE Low-Flow",
    description = "Low-flow KGE using log1p-transformed series prior to KGE computation.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Based on Gupta et al. (2009) KGE, with low-flow log-transformed objective-function context from Krause et al. (2005).",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_kgenp <- function(sim, obs) {
  iqr_obs <- stats::IQR(obs)
  median_obs <- stats::median(obs)

  if (iqr_obs == 0) {
    stop("KGEnp undefined because IQR(obs) == 0.", call. = FALSE)
  }
  if (median_obs == 0) {
    stop("KGEnp undefined because median(obs) == 0.", call. = FALSE)
  }

  r <- stats::cor(sim, obs, method = "spearman")
  if (!is.finite(r)) {
    stop("KGEnp undefined because Spearman correlation is NA.", call. = FALSE)
  }

  alpha <- stats::IQR(sim) / iqr_obs
  beta <- stats::median(sim) / median_obs

  1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)
}

core_metric_spec_kgenp <- function() {
  list(
    id = "kgenp",
    fun = metric_kgenp,
    name = "KGE Nonparametric",
    description = "Nonparametric KGE using Spearman correlation, IQR ratio, and median ratio.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Pool, S., Vis, M., & Seibert, J. (2018). Evaluating model performance: towards a non-parametric variant of the Kling-Gupta efficiency.",
    version_added = "0.1.0",
    tags = character()
  )
}

# Canonical sKGE implementation lives here with its helper and wrapper to
# avoid phase-residue shadowing across source files.
.hm_skge_month_groups_from_index <- function(index) {
  if (is.null(index) || length(index) == 0L) {
    return(NULL)
  }

  if (inherits(index, "Date") || inherits(index, "POSIXt")) {
    idx <- as.POSIXlt(index, tz = "UTC")
    serial <- (idx$year + 1900L) * 12L + idx$mon
    if (length(serial) < 2L || all(diff(serial) == 1L)) {
      return(as.integer(idx$mon + 1L))
    }
    return(NULL)
  }

  if (inherits(index, "yearmon")) {
    serial <- as.integer(floor(as.numeric(index) * 12 + 1e-8))
    if (length(serial) < 2L || all(diff(serial) == 1L)) {
      return(as.integer((serial %% 12L) + 1L))
    }
    return(NULL)
  }

  if (is.numeric(index)) {
    steps <- diff(index)
    months <- as.integer(round((index - floor(index)) * 12)) + 1L
    if (
      all(months >= 1L & months <= 12L) &&
      (length(steps) == 0L || all(abs((steps * 12) - 1) < 1e-6))
    ) {
      return(months)
    }
  }

  NULL
}

.hm_skge_grouped_mean <- function(sim, obs, groups) {
  group_scores <- numeric()

  for (m in 1:12) {
    idx <- which(groups == m)
    if (length(idx) < 2L) {
      next
    }

    score <- tryCatch(
      metric_kge(as.numeric(sim[idx]), as.numeric(obs[idx])),
      error = function(e) NULL
    )
    if (!is.null(score) && is.finite(score)) {
      group_scores <- c(group_scores, score)
    }
  }

  if (length(group_scores) == 0L) {
    stop("sKGE has no valid seasonal groups for KGE computation.", call. = FALSE)
  }

  mean(group_scores)
}

metric_skge <- function(sim, obs, index = NULL) {
  if (inherits(sim, "ts") || inherits(obs, "ts")) {
    if (!inherits(sim, "ts") || !inherits(obs, "ts")) {
      stop("sKGE requires both inputs to share the same time context.", call. = FALSE)
    }
    if (stats::frequency(sim) != 12 || stats::frequency(obs) != 12) {
      stop("sKGE requires monthly ts inputs (frequency = 12).", call. = FALSE)
    }

    return(.hm_skge_grouped_mean(sim, obs, stats::cycle(sim)))
  }

  groups <- .hm_skge_month_groups_from_index(index)
  if (is.null(groups)) {
    return(metric_kge(as.numeric(sim), as.numeric(obs)))
  }

  .hm_skge_grouped_mean(sim, obs, groups)
}

core_metric_spec_skge <- function() {
  list(
    id = "skge",
    fun = metric_skge,
    name = "Seasonal KGE",
    description = "Seasonal KGE using monthly groups when monthly time context is available, otherwise falling back to KGE.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Based on Gupta et al. (2009) KGE with monthly streamflow seasonality context from Gnann et al. (2020) and Berghuijs et al. (2025).",
    version_added = "0.1.0",
    tags = character()
  )
}

skge <- function(sim, obs, na.rm = NULL, ...) {
  payload <- preproc(sim = sim, obs = obs, na.rm = na.rm, ...)
  has_time_context <- inherits(sim, "ts") || inherits(obs, "ts") ||
    inherits(sim, "zoo") || inherits(sim, "xts") ||
    inherits(obs, "zoo") || inherits(obs, "xts")

  metric_skge(
    sim = payload$sim,
    obs = payload$obs,
    index = if (has_time_context) payload$index else NULL
  )
}

metric_pbiasfdc <- function(sim, obs) {
  if (any(sim < 0) || any(obs < 0)) {
    stop("pbiasfdc undefined because sim/obs contain negative values.", call. = FALSE)
  }

  p <- seq(0.01, 0.99, by = 0.01)
  qobs <- stats::quantile(obs, probs = 1 - p, type = 7, names = FALSE)
  qsim <- stats::quantile(sim, probs = 1 - p, type = 7, names = FALSE)

  if (sum(qobs) == 0) {
    stop("pbiasfdc undefined because sum(Qobs) == 0.", call. = FALSE)
  }

  100 * sum(qsim - qobs) / sum(qobs)
}

core_metric_spec_pbiasfdc <- function() {
  list(
    id = "pbiasfdc",
    fun = metric_pbiasfdc,
    name = "Percent Bias of Flow Duration Curve",
    description = "PBIASFDC using exceedance-quantile grid p = 0.01..0.99.",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Based on Moriasi et al. (2007) percent bias interpretation applied to a flow-duration-curve quantile grid in the Searcy (1959) convention.",
    version_added = "0.1.0",
    tags = character()
  )
}

.metric_year_from_index <- function(index) {
  years <- suppressWarnings(as.integer(format(as.POSIXlt(index, tz = "UTC"), "%Y")))
  if (any(!is.finite(years))) {
    stop("APFB could not derive calendar year from index.", call. = FALSE)
  }
  years
}

metric_apfb <- function(sim, obs, index) {
  if (missing(index) || is.null(index)) {
    stop("APFB requires an aligned time index.", call. = FALSE)
  }
  if (length(index) != length(obs)) {
    stop("APFB index length must match input length.", call. = FALSE)
  }

  years <- .metric_year_from_index(index)
  n_years <- length(unique(years))
  if (n_years < 2L) {
    stop("APFB requires at least 2 years after preprocessing.", call. = FALSE)
  }

  sim_peak <- tapply(sim, years, max)
  obs_peak <- tapply(obs, years, max)
  if (any(obs_peak == 0)) {
    stop("APFB is undefined because annual observed peak includes zero.", call. = FALSE)
  }

  ratios <- (sim_peak - obs_peak) / obs_peak
  if (length(ratios) == 0L || any(!is.finite(ratios))) {
    stop("APFB denominator invalid.", call. = FALSE)
  }

  mean(ratios) * 100
}

core_metric_spec_apfb <- function() {
  list(
    id = "apfb",
    fun = metric_apfb,
    name = "Annual Peak Flow Bias",
    description = "APFB as mean percent bias between annual simulated and observed peak flows.",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Clean-room APFB compatibility implementation over yearly maxima.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_hfb <- function(sim, obs, threshold_prob = 0.9) {
  if (!is.numeric(threshold_prob) ||
      length(threshold_prob) != 1L ||
      !is.finite(threshold_prob) ||
      threshold_prob <= 0 ||
      threshold_prob >= 1) {
    stop("`threshold_prob` must be a numeric scalar in (0, 1).", call. = FALSE)
  }

  q_high <- as.numeric(stats::quantile(obs, probs = threshold_prob, type = 7, names = FALSE))
  high_idx <- which(obs >= q_high)
  if (length(high_idx) < 3L) {
    stop("HFB requires at least 3 points at or above the high-flow threshold.", call. = FALSE)
  }

  sim_high <- sim[high_idx]
  obs_high <- obs[high_idx]
  den <- sum(obs_high)
  if (!is.finite(den) || den == 0) {
    stop("HFB denominator is zero.", call. = FALSE)
  }

  out <- (sum(sim_high - obs_high) / den) * 100
  if (!is.finite(out)) {
    stop("HFB denominator invalid.", call. = FALSE)
  }
  out
}

core_metric_spec_hfb <- function() {
  list(
    id = "hfb",
    fun = metric_hfb,
    name = "High Flow Bias",
    description = "HFB as percent bias over observations at or above a high-flow quantile threshold.",
    category = "bias",
    perfect = 0,
    range = NULL,
    references = "Clean-room HFB compatibility implementation using deterministic quantile thresholding.",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_rpearson <- function(sim, obs) {
  r <- suppressWarnings(stats::cor(sim, obs, method = "pearson"))
  if (!is.finite(r)) {
    stop("rPearson correlation undefined (constant series).", call. = FALSE)
  }
  r
}

core_metric_spec_rpearson <- function() {
  list(
    id = "rpearson",
    fun = metric_rpearson,
    name = "Pearson Correlation",
    description = "Pearson product-moment correlation coefficient.",
    category = "correlation",
    perfect = 1,
    range = c(-1, 1),
    references = "Pearson correlation coefficient (standard statistical definition).",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_rspearman <- function(sim, obs) {
  r <- suppressWarnings(stats::cor(sim, obs, method = "spearman"))
  if (!is.finite(r)) {
    stop("rSpearman correlation undefined (constant series).", call. = FALSE)
  }
  r
}

core_metric_spec_rspearman <- function() {
  list(
    id = "rspearman",
    fun = metric_rspearman,
    name = "Spearman Correlation",
    description = "Spearman rank correlation coefficient.",
    category = "correlation",
    perfect = 1,
    range = c(-1, 1),
    references = "Spearman rank correlation (standard statistical definition).",
    version_added = "0.1.0",
    tags = character()
  )
}

metric_rsd <- function(sim, obs) {
  sd_obs <- stats::sd(obs)
  if (sd_obs == 0) {
    stop("rSD undefined because sd(obs) == 0.", call. = FALSE)
  }
  stats::sd(sim) / sd_obs
}

core_metric_spec_rsd <- function() {
  list(
    id = "rsd",
    fun = metric_rsd,
    name = "Standard Deviation Ratio",
    description = "rSD computed as sd(sim) / sd(obs).",
    category = "scale",
    perfect = 1,
    range = c(0, Inf),
    references = "Project definition for hydrology compatibility: ratio of simulated to observed standard deviation.",
    version_added = "0.1.0",
    tags = character()
  )
}
