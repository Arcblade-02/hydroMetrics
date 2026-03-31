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
  "low_flow_bias",
  "peak_timing_error", "extreme_event_ratio", "rising_limb_error",
  "baseflow_index_error",
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
  expect_true(all(c("sae", "rmsle", "evs", "rae", "rrse") %in% names(out)))
})

test_that("gof explicit methods override default and extended selection", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  out <- .hm_gof_get("gof")(sim, obs, methods = c("nse", "rmse"), extended = TRUE)

  expect_true(is.numeric(out))
  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(out), c("nse", "rmse"))
})

test_that("gof exposes sae, rmsle, and evs through explicit method selection", {
  sim <- c(1.2, 1.9, 3.4, 4.8)
  obs <- c(1, 2, 3, 5)

  out <- .hm_gof_get("gof")(sim, obs, methods = c("sae", "rmsle", "evs"))

  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(out), c("sae", "rmsle", "evs"))
  expect_equal(as.numeric(out[["sae"]]), sum(abs(sim - obs)))
  expect_equal(as.numeric(out[["rmsle"]])^2, .hm_gof_get("metric_msle")(sim, obs), tolerance = 1e-12)
  expect_equal(
    as.numeric(out[["evs"]]),
    1 - stats::var(obs - sim) / stats::var(obs),
    tolerance = 1e-12
  )
})

test_that("gof exposes rae and rrse through explicit method selection", {
  sim <- c(1.2, 1.9, 3.4, 4.8)
  obs <- c(1, 2, 3, 5)

  out <- .hm_gof_get("gof")(sim, obs, methods = c("rae", "rrse"))

  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(out), c("rae", "rrse"))
  expect_equal(as.numeric(out[["rae"]]), 1 - .hm_gof_get("metric_e1")(sim, obs), tolerance = 1e-12)
  expect_equal(as.numeric(out[["rrse"]])^2, 1 - .hm_gof_get("metric_nse")(sim, obs), tolerance = 1e-12)
})

test_that("gof defaults remain unchanged after adding sae, rmsle, and evs", {
  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  out <- .hm_gof_get("gof")(sim, obs)

  expect_false(any(c("sae", "rmsle", "evs", "rae", "rrse") %in% names(out)))
  expect_identical(names(out), .hm_gof_default_ids)
})

test_that("gof returns hydro_metrics object for single series", {
  expect_warning(
    out <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = c("NSE", "rmse", "rPearson")
    ),
    "deprecated"
  )

  expect_s3_class(out, "hydro_metrics")
  expect_true(is.numeric(out))
  expect_true(is.null(dim(out)))
  expect_true(all(c("NSE", "rmse", "rPearson") %in% names(out)))
})

test_that("gof canonicalizes deprecated orchestration aliases while preserving labels", {
  expect_warning(
    out <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = "rPearson"
    ),
    "deprecated"
  )

  ref <- .hm_gof_get("gof")(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = "r")

  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(out), "rPearson")
  expect_equal(as.numeric(out), as.numeric(ref))
})

test_that("gof keeps compatibility labels silent while preserving requested labels", {
  expect_no_warning(
    out_requested <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = "NSE",
      labels = "requested"
    )
  )

  expect_identical(names(out_requested), "NSE")

  out_canonical <- .hm_gof_get("gof")(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = "NSE",
    labels = "canonical"
  )

  expect_identical(names(out_canonical), "nse")
})

test_that("gof canonical labels normalize deprecated aliases while requested labels preserve them", {
  expect_warning(
    out_requested <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = "rPearson",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested), "rPearson")

  expect_warning(
    out_canonical <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = "rPearson",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical), "r")
})

