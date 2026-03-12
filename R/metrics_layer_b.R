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
