validate_distribution_vector <- function(x, name) {
  validate_numeric_vector(x, name)
  validate_finite(x, x)

  if (length(x) < 1L) {
    stop(sprintf("%s requires at least 1 value.", name), call. = FALSE)
  }

  invisible(TRUE)
}

# Shared Batch B1 empirical-distribution convention:
# - support comparisons use the ascending union support grid of sim and obs
# - empirical CDFs are right-continuous step functions evaluated on that grid
# - quantile comparisons use fixed probabilities p = 0.1, 0.2, ..., 0.9 with
#   stats::quantile(..., type = 7)
# - Wasserstein distance uses equal-weight empirical quantile coupling for the
#   paired aligned sample size already established by package preprocessing

.hm_b1_union_support <- function(sim, obs) {
  sort(unique(c(as.numeric(sim), as.numeric(obs))))
}

.hm_b1_ecdf_values <- function(x, grid) {
  stats::ecdf(as.numeric(x))(grid)
}

.hm_b1_fixed_prob_grid <- function() {
  seq(0.1, 0.9, by = 0.1)
}

.hm_b1_fdc_normalize <- function(x, name) {
  x <- as.numeric(x)
  x_range <- diff(range(x))
  if (!is.finite(x_range) || x_range == 0) {
    stop(sprintf("%s is undefined because range(%s) == 0.", name, name), call. = FALSE)
  }

  (sort(x, decreasing = TRUE) - min(x)) / x_range
}

.hm_b1_anderson_darling_weights <- function(sim, obs, grid) {
  n <- length(sim)
  m <- length(obs)
  pooled_counts <- vapply(grid, function(value) {
    sum(sim == value) + sum(obs == value)
  }, numeric(1))
  pooled_cdf <- (n * .hm_b1_ecdf_values(sim, grid) + m * .hm_b1_ecdf_values(obs, grid)) / (n + m)

  list(
    dH = pooled_counts / (n + m),
    H = pooled_cdf
  )
}

metric_ks_statistic <- function(sim, obs) {
  validate_distribution_vector(sim, "ks_statistic")
  validate_distribution_vector(obs, "ks_statistic")

  grid <- .hm_b1_union_support(sim, obs)
  max(abs(.hm_b1_ecdf_values(sim, grid) - .hm_b1_ecdf_values(obs, grid)))
}

