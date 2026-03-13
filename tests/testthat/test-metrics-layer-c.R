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

test_that("layer C batch C1 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("skewness_error", "kurtosis_error", "iqr_error")

  expect_true(all(target %in% ids))
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

test_that("iqr_error matches manual type-7 IQR error", {
  sim <- c(1, 2, 3, 4, 8, 9, 10, 11)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  expected <- abs(.test_c1_type7_iqr(sim) - .test_c1_type7_iqr(obs))

  expect_equal(iqr_error(sim, obs), expected)
  expect_equal(metric_iqr_error(sim, obs), expected)
})

test_that("iqr_error is zero on identical series and nonzero on spread changes", {
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)
  sim <- c(1, 1, 2, 3, 5, 8, 13, 21)

  expect_equal(iqr_error(obs, obs), 0)
  expect_gt(iqr_error(sim, obs), 0)
})

test_that("iqr_error allows constant series but rejects too-short inputs", {
  expect_equal(
    iqr_error(c(1, 1, 1, 1), c(1, 2, 3, 4)),
    abs(0 - .test_c1_type7_iqr(c(1, 2, 3, 4)))
  )
  expect_error(
    iqr_error(1, 1),
    "requires at least 2 values"
  )
})

test_that("layer C wrappers integrate with gof and extended deterministic visibility", {
  sim <- c(1, 2, 3, 4, 8, 9, 10, 11)
  obs <- c(1, 2, 3, 4, 5, 6, 7, 8)

  out <- gof(sim, obs, methods = c("skewness_error", "kurtosis_error", "iqr_error"))
  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(names(out), c("skewness_error", "kurtosis_error", "iqr_error"))

  out_ext <- gof(sim, obs, extended = TRUE)
  expect_true(all(c("skewness_error", "kurtosis_error", "iqr_error") %in% names(out_ext)))
})
