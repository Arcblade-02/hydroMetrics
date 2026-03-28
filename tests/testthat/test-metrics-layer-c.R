if (!exists("gof", mode = "function")) {
  find_pkg_root <- function(path = getwd()) {
    current <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(current, "DESCRIPTION"))) {
        return(current)
      }

      parent <- dirname(current)
      if (identical(parent, current)) {
        stop("Could not locate package root for standalone Layer C tests.", call. = FALSE)
      }
      current <- parent
    }
  }

  pkg_root <- find_pkg_root()
  file_env <- environment()
  for (path in list.files(file.path(pkg_root, "R"), pattern = "\\.[Rr]$", full.names = TRUE)) {
    sys.source(path, envir = file_env)
  }
}

.test_c1_adjusted_skewness <- function(x) {
  n <- length(x)
  m2 <- mean((x - mean(x))^2)
  g1 <- mean((x - mean(x))^3) / (m2^(3 / 2))
  sqrt(n * (n - 1)) / (n - 2) * g1
}

.test_c1_adjusted_excess_kurtosis <- function(x) {
  n <- length(x)
  m2 <- mean((x - mean(x))^2)
  g2 <- mean((x - mean(x))^4) / (m2^2) - 3
  ((n - 1) / ((n - 2) * (n - 3))) * ((n + 1) * g2 + 6)
}

.test_c1_type7_iqr <- function(x) {
  qs <- stats::quantile(x, probs = c(0.25, 0.75), type = 7, names = FALSE)
  as.numeric(qs[[2L]] - qs[[1L]])
}

.test_c2_sturges_bin_count <- function(n) {
  max(2L, as.integer(ceiling(log(n, base = 2) + 1)))
}

.test_c2_pooled_breaks <- function(sim, obs) {
  pooled <- c(sim, obs)
  x_min <- min(pooled)
  x_max <- max(pooled)

  if (x_min == x_max) {
    delta <- max(0.5, abs(x_min) * 1e-8)
    return(c(x_min - delta, x_max + delta))
  }

  seq(x_min, x_max, length.out = .test_c2_sturges_bin_count(length(pooled)) + 1L)
}

.test_c2_hist_probs <- function(x, breaks) {
  bins <- cut(x, breaks = breaks, include.lowest = TRUE, right = TRUE, labels = FALSE)
  tabulate(bins, nbins = length(breaks) - 1L) / length(x)
}

.test_c2_entropy <- function(x, breaks) {
  probs <- .test_c2_hist_probs(x, breaks)
  positive <- probs > 0
  -sum(probs[positive] * log(probs[positive]))
}

.test_c2_joint_probs <- function(sim, obs, breaks) {
  sim_bins <- cut(sim, breaks = breaks, include.lowest = TRUE, right = TRUE, labels = FALSE)
  obs_bins <- cut(obs, breaks = breaks, include.lowest = TRUE, right = TRUE, labels = FALSE)
  n_bins <- length(breaks) - 1L
  joint_index <- (sim_bins - 1L) * n_bins + obs_bins
  counts <- tabulate(joint_index, nbins = n_bins * n_bins)
  matrix(counts / length(sim), nrow = n_bins, ncol = n_bins, byrow = TRUE)
}

.test_c2_mutual_information <- function(sim, obs, breaks) {
  joint <- .test_c2_joint_probs(sim, obs, breaks)
  px <- rowSums(joint)
  py <- colSums(joint)
  denom <- outer(px, py)
  positive <- joint > 0
  sum(joint[positive] * log(joint[positive] / denom[positive]))
}

.test_c2_kl_obs_vs_sim <- function(sim, obs, breaks, epsilon = 1e-12) {
  p_obs <- .test_c2_hist_probs(obs, breaks)
  p_sim <- .test_c2_hist_probs(sim, breaks)
  p_obs <- (p_obs + epsilon) / sum(p_obs + epsilon)
  p_sim <- (p_sim + epsilon) / sum(p_sim + epsilon)
  sum(p_obs * log(p_obs / p_sim))
}

