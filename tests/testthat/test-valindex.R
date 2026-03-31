if (!exists("gof", mode = "function")) {
  find_pkg_root <- function(path = getwd()) {
    current <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(current, "DESCRIPTION"))) {
        return(current)
      }

      parent <- dirname(current)
      if (identical(parent, current)) {
        stop("Could not locate package root for standalone valindex tests.", call. = FALSE)
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

.test_extended_valindex_expected <- function(sim, obs) {
  raw <- valindex(
    sim,
    obs,
    fun = c("nse", "kge", "rmse", "pbias", "r", "mae", "rsr", "ve")
  )
  values <- stats::setNames(as.numeric(raw), names(raw))
  obs_scale <- mean(abs(obs))

  mean(c(
    nse = 1 / (1 + abs(1 - values[["nse"]])),
    kge = 1 / (1 + abs(1 - values[["kge"]])),
    rmse = 1 / (1 + (values[["rmse"]] / obs_scale)),
    pbias = 1 / (1 + (abs(values[["pbias"]]) / 100)),
    r = (values[["r"]] + 1) / 2,
    mae = 1 / (1 + (values[["mae"]] / obs_scale)),
    rsr = 1 / (1 + values[["rsr"]]),
    ve = 1 / (1 + abs(1 - values[["ve"]]))
  ))
}

test_that("valindex is a thin wrapper over gof(methods = fun)", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)

  out <- valindex(sim, obs, fun = c("NSE", "rmse"))
  ref <- gof(sim, obs, methods = c("NSE", "rmse"))

  expect_s3_class(out, "hydro_metrics")
  expect_equal(as.numeric(out), as.numeric(ref))
  expect_identical(names(out), names(ref))
  expect_identical(attr(out, "n_obs"), attr(ref, "n_obs"))
  expect_equal(attr(out, "meta"), attr(ref, "meta"))
  expect_equal(as.numeric(out), as.numeric(ref))
})

test_that("valindex supports multi-series inputs through gof", {
  sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs <- cbind(a = c(1, 2, 1), b = c(2, 2, 3))

  out <- valindex(sim, obs, fun = c("rmse", "pbias"))

  expect_s3_class(out, "hydro_metrics")
  expect_true(is.matrix(out))
  expect_identical(rownames(out), c("rmse", "pbias"))
})

test_that("valindex errors when fun is missing", {
  expect_error(
    valindex(c(1, 2, 3), c(1, 2, 1)),
    "`fun` must be provided"
  )
})

test_that("composite_performance_index matches the fixed normalized composite of valindex-style components", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  expected <- .test_extended_valindex_expected(sim, obs)

  expect_equal(composite_performance_index(sim, obs), expected)
  expect_equal(metric_extended_valindex(sim, obs), expected)
  expect_warning(
    expect_equal(extended_valindex(sim, obs), expected),
    "deprecated"
  )
})

test_that("composite_performance_index gives a better score to a better simulation and peaks at one", {
  obs <- c(1, 2, 3, 4, 5)
  sim_good <- c(1.0, 2.1, 2.9, 4.0, 5.1)
  sim_bad <- c(2, 3, 4, 5, 6)

  expect_equal(composite_performance_index(obs, obs), 1)
  expect_gt(composite_performance_index(sim_good, obs), composite_performance_index(sim_bad, obs))
})

test_that("composite_performance_index stays related to the base valindex component bundle", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  raw <- valindex(sim, obs, fun = c("nse", "kge", "rmse", "pbias", "r", "mae", "rsr", "ve"))

  expect_s3_class(raw, "hydro_metrics")
  expect_identical(names(raw), c("nse", "kge", "rmse", "pbias", "r", "mae", "rsr", "ve"))
  expect_equal(composite_performance_index(sim, obs), .test_extended_valindex_expected(sim, obs))
})

test_that("composite_performance_index rejects undefined observed-scale and component states", {
  expect_error(
    composite_performance_index(c(1, 2, 3, 4, 5), c(0, 0, 0, 0, 0)),
    "mean\\(abs\\(obs\\)\\) must be positive"
  )
})
