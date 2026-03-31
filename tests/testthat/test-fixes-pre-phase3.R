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

test_that("pairwise preprocessing defers NA dropping instead of matching remove", {
  sim <- c(1, NA, 3, 4, 5)
  obs <- c(1, 2, NA, 4, 5)

  out_remove <- .hm_get("hm_prepare")(sim, obs, na_strategy = "remove")
  out_pair <- .hm_get("hm_prepare")(sim, obs, na_strategy = "pairwise")

  expect_identical(out_remove$sim, c(1, 4, 5))
  expect_identical(out_remove$obs, c(1, 4, 5))
  expect_identical(out_remove$n_removed_na, 2L)
  expect_identical(out_pair$sim, sim)
  expect_identical(out_pair$obs, obs)
  expect_identical(out_pair$n_removed_na, 0L)
  expect_identical(out_pair$n, 5L)
  expect_identical(out_pair$removed, 0L)
})

test_that("pairwise gof remains deterministic on valid paired values", {
  sim <- c(1, NA, 3, 4, 5)
  obs <- c(1, 2, NA, 4, 5)

  out_remove <- .hm_get("gof")(sim, obs, methods = "nse", na_strategy = "remove")
  out_pair <- .hm_get("gof")(sim, obs, methods = "nse", na_strategy = "pairwise")

  expect_equal(out_pair[["nse"]], out_remove[["nse"]])
  expect_identical(attr(out_pair, "n_obs"), 3L)
  expect_identical(attr(out_pair, "meta")$n_removed_na, 2L)
})

test_that("slope_scaled_r2 matches abs(slope) * r^2 and differs from the old penalty formula", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  manual <- abs(stats::coef(stats::lm(sim ~ obs))[2]) * stats::cor(sim, obs)^2
  old_formula <- {
    r <- stats::cor(sim, obs)
    sd_penalty <- min(stats::sd(sim), stats::sd(obs)) / max(stats::sd(sim), stats::sd(obs))
    mean_penalty <- min(mean(sim), mean(obs)) / max(mean(sim), mean(obs))
    (r^2) * (sd_penalty^2) * (mean_penalty^2)
  }

  out <- .hm_get("evaluate_metrics")(sim, obs, "slope_scaled_r2")

  expect_equal(out$value[[1]], unname(manual), tolerance = 1e-12)
  expect_false(isTRUE(all.equal(unname(manual), unname(old_formula), tolerance = 1e-12)))
})

test_that("Batch 3A aliases are deprecated and no longer canonical registry ids", {
  ids <- .hm_get("list_metrics")()$id

  expect_true(all(c("mean_absolute_error_ratio", "within_tolerance_rate", "slope_scaled_r2") %in% ids))
  expect_false(any(c("rfactor", "pfactor", "br2") %in% ids))

  expect_warning(
    rfactor_out <- .hm_get("evaluate_metrics")(c(1, 1, 4), c(1, 2, 3), "rfactor"),
    "deprecated"
  )
  expect_identical(rfactor_out$metric, "mean_absolute_error_ratio")

  expect_warning(
    pfactor_out <- .hm_get("evaluate_metrics")(c(9, 11, 12), c(10, 10, 10), "pfactor"),
    "deprecated"
  )
  expect_identical(pfactor_out$metric, "within_tolerance_rate")

  expect_warning(
    br2_out <- .hm_get("evaluate_metrics")(c(1.2, 1.8, 3.4, 3.9, 5.1), c(1.0, 2.0, 3.0, 4.0, 5.0), "br2"),
    "deprecated"
  )
  expect_identical(br2_out$metric, "slope_scaled_r2")
})

test_that("Batch 3B aliases follow the approved lifecycle and no longer canonical registry ids", {
  ids <- .hm_get("list_metrics")()$id

  expect_true(all(c("obs_normalized_agreement_index", "monthly_grouped_kge", "log_transformed_kge") %in% ids))
  expect_false(any(c("rd", "skge", "kgelf") %in% ids))

  expect_warning(
    rd_out <- .hm_get("evaluate_metrics")(c(1.2, 1.8, 3.4, 3.9, 5.1), c(1.0, 2.0, 3.0, 4.0, 5.0), "rd"),
    "deprecated"
  )
  expect_identical(rd_out$metric, "obs_normalized_agreement_index")

  expect_no_warning(
    skge_out <- .hm_get("evaluate_metrics")(c(1, 2, 3, 4), c(1, 2, 3, 4), "skge")
  )
  expect_identical(skge_out$metric, "monthly_grouped_kge")

  expect_no_warning(
    kgelf_out <- .hm_get("evaluate_metrics")(c(1, 2, 3), c(1, 2, 1), "kgelf")
  )
  expect_identical(kgelf_out$metric, "log_transformed_kge")
})

test_that("rpearson is deprecated and no longer a canonical registry id", {
  ids <- .hm_get("list_metrics")()$id

  expect_true("r" %in% ids)
  expect_false("rpearson" %in% ids)
  expect_identical(sum(ids %in% c("r", "rpearson")), 1L)
  expect_warning(
    deprecated <- .hm_get("evaluate_metrics")(c(1, 2, 3), c(1, 2, 1), "rpearson"),
    "deprecated"
  )
  canonical <- .hm_get("evaluate_metrics")(c(1, 2, 3), c(1, 2, 1), "r")
  expect_equal(deprecated$value[[1]], canonical$value[[1]])
})

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