.test_c3_tail_threshold <- function(obs) {
  as.numeric(stats::quantile(obs, probs = 0.9, type = 7, names = FALSE))
}

.test_c3_event_count <- function(x, threshold) {
  idx <- which(x > threshold)
  if (!length(idx)) {
    return(0L)
  }

  length(split(idx, cumsum(c(1L, diff(idx) > 1L))))
}

.test_c4_rank_turnover <- function(sim, obs) {
  sim_rank <- rank(sim, ties.method = "average")
  obs_rank <- rank(obs, ties.method = "average")
  max_diff <- mean(abs(seq_along(obs) - rev(seq_along(obs))))
  mean(abs(sim_rank - obs_rank)) / max_diff
}

.test_c4_distribution_overlap <- function(sim, obs) {
  breaks <- .test_c2_pooled_breaks(sim, obs)
  p_sim <- .test_c2_hist_probs(sim, breaks)
  p_obs <- .test_c2_hist_probs(obs, breaks)
  sum(pmin(p_sim, p_obs))
}

.test_c4_quantile_shift_index <- function(sim, obs) {
  probs <- seq(0.1, 0.9, by = 0.1)
  sim_q <- stats::quantile(sim, probs = probs, type = 7, names = FALSE)
  obs_q <- stats::quantile(obs, probs = probs, type = 7, names = FALSE)
  mean(abs(sim_q - obs_q)) / .test_c1_type7_iqr(obs)
}

test_that("layer C batch C1 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("skewness_error", "kurtosis_error")

  expect_true(all(target %in% ids))
})

test_that("layer C batch C2 registry ids are present", {
  ids <- list_metrics()$id
  target <- c(
    "entropy_diff",
    "mutual_information_score",
    "mutual_information",
    "normalised_mi"
  )

  expect_true(all(target %in% ids))
})

test_that("layer C batch C3 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("tail_dependence_score", "extreme_event_ratio")

  expect_true(all(target %in% ids))
})

test_that("layer C batch C4 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("rank_turnover_score", "distribution_overlap", "quantile_shift_index")

  expect_true(all(target %in% ids))
})

test_that("extended_valindex registry id is present", {
  expect_true("extended_valindex" %in% list_metrics()$id)
})

test_that("skewness_error matches adjusted Fisher-Pearson skewness error", {
  sim <- c(1, 2, 3, 4, 8, 9, 10, 11)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  expected <- abs(.test_c1_adjusted_skewness(sim) - .test_c1_adjusted_skewness(obs))

  expect_equal(skewness_error(sim, obs), expected)
  expect_equal(metric_skewness_error(sim, obs), expected)
})

test_that("skewness_error is zero on identical series and positive on shape changes", {
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  sim <- c(1, 1, 2, 3, 5, 8, 13, 21)

  expect_equal(skewness_error(obs, obs), 0)
  expect_gt(skewness_error(sim, obs), 0)
})

test_that("skewness_error rejects too-short and zero-variance inputs", {
  expect_error(
    skewness_error(c(1, 2), c(1, 2)),
    "requires at least 3 values"
  )
  expect_error(
    skewness_error(c(1, 1, 1, 1), c(1, 2, 3, 4)),
    "sim has zero variance"
  )
})

test_that("kurtosis_error matches adjusted excess kurtosis error", {
  sim <- c(1, 2, 3, 4, 8, 9, 10, 11)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  expected <- abs(.test_c1_adjusted_excess_kurtosis(sim) - .test_c1_adjusted_excess_kurtosis(obs))

  expect_equal(kurtosis_error(sim, obs), expected)
  expect_equal(metric_kurtosis_error(sim, obs), expected)
})

test_that("kurtosis_error is zero on identical series and positive on shape changes", {
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  sim <- c(1, 1, 2, 3, 5, 8, 13, 21)

  expect_equal(kurtosis_error(obs, obs), 0)
  expect_gt(kurtosis_error(sim, obs), 0)
})

