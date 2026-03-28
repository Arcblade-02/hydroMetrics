.hm_gof_test_env <- if ("package:hydroMetrics" %in% search()) {
  asNamespace("hydroMetrics")
} else {
  env <- new.env(parent = globalenv())
  root <- if (dir.exists("R")) {
    "."
  } else if (dir.exists(file.path("..", "..", "R"))) {
    file.path("..", "..")
  } else {
    stop("Could not locate package root for standalone gof tests.", call. = FALSE)
  }
  r_files <- sort(list.files(file.path(root, "R"), pattern = "[.][Rr]$", full.names = TRUE))
  for (path in r_files) {
    sys.source(path, envir = env)
  }
  env
}

.hm_gof_get <- function(name) {
  get(name, envir = .hm_gof_test_env, inherits = FALSE)
}

.hm_gof_default_ids <- c(
  "me", "mae", "rmse", "ubrmse", "pbias", "rsr", "rsd", "nse", "r", "r2", "ve", "kge", "mnse", "cp",
  "alpha", "beta", "ccc",
  "mdae", "maxae", "smape",
  "log_nse", "log_rmse", "low_flow_bias", "fdc_lowflow_bias",
  "peak_timing_error", "extreme_event_ratio", "rising_limb_error",
  "fdc_shape_distance", "baseflow_index_error",
  "rspearman", "wasserstein_distance", "distribution_overlap"
)

test_that("gof defaults to the curated modern summary set", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  out <- .hm_gof_get("gof")(sim, obs)

  expect_s3_class(out, "hydro_metrics")
  expect_true(is.numeric(out))
  expect_true(is.null(dim(out)))
  expect_identical(names(out), .hm_gof_default_ids)
  expect_identical(length(out), length(.hm_gof_default_ids))
  expect_false(any(c("metrics", "n_obs", "meta", "call") %in% names(out)))
  expect_identical(attr(out, "n_obs"), 5L)
  expect_true(is.list(attr(out, "meta")))
  expect_true(is.call(attr(out, "call")))
})

test_that("gof extended = FALSE matches plain default behavior", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  out_default <- .hm_gof_get("gof")(sim, obs)
  out_explicit <- .hm_gof_get("gof")(sim, obs, extended = FALSE)

  expect_identical(names(out_explicit), names(out_default))
  expect_equal(as.numeric(out_explicit), as.numeric(out_default))
  expect_identical(attr(out_explicit, "n_obs"), attr(out_default, "n_obs"))
  expect_equal(attr(out_explicit, "meta"), attr(out_default, "meta"))
})

test_that("gof extended = TRUE returns all auto-applicable registered metrics", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  payload <- .hm_gof_get("preproc")(sim = sim, obs = obs)
  registered_ids <- .hm_gof_get(".gof_auto_applicable_ids")(
    available_ids = as.character(.hm_gof_get("list_metrics")()$id),
    sim = payload$sim,
    obs = payload$obs,
    index = payload$index
  )

  out <- .hm_gof_get("gof")(sim, obs, extended = TRUE)

  expect_true(is.numeric(out))
  expect_true(is.null(dim(out)))
  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(out), registered_ids)
  expect_true(length(out) >= length(.hm_gof_default_ids))
  expect_true(all(.hm_gof_default_ids %in% names(out)))
})

test_that("gof explicit methods override default and extended selection", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  out <- .hm_gof_get("gof")(sim, obs, methods = c("nse", "rmse"), extended = TRUE)

  expect_true(is.numeric(out))
  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(out), c("nse", "rmse"))
})

test_that("gof returns hydro_metrics object for single series", {
  out <- .hm_gof_get("gof")(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = c("NSE", "rmse", "rPearson")
  )

  expect_s3_class(out, "hydro_metrics")
  expect_true(is.numeric(out))
  expect_true(is.null(dim(out)))
  expect_true(all(c("NSE", "rmse", "rPearson") %in% names(out)))
})

test_that("gof canonicalizes deprecated orchestration aliases while preserving labels", {
  expect_no_warning(
    out <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = "rPearson"
    )
  )

  ref <- .hm_gof_get("gof")(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = "r")

  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(out), "rPearson")
  expect_equal(as.numeric(out), as.numeric(ref))
})

