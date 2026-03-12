if (!exists("gof", mode = "function")) {
  find_pkg_root <- function(path = getwd()) {
    current <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(current, "DESCRIPTION"))) {
        return(current)
      }

      parent <- dirname(current)
      if (identical(parent, current)) {
        stop("Could not locate package root for standalone Layer A tests.", call. = FALSE)
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

test_that("layer A batch A1 registry ids are present", {
  ids <- list_metrics()$id
  target <- c("mdae", "maxae", "rbias", "ccc", "e1", "rrmse")

  expect_true(all(target %in% ids))
})

test_that("mdae and maxae match absolute-error summaries", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  abs_err <- abs(sim - obs)

  expect_equal(mdae(sim, obs), stats::median(abs_err))
  expect_equal(maxae(sim, obs), max(abs_err))

  out <- evaluate_metrics(sim, obs, c("mdae", "maxae"))
  values <- setNames(out$value, out$metric)
  expect_equal(values[["mdae"]], stats::median(abs_err))
  expect_equal(values[["maxae"]], max(abs_err))
})

test_that("mdae and maxae require at least one paired value", {
  expect_error(mdae(numeric(), numeric()), "At least 1 paired value is required after alignment")
  expect_error(maxae(numeric(), numeric()), "At least 1 paired value is required after alignment")
})

test_that("rbias matches mean paired relative bias", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- mean((sim - obs) / obs)

  expect_equal(rbias(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "rbias")$value[[1]], expected)
})

test_that("rbias errors when observed values contain zero", {
  expect_error(
    rbias(c(1, 2, 3), c(1, 0, 3)),
    "obs contains zero"
  )
})

test_that("ccc matches Lin concordance formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- (2 * stats::cov(sim, obs)) /
    (stats::var(sim) + stats::var(obs) + (mean(sim) - mean(obs))^2)

  expect_equal(ccc(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "ccc")$value[[1]], expected)
})

test_that("ccc handles constant identical series and short inputs deterministically", {
  expect_equal(ccc(c(2, 2), c(2, 2)), 1)
  expect_error(ccc(1, 1), "at least 2 values")
})

test_that("e1 matches Legates-McCabe absolute-efficiency formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- 1 - sum(abs(sim - obs)) / sum(abs(obs - mean(obs)))

  expect_equal(e1(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "e1")$value[[1]], expected)
})

test_that("e1 errors when the observed baseline denominator is zero", {
  expect_error(
    e1(c(1, 2, 3), c(2, 2, 2)),
    "sum\\(abs\\(obs - mean\\(obs\\)\\)\\) == 0"
  )
})

test_that("rrmse matches root mean squared relative error", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- sqrt(mean(((sim - obs) / obs)^2))

  expect_equal(rrmse(sim, obs), expected)
  expect_equal(evaluate_metrics(sim, obs, "rrmse")$value[[1]], expected)
})

test_that("rrmse errors when observed values contain zero", {
  expect_error(
    rrmse(c(1, 2, 3), c(1, 0, 3)),
    "obs contains zero"
  )
})

test_that("layer A wrappers integrate with gof output", {
  sim <- cbind(a = c(1.2, 1.8, 3.4, 3.9, 5.1), b = c(1.0, 2.1, 2.9, 4.2, 5.0))
  obs <- cbind(a = c(1.0, 2.0, 3.0, 4.0, 5.0), b = c(1.0, 2.0, 3.0, 4.0, 5.0))

  out <- gof(sim, obs, methods = c("mdae", "ccc", "rrmse"))
  expect_true(is.matrix(out))
  expect_true(inherits(out, "hydro_metrics"))
  expect_identical(rownames(out), c("mdae", "ccc", "rrmse"))
  expect_identical(colnames(out), c("a", "b"))
})