test_that("kurtosis_error rejects too-short and zero-variance inputs", {
  expect_error(
    kurtosis_error(c(1, 2, 3), c(1, 2, 3)),
    "requires at least 4 values"
  )
  expect_error(
    kurtosis_error(c(1, 2, 3, 4), c(1, 1, 1, 1)),
    "obs has zero variance"
  )
})

test_that("layer C wrappers integrate with gof and extended deterministic visibility", {
  sim <- c(1, 2, 3, 4, 8, 9, 10, 11, 5, 4, 3, 2)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 10, 6, 5, 4, 3)

  out <- gof(
    sim,
    obs,
    methods = c(
      "skewness_error",
      "kurtosis_error",
      "entropy_diff",
      "mutual_information_score",
      "mutual_information",
      "normalised_mi",
      "tail_dependence_score",
      "extreme_event_ratio",
      "rank_turnover_score",
      "distribution_overlap",
      "quantile_shift_index",
      "extended_valindex"
    )
  )
  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(
    names(out),
    c(
      "skewness_error",
      "kurtosis_error",
      "entropy_diff",
      "mutual_information_score",
      "mutual_information",
      "normalised_mi",
      "tail_dependence_score",
      "extreme_event_ratio",
      "rank_turnover_score",
      "distribution_overlap",
      "quantile_shift_index",
      "extended_valindex"
    )
  )

  out_ext <- gof(sim, obs, extended = TRUE)
  expect_true(
    all(
      c(
        "skewness_error",
        "kurtosis_error",
        "entropy_diff",
        "mutual_information_score",
        "mutual_information",
        "normalised_mi",
        "tail_dependence_score",
        "extreme_event_ratio",
        "rank_turnover_score",
        "distribution_overlap",
        "quantile_shift_index",
        "extended_valindex"
      ) %in% names(out_ext)
    )
  )
})

test_that("entropy_diff matches manual pooled-grid Shannon entropy difference", {
  sim <- c(1, 2, 2, 3, 4, 5, 5, 6, 7, 8)
  obs <- c(1, 1, 2, 3, 3, 4, 5, 6, 7, 9)
  breaks <- .test_c2_pooled_breaks(sim, obs)
  expected <- abs(.test_c2_entropy(sim, breaks) - .test_c2_entropy(obs, breaks))

  expect_equal(entropy_diff(sim, obs), expected)
  expect_equal(metric_entropy_diff(sim, obs), expected)
})

test_that("entropy_diff is zero on identical series and handles constant series", {
  const <- c(1, 1, 1, 1, 1, 1)
  var <- c(1, 2, 3, 4, 5, 6)
  breaks <- .test_c2_pooled_breaks(const, var)

  expect_equal(entropy_diff(var, var), 0)
  expect_equal(entropy_diff(const, const), 0)
  expect_equal(entropy_diff(const, var), abs(0 - .test_c2_entropy(var, breaks)))
  expect_error(entropy_diff(1, 1), "requires at least 2 values")
})

test_that("mutual_information_score matches manual pooled-grid mutual information", {
  sim <- c(1, 2, 2, 3, 4, 5, 5, 6, 7, 8)
  obs <- c(1, 1, 2, 3, 3, 4, 5, 6, 7, 9)
  breaks <- .test_c2_pooled_breaks(sim, obs)
  expected <- .test_c2_mutual_information(sim, obs, breaks)

  expect_equal(mutual_information_score(sim, obs), expected)
  expect_equal(metric_mutual_information_score(sim, obs), expected)
})

test_that("mutual_information is the canonical equivalent of mutual_information_score", {
  sim <- c(1, 2, 2, 3, 4, 5, 5, 6, 7, 8)
  obs <- c(1, 1, 2, 3, 3, 4, 5, 6, 7, 9)
  breaks <- .test_c2_pooled_breaks(sim, obs)
  expected <- .test_c2_mutual_information(sim, obs, breaks)

  expect_equal(mutual_information(sim, obs), expected)
  expect_equal(metric_mutual_information(sim, obs), expected)
  expect_equal(mutual_information(sim, obs), mutual_information_score(sim, obs))
})

