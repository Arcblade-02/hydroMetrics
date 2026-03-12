.hm_test_env <- if ("package:hydroMetrics" %in% search()) {
  asNamespace("hydroMetrics")
} else {
  env <- new.env(parent = globalenv())
  root <- if (dir.exists("R")) {
    "."
  } else if (dir.exists(file.path("..", "..", "R"))) {
    file.path("..", "..")
  } else {
    stop("Could not locate package root for standalone pre-phase3 tests.", call. = FALSE)
  }
  r_files <- sort(list.files(file.path(root, "R"), pattern = "[.][Rr]$", full.names = TRUE))
  for (path in r_files) {
    sys.source(path, envir = env)
  }
  env
}

.hm_get <- function(name) {
  get(name, envir = .hm_test_env, inherits = FALSE)
}

test_that("skge supports numeric vectors via non-seasonal fallback", {
  sim <- c(1:12, 2:13)
  obs <- c(1:12, 2:13)
  sim_ts <- stats::ts(sim, start = c(2000, 1), frequency = 12)
  obs_ts <- stats::ts(obs, start = c(2000, 1), frequency = 12)

  expect_no_error(out_numeric <- .hm_get("skge")(sim, obs))
  expect_equal(out_numeric, 1)
  expect_equal(out_numeric, .hm_get("skge")(sim_ts, obs_ts), tolerance = 1e-12)
})

test_that("skge supports monthly zoo inputs with deterministic alignment", {
  skip_if_not_installed("zoo")

  idx <- seq.Date(as.Date("2000-01-01"), by = "month", length.out = 24)
  obs_zoo <- zoo::zoo(c(1:12, 2:13), idx)
  sim_zoo <- obs_zoo
  obs_ts <- stats::ts(c(1:12, 2:13), start = c(2000, 1), frequency = 12)
  sim_ts <- obs_ts

  expect_no_error(out_zoo <- .hm_get("skge")(sim_zoo, obs_zoo))
  expect_equal(out_zoo, .hm_get("skge")(sim_ts, obs_ts), tolerance = 1e-12)
  expect_equal(out_zoo, 1)
})

test_that("skge preserves existing monthly ts behavior", {
  obs_ts <- stats::ts(c(1:12, 2:13), start = c(2000, 1), frequency = 12)
  sim_ts <- obs_ts

  expect_equal(.hm_get("metric_skge")(sim_ts, obs_ts), 1)
  expect_equal(.hm_get("skge")(sim_ts, obs_ts), 1)
})