test_that("gof supports zoo alignment and method subsets", {
  skip_if_not_installed("zoo")

  sim <- zoo::zoo(c(1, 2, 3), order.by = as.Date("2020-01-01") + 0:2)
  obs <- zoo::zoo(c(1, 2, 4), order.by = as.Date("2020-01-02") + 0:2)

  out <- .hm_gof_get("gof")(sim = sim, obs = obs, methods = c("NSE", "rmse"), na_strategy = "fail")
  expect_equal(names(out), c("NSE", "rmse"))
  expect_identical(attr(out, "n_obs"), 2L)
})

test_that("gof accepts valid aligned zoo inputs without NA failure on common index", {
  skip_if_not_installed("zoo")

  sim <- zoo::zoo(
    c(5, 7, 9, 11),
    order.by = as.POSIXct(c(
      "2021-05-01 00:00:00",
      "2021-05-02 00:00:00",
      "2021-05-03 00:00:00",
      "2021-05-04 00:00:00"
    ), tz = "UTC")
  )
  obs <- zoo::zoo(
    c(4, 8, 10, 12),
    order.by = as.POSIXct(c(
      "2021-05-02 00:00:00",
      "2021-05-03 00:00:00",
      "2021-05-04 00:00:00",
      "2021-05-05 00:00:00"
    ), tz = "UTC")
  )

  expect_no_error(
    out <- .hm_gof_get("gof")(sim = sim, obs = obs, methods = c("rmse", "pbias"), na_strategy = "fail")
  )
  expect_identical(attr(out, "n_obs"), 3L)
  expect_identical(names(out), c("rmse", "pbias"))
})

test_that("gof returns method x model metrics matrix for multi-series input", {
  sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs <- cbind(a = c(1, 2, 1), b = c(2, 2, 3))

  out <- .hm_gof_get("gof")(sim = sim, obs = obs, methods = c("rmse", "pbias"))

  expect_true(is.matrix(out))
  expect_s3_class(out, "hydro_metrics")
  expect_identical(rownames(out), c("rmse", "pbias"))
  expect_identical(colnames(out), c("a", "b"))
  expect_equal(length(attr(out, "n_obs")), 2L)
})

test_that("gof preserves output contract for default multi-series output", {
  sim <- cbind(a = c(1, 2, 3, 4, 5), b = c(2, 3, 4, 5, 6))
  obs <- cbind(a = c(1.1, 1.9, 3.2, 3.8, 5.1), b = c(2.2, 2.8, 4.1, 5.2, 5.9))

  out <- .hm_gof_get("gof")(sim, obs)

  expect_s3_class(out, "hydro_metrics")
  expect_true(is.matrix(out))
  expect_identical(rownames(out), .hm_gof_default_ids)
  expect_identical(colnames(out), c("a", "b"))
  expect_null(names(out))
})

test_that("gof errors for unknown method names with available list hint", {
  expect_error(
    .hm_gof_get("gof")(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = "not_a_metric"),
    "available"
  )
})

test_that("gof stores orchestration meta fields", {
  out <- .hm_gof_get("gof")(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = "rmse",
    components = TRUE,
    na_strategy = "remove",
    transform = "none",
    epsilon_mode = "constant"
  )

  meta <- attr(out, "meta")

  expect_identical(meta$na_strategy, "remove")
  expect_identical(meta$transform, "none")
  expect_identical(meta$epsilon_mode, "constant")
  expect_identical(meta$components, TRUE)
})

test_that("gof stores single-series meta alignment fields", {
  out <- .hm_gof_get("gof")(
    sim = c(1, 2, 3, 4),
    obs = c(1, 2, 3, 4),
    methods = "rmse"
  )

  meta <- attr(out, "meta")

  expect_identical(meta$n_original, 4L)
  expect_identical(meta$n_aligned, 4L)
  expect_identical(meta$n_removed_na, 0L)
  expect_true(isTRUE(meta$aligned))
  expect_identical(meta$sim_used, c(1, 2, 3, 4))
  expect_identical(meta$obs_used, c(1, 2, 3, 4))
})

test_that("gof propagates output and label selection into metadata", {
  out <- .hm_gof_get("gof")(
    sim = c(1, 2, 3, 4),
    obs = c(1, 2, 3, 4),
    methods = c("rmse", "nse"),
    output = "matrix",
    labels = "professional"
  )

  meta <- attr(out, "meta")

  expect_identical(meta$output, "matrix")
  expect_identical(meta$labels, "professional")
  expect_true(is.matrix(out))
})