test_that("mutual_information_score handles constant inputs and rejects too-short inputs", {
  const <- c(1, 1, 1, 1, 1, 1)
  var <- c(1, 2, 3, 4, 5, 6)
  paired <- c(1, 2, 2, 3, 4, 5)

  expect_equal(mutual_information_score(const, var), 0)
  expect_gt(mutual_information_score(paired, paired), 0)
  expect_error(
    mutual_information_score(c(1, 2), c(1, 2)),
    "requires at least 3 values"
  )
})

test_that("normalised_mi uses MI / sqrt(H_sim * H_obs) and rejects zero-entropy cases", {
  sim <- c(1, 2, 2, 3, 4, 5, 5, 6, 7, 8)
  obs <- c(1, 1, 2, 3, 3, 4, 5, 6, 7, 9)
  breaks <- .test_c2_pooled_breaks(sim, obs)
  mi <- .test_c2_mutual_information(sim, obs, breaks)
  h_sim <- .test_c2_entropy(sim, breaks)
  h_obs <- .test_c2_entropy(obs, breaks)
  expected <- mi / sqrt(h_sim * h_obs)

  expect_equal(normalised_mi(sim, obs), expected)
  expect_equal(metric_normalised_mi(sim, obs), expected)
  expect_gte(normalised_mi(sim, obs), 0)
  expect_lte(normalised_mi(sim, obs), 1)

  const <- c(1, 1, 1, 1, 1, 1)
  expect_error(
    normalised_mi(const, const),
    "both marginal entropies must be positive"
  )
})

test_that("tail_dependence_score matches empirical observed-threshold conditional exceedance", {
  sim <- c(1, 2, 3, 7, 8, 4, 3, 2, 6, 7, 3, 2)
  obs <- c(1, 2, 4, 8, 7, 5, 3, 2, 5, 8, 4, 2)
  threshold <- .test_c3_tail_threshold(obs)
  obs_exceed <- obs > threshold
  expected <- mean(sim[obs_exceed] > threshold)

  expect_equal(tail_dependence_score(sim, obs), expected)
  expect_equal(metric_tail_dependence_score(sim, obs), expected)
})

test_that("tail_dependence_score handles identical, absent simulated, and no-observed-exceedance cases", {
  paired <- c(1, 2, 3, 7, 8, 4, 3, 2, 6, 7, 3, 2)
  const <- c(1, 1, 1, 1, 1, 1)
  var <- c(1, 2, 3, 4, 5, 6)

  expect_equal(tail_dependence_score(paired, paired), 1)
  expect_equal(tail_dependence_score(const, var), 0)
  expect_error(
    tail_dependence_score(const, const),
    "obs contains no exceedances above the observed 0.9 quantile threshold"
  )
})

test_that("extreme_event_ratio matches observed-threshold contiguous event-count ratio", {
  sim <- c(1, 2, 3, 7, 2, 1, 1, 6, 2, 1, 1, 7)
  obs <- c(1, 2, 4, 8, 2, 1, 1, 5, 2, 1, 1, 8)
  threshold <- .test_c3_tail_threshold(obs)
  expected <- .test_c3_event_count(sim, threshold) / .test_c3_event_count(obs, threshold)

  expect_equal(extreme_event_ratio(sim, obs), expected)
  expect_equal(metric_extreme_event_ratio(sim, obs), expected)
})

test_that("extreme_event_ratio handles identical, zero-sim-event, and no-observed-event cases", {
  obs <- c(1, 2, 4, 8, 2, 1, 1, 5, 2, 1, 1, 8)
  threshold <- .test_c3_tail_threshold(obs)
  sim_none <- c(1, 2, 3, 4, 2, 1, 1, 3, 2, 1, 1, 3)
  const <- c(1, 1, 1, 1, 1, 1)

  expect_equal(extreme_event_ratio(obs, obs), 1)
  expect_equal(extreme_event_ratio(sim_none, obs), 0)
  expect_equal(.test_c3_event_count(obs, threshold), 2L)
  expect_error(
    extreme_event_ratio(const, const),
    "obs contains no events above the observed 0.9 quantile threshold"
  )
})