test_that("gof preserves requested Batch 2 deprecated ids and canonicalizes their labels", {
  sim <- c(1, 2, 2, 4, 5, 7)
  obs <- c(1, 1, 3, 4, 6, 8)

  expect_warning(
    out_requested_rsr <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "nrmse_sd",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_rsr), "nrmse_sd")

  expect_warning(
    out_canonical_rsr <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "nrmse_sd",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_rsr), "rsr")
  expect_equal(out_canonical_rsr[["rsr"]], .hm_gof_get("gof")(sim, obs, methods = "rsr")[["rsr"]])

  expect_warning(
    out_requested_mi <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "mutual_information_score",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_mi), "mutual_information_score")

  expect_warning(
    out_canonical_mi <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "mutual_information_score",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_mi), "mutual_information")
  expect_equal(
    out_canonical_mi[["mutual_information"]],
    .hm_gof_get("gof")(sim, obs, methods = "mutual_information")[["mutual_information"]]
  )
})

test_that("gof preserves requested Batch 3A deprecated ids and canonicalizes their labels", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_warning(
    out_requested_rfactor <- .hm_gof_get("gof")(
      sim = c(1, 1, 4),
      obs = c(1, 2, 3),
      methods = "rfactor",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_rfactor), "rfactor")

  expect_warning(
    out_canonical_rfactor <- .hm_gof_get("gof")(
      sim = c(1, 1, 4),
      obs = c(1, 2, 3),
      methods = "rfactor",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_rfactor), "mean_absolute_error_ratio")
  expect_equal(
    out_canonical_rfactor[["mean_absolute_error_ratio"]],
    .hm_gof_get("gof")(c(1, 1, 4), c(1, 2, 3), methods = "mean_absolute_error_ratio")[["mean_absolute_error_ratio"]]
  )

  expect_warning(
    out_requested_pfactor <- .hm_gof_get("gof")(
      sim = c(9, 11, 12),
      obs = c(10, 10, 10),
      methods = "pfactor",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_pfactor), "pfactor")

  expect_warning(
    out_canonical_pfactor <- .hm_gof_get("gof")(
      sim = c(9, 11, 12),
      obs = c(10, 10, 10),
      methods = "pfactor",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_pfactor), "within_tolerance_rate")
  expect_equal(
    out_canonical_pfactor[["within_tolerance_rate"]],
    .hm_gof_get("gof")(c(9, 11, 12), c(10, 10, 10), methods = "within_tolerance_rate")[["within_tolerance_rate"]]
  )

  expect_warning(
    out_requested_br2 <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "br2",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_br2), "br2")

  expect_warning(
    out_canonical_br2 <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "br2",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_br2), "slope_scaled_r2")
  expect_equal(
    out_canonical_br2[["slope_scaled_r2"]],
    .hm_gof_get("gof")(sim, obs, methods = "slope_scaled_r2")[["slope_scaled_r2"]]
  )
})

test_that("gof preserves requested Batch 3B alias ids and canonicalizes their labels", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_warning(
    out_requested_rd <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "rd",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_rd), "rd")

  expect_warning(
    out_canonical_rd <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "rd",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_rd), "obs_normalized_agreement_index")
  expect_equal(
    out_canonical_rd[["obs_normalized_agreement_index"]],
    .hm_gof_get("gof")(sim, obs, methods = "obs_normalized_agreement_index")[["obs_normalized_agreement_index"]]
  )

  expect_no_warning(
    out_requested_skge <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "skge",
      labels = "requested"
    )
  )
  expect_identical(names(out_requested_skge), "skge")

  expect_no_warning(
    out_canonical_skge <- .hm_gof_get("gof")(
      sim = sim,
      obs = obs,
      methods = "skge",
      labels = "canonical"
    )
  )
  expect_identical(names(out_canonical_skge), "monthly_grouped_kge")
  expect_equal(
    out_canonical_skge[["monthly_grouped_kge"]],
    .hm_gof_get("gof")(sim, obs, methods = "monthly_grouped_kge")[["monthly_grouped_kge"]]
  )

  expect_no_warning(
    out_requested_kgelf <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = "kgelf",
      labels = "requested"
    )
  )
  expect_identical(names(out_requested_kgelf), "kgelf")

  expect_no_warning(
    out_canonical_kgelf <- .hm_gof_get("gof")(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      methods = "kgelf",
      labels = "canonical"
    )
  )
  expect_identical(names(out_canonical_kgelf), "log_transformed_kge")
  expect_equal(
    out_canonical_kgelf[["log_transformed_kge"]],
    .hm_gof_get("gof")(c(1, 2, 3), c(1, 2, 1), methods = "log_transformed_kge")[["log_transformed_kge"]]
  )
})

