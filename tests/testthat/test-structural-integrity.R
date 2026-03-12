.struct_namespace <- local({
  .find_pkg_root <- function(path = getwd()) {
    path <- normalizePath(path, winslash = "/", mustWork = TRUE)

    repeat {
      if (file.exists(file.path(path, "DESCRIPTION"))) {
        return(path)
      }

      parent <- dirname(path)
      if (identical(parent, path)) {
        stop("Could not locate package root for structural integrity tests.")
      }
      path <- parent
    }
  }

  if (exists("list_metrics", mode = "function")) {
    return(function() asNamespace("hydroMetrics"))
  }

  ns <- new.env(parent = baseenv())
  r_dir <- file.path(.find_pkg_root(), "R")
  r_files <- sort(list.files(r_dir, pattern = "[.][Rr]$", full.names = TRUE))
  for (path in r_files) {
    sys.source(path, envir = ns)
  }

  function() ns
})

test_that("no duplicate metric function definitions remain", {
  ns <- .struct_namespace()
  metric_names <- ls(envir = ns, pattern = "^metric_[A-Za-z0-9_]+$")
  expect_identical(length(metric_names), length(unique(metric_names)))
})

test_that("canonical metric tree contains no NA-handling logic tokens", {
  ns <- .struct_namespace()
  metric_names <- ls(envir = ns, pattern = "^metric_[A-Za-z0-9_]+$")
  metric_bodies <- vapply(metric_names, function(name) {
    paste(deparse(body(get(name, envir = ns))), collapse = "\n")
  }, character(1))
  hits <- grep("na\\.rm|complete\\.cases|is\\.na\\(", metric_bodies, value = TRUE, perl = TRUE)
  expect_length(hits, 0L)
})

.struct_fixture_for_metric <- function(id) {
  if (identical(id, "skge")) {
    obs <- stats::ts(c(1:12, 2:13), start = c(2000, 1), frequency = 12)
    sim <- obs
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "apfb")) {
    idx <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
    sim <- c(12, 18, 33, 35)
    obs <- c(10, 20, 30, 40)
    return(list(sim = sim, obs = obs, params = list(index = idx)))
  }

  if (identical(id, "seasonal_bias")) {
    obs <- stats::ts(c(1:12, 2:13), start = c(2000, 1), frequency = 12)
    sim <- obs + 0.5
    return(list(sim = as.numeric(sim), obs = as.numeric(obs), params = list(index = stats::time(obs))))
  }

  if (identical(id, "seasonal_nse")) {
    obs <- stats::ts(c(1:12, 2:13), start = c(2000, 1), frequency = 12)
    sim <- obs + c(rep(0.5, 12), rep(-0.5, 12))
    return(list(sim = as.numeric(sim), obs = as.numeric(obs), params = list(index = stats::time(obs))))
  }

  if (identical(id, "derivative_nse")) {
    sim <- c(1, 2, 4, 7)
    obs <- c(1, 2, 3, 5)
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "recession_constant")) {
    sim <- c(1, 2, 5, 4, 3, 2)
    obs <- c(1, 2, 6, 5, 4, 3)
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "crps")) {
    sim <- matrix(c(1, 1.2, 0.8, 2, 2.2, 1.8), nrow = 2, byrow = TRUE)
    obs <- c(1.1, 2.1)
    return(list(sim = sim, obs = obs, params = list()))
  }

  if (identical(id, "picp")) {
    return(list(
      sim = c(0.9, 1.9),
      obs = c(1.1, 2.1),
      params = list(upper = c(1.3, 2.3))
    ))
  }

  if (identical(id, "mwpi")) {
    return(list(sim = c(0.9, 1.9), obs = c(1.3, 2.3), params = list()))
  }

  if (identical(id, "skill_score")) {
    return(list(sim = c(0.8, 0.7), obs = c(1.0, 1.0), params = list()))
  }

  if (identical(id, "hfb")) {
    obs <- 1:30
    sim <- obs + 1
    return(list(sim = sim, obs = obs, params = list(threshold_prob = 0.9)))
  }

  list(
    sim = c(1, 2, 3, 4),
    obs = c(1, 2, 3, 4),
    params = list()
  )
}

test_that("every registered metric has a callable implementation", {
  ns <- .struct_namespace()
  ids <- as.character(get("list_metrics", envir = ns)()$id)

  for (id in ids) {
    spec <- get("get_metric", envir = ns)(id)
    expect_true(is.function(spec$fun), info = sprintf("metric '%s' is not callable", id))

    fixture <- .struct_fixture_for_metric(id)
    value <- do.call(spec$fun, c(list(fixture$sim, fixture$obs), fixture$params))

    expect_true(is.numeric(value), info = sprintf("metric '%s' returned non-numeric", id))
    expect_identical(length(value), 1L, info = sprintf("metric '%s' returned non-scalar", id))
    expect_true(is.finite(as.numeric(value)), info = sprintf("metric '%s' returned non-finite", id))
  }
})