core_metric_spec_ks_statistic <- function() {
  list(
    id = "ks_statistic",
    fun = metric_ks_statistic,
    name = "Kolmogorov-Smirnov Statistic",
    description = "Maximum absolute gap between the empirical CDFs of sim and obs on the pooled support grid.",
    category = "agreement",
    perfect = 0,
    range = c(0, 1),
    references = "Nikiforov (1994) exact Smirnov two-sample test context; package metric reports the two-sample empirical KS distance only.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_cdf_rmse <- function(sim, obs) {
  validate_distribution_vector(sim, "cdf_rmse")
  validate_distribution_vector(obs, "cdf_rmse")

  grid <- .hm_b1_union_support(sim, obs)
  diff_cdf <- .hm_b1_ecdf_values(sim, grid) - .hm_b1_ecdf_values(obs, grid)
  sqrt(mean(diff_cdf^2))
}

core_metric_spec_cdf_rmse <- function() {
  list(
    id = "cdf_rmse",
    fun = metric_cdf_rmse,
    name = "CDF RMSE",
    description = "RMSE between empirical CDFs of sim and obs evaluated on the pooled support grid.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Empirical-distribution comparison grounded in Smirnov-type EDF distances; package metric uses RMSE over the pooled support grid.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_quantile_deviation <- function(sim, obs) {
  validate_distribution_vector(sim, "quantile_deviation")
  validate_distribution_vector(obs, "quantile_deviation")

  probs <- .hm_b1_fixed_prob_grid()
  sim_q <- stats::quantile(sim, probs = probs, type = 7, names = FALSE)
  obs_q <- stats::quantile(obs, probs = probs, type = 7, names = FALSE)

  sqrt(mean((sim_q - obs_q)^2))
}

core_metric_spec_quantile_deviation <- function() {
  list(
    id = "quantile_deviation",
    fun = metric_quantile_deviation,
    name = "Quantile Deviation",
    description = "RMSE between type-7 sample quantiles on the fixed probability grid p = 0.1, ..., 0.9.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Hyndman & Fan (1996) sample-quantile conventions; package metric uses a fixed p = 0.1..0.9 quantile RMSE.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_fdc_shape_distance <- function(sim, obs) {
  validate_distribution_vector(sim, "fdc_shape_distance")
  validate_distribution_vector(obs, "fdc_shape_distance")

  sim_norm <- .hm_b1_fdc_normalize(sim, "sim")
  obs_norm <- .hm_b1_fdc_normalize(obs, "obs")

  sqrt(mean((sim_norm - obs_norm)^2))
}

core_metric_spec_fdc_shape_distance <- function() {
  list(
    id = "fdc_shape_distance",
    fun = metric_fdc_shape_distance,
    name = "FDC Shape Distance",
    description = "RMSE between descending flow-duration curves after within-series range normalization to [0, 1].",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Searcy (1959) flow-duration-curve construction; package metric uses range-normalized descending FDC RMSE as a shape-only distance.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_anderson_darling_stat <- function(sim, obs) {
  validate_distribution_vector(sim, "anderson_darling_stat")
  validate_distribution_vector(obs, "anderson_darling_stat")

  grid <- .hm_b1_union_support(sim, obs)
  sim_cdf <- .hm_b1_ecdf_values(sim, grid)
  obs_cdf <- .hm_b1_ecdf_values(obs, grid)
  weights <- .hm_b1_anderson_darling_weights(sim, obs, grid)
  valid <- weights$H > 0 & weights$H < 1

  if (!any(valid)) {
    return(0)
  }

  sum(((sim_cdf[valid] - obs_cdf[valid])^2 / (weights$H[valid] * (1 - weights$H[valid]))) * weights$dH[valid])
}

core_metric_spec_anderson_darling_stat <- function() {
  list(
    id = "anderson_darling_stat",
    fun = metric_anderson_darling_stat,
    name = "Anderson-Darling Distribution Statistic",
    description = "Tail-weighted empirical CDF gap statistic on the pooled support grid using Anderson-Darling weighting.",
    category = "agreement",
    perfect = 0,
    range = c(0, Inf),
    references = "Pettitt (1976) and Scholz & Stephens (1987) tail-weighted two-sample EDF comparison context; package metric reports a pooled-grid Anderson-Darling-style distance statistic.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

metric_wasserstein_distance <- function(sim, obs) {
  validate_distribution_vector(sim, "wasserstein_distance")
  validate_distribution_vector(obs, "wasserstein_distance")
  validate_equal_length(sim, obs)

  mean(abs(sort(as.numeric(sim)) - sort(as.numeric(obs))))
}

core_metric_spec_wasserstein_distance <- function() {
  list(
    id = "wasserstein_distance",
    fun = metric_wasserstein_distance,
    name = "1-Wasserstein Distance",
    description = "Empirical one-dimensional Wasserstein distance via equal-weight quantile coupling of sorted samples.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Ramdas, Garcia, & Cuturi (2017) Wasserstein two-sample comparison context; package metric uses equal-weight empirical quantile coupling.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b1")
  )
}

# Shared Batch B2 conventions:
# - sqrt_nse applies sqrt() to both sim and obs before the standard NSE formula
# - seasonal_nse computes NSE on monthly climatology means and therefore
#   requires monthly seasonal structure
# - weighted_kge uses the explicit weighted Euclidean distance in KGE component
#   space with stable defaults w_r = w_alpha = w_beta = 1
# - quantile_kge uses type-7 sample quantiles on the fixed probability grid
#   p = 0.1, ..., 0.9 and applies the standard KGE form to those summaries

.hm_b2_validate_positive_weight <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x) || x <= 0) {
    stop(sprintf("`%s` must be a positive finite numeric scalar.", name), call. = FALSE)
  }

  as.numeric(x)
}

metric_sqrt_nse <- function(sim, obs) {
  if (length(obs) < 1L) {
    stop("sqrt_nse requires at least 1 value.", call. = FALSE)
  }
  if (any(sim < 0) || any(obs < 0)) {
    stop("sqrt_nse is undefined for negative values.", call. = FALSE)
  }

  sim_sqrt <- sqrt(sim)
  obs_sqrt <- sqrt(obs)
  denom <- sum((obs_sqrt - mean(obs_sqrt))^2)

  if (denom == 0) {
    stop("sqrt_nse is undefined because sqrt(obs) has zero variance.", call. = FALSE)
  }

  1 - sum((sim_sqrt - obs_sqrt)^2) / denom
}

core_metric_spec_sqrt_nse <- function() {
  list(
    id = "sqrt_nse",
    fun = metric_sqrt_nse,
    name = "Square-Root NSE",
    description = "NSE computed after applying the square-root transform to non-negative sim and obs.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nash & Sutcliffe (1970) baseline NSE with transformed-objective-function context from Krause et al. (2005).",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b2")
  )
}

metric_seasonal_nse <- function(sim, obs, index = NULL) {
  if (length(obs) < 12L) {
    stop("seasonal_nse requires at least 12 monthly values.", call. = FALSE)
  }

  groups <- .hm_monthly_groups_for_seasonal_bias(index)
  sim_month <- tapply(sim, groups, mean)
  obs_month <- tapply(obs, groups, mean)
  sim_month <- as.numeric(sim_month[as.character(1:12)])
  obs_month <- as.numeric(obs_month[as.character(1:12)])

  if (any(!is.finite(sim_month)) || any(!is.finite(obs_month))) {
    stop("seasonal_nse is undefined because monthly climatology could not be estimated.", call. = FALSE)
  }

  denom <- sum((obs_month - mean(obs_month))^2)
  if (denom == 0) {
    stop("seasonal_nse is undefined because observed monthly climatology has zero variance.", call. = FALSE)
  }

  1 - sum((sim_month - obs_month)^2) / denom
}

core_metric_spec_seasonal_nse <- function() {
  list(
    id = "seasonal_nse",
    fun = metric_seasonal_nse,
    name = "Seasonal NSE",
    description = "NSE computed on monthly climatology means inferred from monthly ts or aligned date-like indexed input.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Nash & Sutcliffe (1970) baseline NSE with seasonal streamflow context from Gnann et al. (2020) and Berghuijs et al. (2025); the package metric is monthly-climatology NSE.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b2")
  )
}

metric_weighted_kge <- function(sim, obs, w_r = 1, w_alpha = 1, w_beta = 1) {
  w_r <- .hm_b2_validate_positive_weight(w_r, "w_r")
  w_alpha <- .hm_b2_validate_positive_weight(w_alpha, "w_alpha")
  w_beta <- .hm_b2_validate_positive_weight(w_beta, "w_beta")

  r <- metric_r(sim, obs)
  alpha <- metric_alpha(sim, obs)
  beta <- metric_beta(sim, obs)

  1 - sqrt((w_r * (r - 1))^2 + (w_alpha * (alpha - 1))^2 + (w_beta * (beta - 1))^2)
}

core_metric_spec_weighted_kge <- function() {
  list(
    id = "weighted_kge",
    fun = metric_weighted_kge,
    name = "Weighted Kling-Gupta Efficiency",
    description = "Weighted KGE with defaults w_r = 1, w_alpha = 1, and w_beta = 1.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Gupta et al. (2009) KGE component framework; the exact weighted extension is a stable package-defined Phase 3 variant.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b2")
  )
}

metric_quantile_kge <- function(sim, obs) {
  if (length(obs) < 3L) {
    stop("quantile_kge requires at least 3 values.", call. = FALSE)
  }

  probs <- .hm_b1_fixed_prob_grid()
  sim_q <- stats::quantile(sim, probs = probs, type = 7, names = FALSE)
  obs_q <- stats::quantile(obs, probs = probs, type = 7, names = FALSE)
  obs_q_sd <- stats::sd(obs_q)
  sim_q_sd <- stats::sd(sim_q)
  obs_q_mean <- mean(obs_q)

  if (obs_q_sd == 0) {
    stop("quantile_kge is undefined because quantile(obs) has zero variance.", call. = FALSE)
  }
  if (sim_q_sd == 0) {
    stop("quantile_kge is undefined for constant quantile(sim) summaries.", call. = FALSE)
  }
  if (obs_q_mean == 0) {
    stop("quantile_kge is undefined because mean(quantile(obs)) == 0.", call. = FALSE)
  }

  r_q <- stats::cor(sim_q, obs_q)
  alpha_q <- sim_q_sd / obs_q_sd
  beta_q <- mean(sim_q) / obs_q_mean

  1 - sqrt((r_q - 1)^2 + (alpha_q - 1)^2 + (beta_q - 1)^2)
}

core_metric_spec_quantile_kge <- function() {
  list(
    id = "quantile_kge",
    fun = metric_quantile_kge,
    name = "Quantile Kling-Gupta Efficiency",
    description = "KGE applied to type-7 sample quantiles on the fixed probability grid p = 0.1, ..., 0.9.",
    category = "efficiency",
    perfect = 1,
    range = c(-Inf, 1),
    references = "Gupta et al. (2009) KGE component framework with Hyndman & Fan (1996) quantile conventions; the exact quantile-summary extension is a stable package-defined Phase 3 variant.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-b", "batch-b2")
  )
}
