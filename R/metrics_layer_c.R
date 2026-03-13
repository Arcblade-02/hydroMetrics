# Shared Batch C1 conventions:
# - skewness_error uses the adjusted Fisher-Pearson sample skewness G1 from
#   Joanes & Gill (1998) and returns abs(G1_sim - G1_obs)
# - kurtosis_error uses the adjusted Fisher-Pearson sample excess kurtosis G2
#   from Joanes & Gill (1998) and returns abs(G2_sim - G2_obs)
# - iqr_error uses stats::quantile(..., type = 7) with IQR = Q3 - Q1 and
#   returns abs(IQR_sim - IQR_obs)

.hm_c1_validate_summary_vector <- function(x, metric_id, name, min_length) {
  validate_numeric_vector(x, name)
  validate_finite(x, x)

  if (length(x) < min_length) {
    stop(sprintf("%s requires at least %d values.", metric_id, min_length), call. = FALSE)
  }

  as.numeric(x)
}

.hm_c1_centered_moment <- function(x, order) {
  centered <- x - mean(x)
  mean(centered^order)
}

.hm_c1_adjusted_skewness <- function(x, metric_id, name) {
  x <- .hm_c1_validate_summary_vector(x, metric_id, name, min_length = 3L)
  m2 <- .hm_c1_centered_moment(x, 2L)
  if (!is.finite(m2) || m2 == 0) {
    stop(sprintf("%s is undefined because %s has zero variance.", metric_id, name), call. = FALSE)
  }

  n <- length(x)
  g1 <- .hm_c1_centered_moment(x, 3L) / (m2^(3 / 2))
  sqrt(n * (n - 1)) / (n - 2) * g1
}

.hm_c1_adjusted_excess_kurtosis <- function(x, metric_id, name) {
  x <- .hm_c1_validate_summary_vector(x, metric_id, name, min_length = 4L)
  m2 <- .hm_c1_centered_moment(x, 2L)
  if (!is.finite(m2) || m2 == 0) {
    stop(sprintf("%s is undefined because %s has zero variance.", metric_id, name), call. = FALSE)
  }

  n <- length(x)
  g2 <- .hm_c1_centered_moment(x, 4L) / (m2^2) - 3
  ((n - 1) / ((n - 2) * (n - 3))) * ((n + 1) * g2 + 6)
}

.hm_c1_type7_iqr <- function(x, metric_id, name) {
  x <- .hm_c1_validate_summary_vector(x, metric_id, name, min_length = 2L)
  qs <- stats::quantile(x, probs = c(0.25, 0.75), type = 7, names = FALSE)
  if (any(!is.finite(qs))) {
    stop(sprintf("%s is undefined because %s quartiles could not be estimated.", metric_id, name), call. = FALSE)
  }

  as.numeric(qs[[2L]] - qs[[1L]])
}

metric_skewness_error <- function(sim, obs) {
  abs(
    .hm_c1_adjusted_skewness(sim, "skewness_error", "sim") -
      .hm_c1_adjusted_skewness(obs, "skewness_error", "obs")
  )
}

core_metric_spec_skewness_error <- function() {
  list(
    id = "skewness_error",
    fun = metric_skewness_error,
    name = "Skewness Error",
    description = "Absolute difference between adjusted Fisher-Pearson sample skewness of sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Joanes & Gill (1998) sample skewness conventions; package metric uses absolute error in adjusted Fisher-Pearson sample skewness G1.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c1")
  )
}

metric_kurtosis_error <- function(sim, obs) {
  abs(
    .hm_c1_adjusted_excess_kurtosis(sim, "kurtosis_error", "sim") -
      .hm_c1_adjusted_excess_kurtosis(obs, "kurtosis_error", "obs")
  )
}

core_metric_spec_kurtosis_error <- function() {
  list(
    id = "kurtosis_error",
    fun = metric_kurtosis_error,
    name = "Kurtosis Error",
    description = "Absolute difference between adjusted Fisher-Pearson sample excess kurtosis of sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Joanes & Gill (1998) sample kurtosis conventions; package metric uses absolute error in adjusted Fisher-Pearson excess kurtosis G2.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c1")
  )
}

metric_iqr_error <- function(sim, obs) {
  abs(
    .hm_c1_type7_iqr(sim, "iqr_error", "sim") -
      .hm_c1_type7_iqr(obs, "iqr_error", "obs")
  )
}

core_metric_spec_iqr_error <- function() {
  list(
    id = "iqr_error",
    fun = metric_iqr_error,
    name = "Interquartile Range Error",
    description = "Absolute difference between type-7 interquartile ranges IQR = Q3 - Q1 of sim and obs.",
    category = "error",
    perfect = 0,
    range = c(0, Inf),
    references = "Hyndman & Fan (1996) sample-quantile conventions; package metric uses absolute error in the type-7 interquartile range.",
    version_added = "0.2.2",
    tags = c("phase-3", "layer-c", "batch-c1")
  )
}
