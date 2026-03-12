if (!exists("gof", mode = "function")) {
  find_pkg_root <- function(path = getwd()) {
    current <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(current, "DESCRIPTION"))) {
        return(current)
      }

      parent <- dirname(current)
      if (identical(parent, current)) {
        stop("Could not locate package root for standalone Layer B tests.", call. = FALSE)
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

.test_b1_union_support <- function(sim, obs) {
  sort(unique(c(sim, obs)))
}

test_that("layer B batch B1 registry ids are present", {
  ids <- list_metrics()$id
  target <- c(
    "ks_statistic",
    "cdf_rmse",
    "quantile_deviation",
    "fdc_shape_distance",
    "anderson_darling_stat",
    "wasserstein_distance"
  )

  expect_true(all(target %in% ids))
})

test_that("ks_statistic matches the two-sample empirical KS gap", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  grid <- .test_b1_union_support(sim, obs)
  expected <- max(abs(stats::ecdf(sim)(grid) - stats::ecdf(obs)(grid)))

  expect_equal(ks_statistic(sim, obs), expected)
  expect_equal(metric_ks_statistic(sim, obs), expected)
  expect_equal(ks_statistic(sim, obs), as.numeric(stats::ks.test(sim, obs)$statistic))
})

test_that("cdf_rmse matches pooled-support empirical CDF RMSE", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  grid <- .test_b1_union_support(sim, obs)
  expected <- sqrt(mean((stats::ecdf(sim)(grid) - stats::ecdf(obs)(grid))^2))

  expect_equal(cdf_rmse(sim, obs), expected)
  expect_equal(metric_cdf_rmse(sim, obs), expected)
})

test_that("quantile_deviation matches fixed-grid quantile RMSE", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1, 2, 4, 5, 6)
  probs <- seq(0.1, 0.9, by = 0.1)
  expected <- sqrt(mean((
    stats::quantile(sim, probs = probs, type = 7, names = FALSE) -
      stats::quantile(obs, probs = probs, type = 7, names = FALSE)
  )^2))

  expect_equal(quantile_deviation(sim, obs), expected)
  expect_equal(metric_quantile_deviation(sim, obs), expected)
})

test_that("fdc_shape_distance matches range-normalized descending FDC RMSE", {
  sim <- c(1, 2, 4, 6, 8)
  obs <- c(2, 3, 5, 7, 9)
  sim_norm <- (sort(sim, decreasing = TRUE) - min(sim)) / diff(range(sim))
  obs_norm <- (sort(obs, decreasing = TRUE) - min(obs)) / diff(range(obs))
  expected <- sqrt(mean((sim_norm - obs_norm)^2))

  expect_equal(fdc_shape_distance(sim, obs), expected)
  expect_equal(metric_fdc_shape_distance(sim, obs), expected)
})

test_that("anderson_darling_stat matches pooled-grid tail-weighted EDF distance", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  grid <- .test_b1_union_support(sim, obs)
  sim_cdf <- stats::ecdf(sim)(grid)
  obs_cdf <- stats::ecdf(obs)(grid)
  pooled_counts <- vapply(grid, function(value) {
    sum(sim == value) + sum(obs == value)
  }, numeric(1))
  dH <- pooled_counts / (length(sim) + length(obs))
  H <- (length(sim) * sim_cdf + length(obs) * obs_cdf) / (length(sim) + length(obs))
  valid <- H > 0 & H < 1
  expected <- sum(((sim_cdf[valid] - obs_cdf[valid])^2 / (H[valid] * (1 - H[valid]))) * dH[valid])

  expect_equal(anderson_darling_stat(sim, obs), expected)
  expect_equal(metric_anderson_darling_stat(sim, obs), expected)
})

test_that("wasserstein_distance matches equal-weight quantile coupling", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 4, 5)
  expected <- mean(abs(sort(sim) - sort(obs)))

  expect_equal(wasserstein_distance(sim, obs), expected)
  expect_equal(metric_wasserstein_distance(sim, obs), expected)
})

test_that("layer B metrics return zero on identical samples where appropriate", {
  same <- c(2, 2, 2, 2, 2)

  expect_equal(ks_statistic(same, same), 0)
  expect_equal(cdf_rmse(same, same), 0)
  expect_equal(quantile_deviation(same, same), 0)
  expect_equal(anderson_darling_stat(same, same), 0)
  expect_equal(wasserstein_distance(same, same), 0)
})

test_that("fdc_shape_distance rejects zero-range series conservatively", {
  same <- c(2, 2, 2, 2, 2)

  expect_error(
    fdc_shape_distance(same, same),
    "range\\(sim\\) == 0"
  )
})

test_that("layer B wrappers integrate with gof for deterministic metrics", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1, 6.0, 7.2, 8.1, 9.3, 10.0)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.2, 7.0, 8.0, 9.0, 10.1)
  out <- gof(
    sim,
    obs,
    methods = c(
      "ks_statistic",
      "cdf_rmse",
      "quantile_deviation",
      "fdc_shape_distance",
      "anderson_darling_stat",
      "wasserstein_distance"
    )
  )

  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(
    names(out),
    c(
      "ks_statistic",
      "cdf_rmse",
      "quantile_deviation",
      "fdc_shape_distance",
      "anderson_darling_stat",
      "wasserstein_distance"
    )
  )
})

test_that("layer B metrics detect simple distribution shifts monotonically", {
  base <- c(1, 2, 3, 4, 5)
  shifted <- base + 1

  expect_gt(ks_statistic(base, shifted), 0)
  expect_gt(cdf_rmse(base, shifted), 0)
  expect_gt(quantile_deviation(base, shifted), 0)
  expect_gt(anderson_darling_stat(base, shifted), 0)
  expect_gt(wasserstein_distance(base, shifted), 0)
})