test_that("gof extended excludes threshold-gated C3 metrics when observed tails are absent", {
  sim <- c(1, 2, 2, 2, 2, 2)
  obs <- c(1, 1, 1, 1, 2, 2)

  out_ext <- gof(sim, obs, extended = TRUE)

  expect_false("tail_dependence_score" %in% names(out_ext))
  expect_false("extreme_event_ratio" %in% names(out_ext))
})

test_that("rank_turnover_score matches normalized average-rank turnover", {
  sim <- c(1, 4, 2, 8, 5, 7, 3, 6)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  expected <- .test_c4_rank_turnover(sim, obs)

  expect_equal(rank_turnover_score(sim, obs), expected)
  expect_equal(metric_rank_turnover_score(sim, obs), expected)
})

test_that("rank_turnover_score is zero for identical rankings and positive for reorderings", {
  const <- c(1, 1, 1, 1, 1, 1)
  inc <- c(1, 2, 3, 4, 5, 6)
  rev_inc <- rev(inc)

  expect_equal(rank_turnover_score(inc, inc), 0)
  expect_equal(rank_turnover_score(const, const), 0)
  expect_gt(rank_turnover_score(rev_inc, inc), 0)
  expect_error(rank_turnover_score(1, 1), "requires at least 2 values")
})

test_that("distribution_overlap matches pooled-grid overlap coefficient", {
  sim <- c(1, 4, 2, 8, 5, 7, 3, 6)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  expected <- .test_c4_distribution_overlap(sim, obs)

  expect_equal(distribution_overlap(sim, obs), expected)
  expect_equal(metric_distribution_overlap(sim, obs), expected)
})

test_that("distribution_overlap stays bounded and handles constant series deterministically", {
  const <- c(1, 1, 1, 1, 1, 1)
  inc <- c(1, 2, 3, 4, 5, 6)
  value <- distribution_overlap(const, inc)

  expect_equal(distribution_overlap(inc, inc), 1)
  expect_equal(distribution_overlap(const, const), 1)
  expect_gte(value, 0)
  expect_lte(value, 1)
  expect_error(distribution_overlap(1, 1), "requires at least 2 values")
})

test_that("quantile_shift_index matches fixed-grid type-7 quantile shift scaling", {
  sim <- c(1, 4, 2, 8, 5, 7, 3, 6)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  expected <- .test_c4_quantile_shift_index(sim, obs)

  expect_equal(quantile_shift_index(sim, obs), expected)
  expect_equal(metric_quantile_shift_index(sim, obs), expected)
})

test_that("quantile_shift_index is zero on identical series and rejects zero observed IQR", {
  inc <- c(1, 2, 3, 4, 5, 6)
  const <- c(1, 1, 1, 1, 1, 1)

  expect_equal(quantile_shift_index(inc, inc), 0)
  expect_error(
    quantile_shift_index(inc, const),
    "IQR\\(obs\\) == 0"
  )
})

test_that("auto-applicability excludes C4 quantile-shift metric when observed IQR is zero", {
  sim <- c(1, 2, 2, 2, 2, 2)
  obs <- c(1, 1, 1, 1, 1, 2)
  ids <- .gof_auto_applicable_ids(list_metrics()$id, sim = sim, obs = obs)

  expect_false("quantile_shift_index" %in% ids)
  expect_true("rank_turnover_score" %in% ids)
  expect_true("distribution_overlap" %in% ids)
})

test_that("gof extended remains robust on constant observed series while excluding zero-IQR-sensitive metrics", {
  sim <- c(1, 2, 3, 4, 5, 6)
  obs <- c(1, 1, 1, 1, 1, 1)

  out_ext <- gof(sim, obs, extended = TRUE)

  expect_true(inherits(out_ext, "hydro_metrics"))
  expect_false("quantile_shift_index" %in% names(out_ext))
  expect_false(any(c("alpha", "kge", "r2", "rsr") %in% names(out_ext)))
  expect_true("distribution_overlap" %in% names(out_ext))
})