test_that("gof professional labels expose Batch 3B canonical names", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  out <- .hm_gof_get("gof")(
    sim = sim,
    obs = obs,
    methods = c("obs_normalized_agreement_index", "monthly_grouped_kge", "log_transformed_kge"),
    labels = "professional"
  )

  expect_identical(
    names(out),
    c("Observation-Normalized Agreement Index", "Monthly Grouped KGE", "Log-Transformed KGE")
  )
})

test_that("gof preserves requested Batch 4 deprecated ids and canonicalizes their labels", {
  sim_hfb <- 1:30 + 2
  obs_hfb <- 1:30

  expect_warning(
    out_requested_hfb <- .hm_gof_get("gof")(
      sim = sim_hfb,
      obs = obs_hfb,
      methods = "hfb",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_hfb), "hfb")

  expect_warning(
    out_canonical_hfb <- .hm_gof_get("gof")(
      sim = sim_hfb,
      obs = obs_hfb,
      methods = "hfb",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_hfb), "high_flow_percent_bias")
  expect_equal(
    out_canonical_hfb[["high_flow_percent_bias"]],
    .hm_gof_get("gof")(sim_hfb, obs_hfb, methods = "high_flow_percent_bias")[["high_flow_percent_bias"]]
  )

  sim_tail <- c(1, 2, 3, 7, 8, 4, 3, 2, 6, 7, 3, 2)
  obs_tail <- c(1, 2, 4, 8, 7, 5, 3, 2, 5, 8, 4, 2)

  expect_warning(
    out_requested_tail <- .hm_gof_get("gof")(
      sim = sim_tail,
      obs = obs_tail,
      methods = "tail_dependence_score",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_tail), "tail_dependence_score")

  expect_warning(
    out_canonical_tail <- .hm_gof_get("gof")(
      sim = sim_tail,
      obs = obs_tail,
      methods = "tail_dependence_score",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_tail), "upper_tail_conditional_exceedance")
  expect_equal(
    out_canonical_tail[["upper_tail_conditional_exceedance"]],
    .hm_gof_get("gof")(sim_tail, obs_tail, methods = "upper_tail_conditional_exceedance")[["upper_tail_conditional_exceedance"]]
  )

  sim_ext <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs_ext <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_warning(
    out_requested_ext <- .hm_gof_get("gof")(
      sim = sim_ext,
      obs = obs_ext,
      methods = "extended_valindex",
      labels = "requested"
    ),
    "deprecated"
  )
  expect_identical(names(out_requested_ext), "extended_valindex")

  expect_warning(
    out_canonical_ext <- .hm_gof_get("gof")(
      sim = sim_ext,
      obs = obs_ext,
      methods = "extended_valindex",
      labels = "canonical"
    ),
    "deprecated"
  )
  expect_identical(names(out_canonical_ext), "composite_performance_index")
  expect_equal(
    out_canonical_ext[["composite_performance_index"]],
    .hm_gof_get("gof")(sim_ext, obs_ext, methods = "composite_performance_index")[["composite_performance_index"]]
  )
})

test_that("gof professional labels expose Batch 4 canonical names", {
  sim <- 1:30 + 2
  obs <- 1:30

  out <- .hm_gof_get("gof")(
    sim = sim,
    obs = obs,
    methods = c("high_flow_percent_bias", "upper_tail_conditional_exceedance", "composite_performance_index"),
    labels = "professional"
  )

  expect_identical(
    names(out),
    c("High Flow Percent Bias", "Upper Tail Conditional Exceedance", "Composite Performance Index")
  )
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
