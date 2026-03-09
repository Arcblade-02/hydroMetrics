test_that("no duplicate metric function definitions remain", {
  ns <- asNamespace("hydroMetrics")
  metric_names <- ls(envir = ns, pattern = "^metric_[A-Za-z0-9_]+$")
  expect_identical(length(metric_names), length(unique(metric_names)))
})

test_that("canonical metric tree contains no NA-handling logic tokens", {
  ns <- asNamespace("hydroMetrics")
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
  ids <- as.character(list_metrics()$id)

  for (id in ids) {
    spec <- get_metric(id)
    expect_true(is.function(spec$fun), info = sprintf("metric '%s' is not callable", id))

    fixture <- .struct_fixture_for_metric(id)
    value <- do.call(spec$fun, c(list(fixture$sim, fixture$obs), fixture$params))

    expect_true(is.numeric(value), info = sprintf("metric '%s' returned non-numeric", id))
    expect_identical(length(value), 1L, info = sprintf("metric '%s' returned non-scalar", id))
    expect_true(is.finite(as.numeric(value)), info = sprintf("metric '%s' returned non-finite", id))
  }
})
