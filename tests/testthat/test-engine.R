test_that("registry schema validation fails on missing required fields", {
  registry <- hydroMetrics:::MetricRegistry$new()

  expect_error(
    registry$register(list(
      id = "bad",
      fun = function(sim, obs) 0,
      name = "Bad Metric"
    )),
    "Missing required field"
  )
})

test_that("registry schema validation fails on invalid category", {
  registry <- hydroMetrics:::MetricRegistry$new()

  bad_spec <- list(
    id = "bad_category",
    fun = function(sim, obs) 0,
    name = "Bad Category",
    description = "Invalid category test",
    category = "invalid",
    perfect = 0,
    range = NULL,
    references = "Test reference",
    version_added = "0.1.0",
    tags = character()
  )

  expect_error(registry$register(bad_spec), "must be one of")
})

test_that("cannot register duplicate metric id", {
  expect_error(
    register_metric(
      id = "nse",
      fun = function(sim, obs) 0,
      name = "Duplicate NSE",
      description = "Duplicate registration test"
    ),
    "already registered"
  )
})

test_that("engine errors on unequal vector lengths", {
  expect_error(
    evaluate_metrics(sim = c(1, 2, 3), obs = c(1, 2), metrics = "nse"),
    "same length"
  )
})

test_that("engine returns expected hm_result structure", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("nse", "rmse", "pbias")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("nse", "rmse", "pbias"))
})

test_that("perfect-case values are correct for core metrics", {
  out <- evaluate_metrics(
    sim = c(2, 4, 6),
    obs = c(2, 4, 6),
    metrics = c("nse", "rmse", "pbias")
  )
  values <- setNames(out$value, out$metric)

  expect_equal(values[["nse"]], 1)
  expect_equal(values[["rmse"]], 0)
  expect_equal(values[["pbias"]], 0)
})

test_that("core metrics return expected values on simple vectors", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("nse", "rmse", "pbias")
  )
  values <- setNames(out$value, out$metric)

  expect_equal(values[["nse"]], -5)
  expect_equal(values[["rmse"]], sqrt(4 / 3))
  expect_equal(values[["pbias"]], 50)
})

test_that("engine canonicalizes deprecated metric aliases during evaluation", {
  expect_warning(
    out <- evaluate_metrics(
      sim = c(1, 2, 3),
      obs = c(1, 2, 1),
      metrics = "rpearson"
    ),
    "deprecated"
  )

  expect_identical(out$metric, "r")
  expect_equal(out$value[[1]], stats::cor(c(1, 2, 3), c(1, 2, 1)))
})

test_that("metric alias policy records alias lifecycle metadata", {
  policy <- hydroMetrics:::.hm_metric_alias_policy()

  expect_true(is.data.frame(policy))
  expect_identical(colnames(policy), c("alias", "target", "lifecycle"))
  expect_true("rpearson" %in% policy$alias)
  expect_identical(policy$target[policy$alias == "rpearson"][[1]], "r")
  expect_identical(policy$lifecycle[policy$alias == "rpearson"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "nrmse_sd"][[1]], "rsr")
  expect_identical(policy$lifecycle[policy$alias == "nrmse_sd"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "mutual_information_score"][[1]], "mutual_information")
  expect_identical(policy$lifecycle[policy$alias == "mutual_information_score"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "rfactor"][[1]], "mean_absolute_error_ratio")
  expect_identical(policy$lifecycle[policy$alias == "rfactor"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "pfactor"][[1]], "within_tolerance_rate")
  expect_identical(policy$lifecycle[policy$alias == "pfactor"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "br2"][[1]], "slope_scaled_r2")
  expect_identical(policy$lifecycle[policy$alias == "br2"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "rd"][[1]], "obs_normalized_agreement_index")
  expect_identical(policy$lifecycle[policy$alias == "rd"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "skge"][[1]], "monthly_grouped_kge")
  expect_identical(policy$lifecycle[policy$alias == "skge"][[1]], "compatibility")
  expect_identical(policy$target[policy$alias == "kgelf"][[1]], "log_transformed_kge")
  expect_identical(policy$lifecycle[policy$alias == "kgelf"][[1]], "compatibility")
  expect_identical(policy$target[policy$alias == "hfb"][[1]], "high_flow_percent_bias")
  expect_identical(policy$lifecycle[policy$alias == "hfb"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "tail_dependence_score"][[1]], "upper_tail_conditional_exceedance")
  expect_identical(policy$lifecycle[policy$alias == "tail_dependence_score"][[1]], "deprecated")
  expect_identical(policy$target[policy$alias == "extended_valindex"][[1]], "composite_performance_index")
  expect_identical(policy$lifecycle[policy$alias == "extended_valindex"][[1]], "deprecated")
})

test_that("engine canonicalizes Batch 2 deprecated aliases during evaluation", {
  sim <- c(1, 2, 2, 4, 5, 7)
  obs <- c(1, 1, 3, 4, 6, 8)

  expect_warning(
    rsr_out <- evaluate_metrics(sim = sim, obs = obs, metrics = "nrmse_sd"),
    "deprecated"
  )
  expect_identical(rsr_out$metric, "rsr")
  expect_equal(rsr_out$value[[1]], evaluate_metrics(sim = sim, obs = obs, metrics = "rsr")$value[[1]])

  expect_warning(
    mi_out <- evaluate_metrics(sim = sim, obs = obs, metrics = "mutual_information_score"),
    "deprecated"
  )
  expect_identical(mi_out$metric, "mutual_information")
  expect_equal(mi_out$value[[1]], evaluate_metrics(sim = sim, obs = obs, metrics = "mutual_information")$value[[1]])
})

test_that("engine canonicalizes Batch 3A deprecated aliases during evaluation", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_warning(
    rfactor_out <- evaluate_metrics(sim = c(1, 1, 4), obs = c(1, 2, 3), metrics = "rfactor"),
    "deprecated"
  )
  expect_identical(rfactor_out$metric, "mean_absolute_error_ratio")
  expect_equal(
    rfactor_out$value[[1]],
    evaluate_metrics(sim = c(1, 1, 4), obs = c(1, 2, 3), metrics = "mean_absolute_error_ratio")$value[[1]]
  )

  expect_warning(
    pfactor_out <- evaluate_metrics(sim = c(9, 11, 12), obs = c(10, 10, 10), metrics = "pfactor"),
    "deprecated"
  )
  expect_identical(pfactor_out$metric, "within_tolerance_rate")
  expect_equal(
    pfactor_out$value[[1]],
    evaluate_metrics(sim = c(9, 11, 12), obs = c(10, 10, 10), metrics = "within_tolerance_rate")$value[[1]]
  )

  expect_warning(
    br2_out <- evaluate_metrics(sim = sim, obs = obs, metrics = "br2"),
    "deprecated"
  )
  expect_identical(br2_out$metric, "slope_scaled_r2")
  expect_equal(br2_out$value[[1]], evaluate_metrics(sim = sim, obs = obs, metrics = "slope_scaled_r2")$value[[1]])
})

test_that("engine canonicalizes Batch 3B mixed-lifecycle aliases during evaluation", {
  sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_warning(
    rd_out <- evaluate_metrics(sim = sim, obs = obs, metrics = "rd"),
    "deprecated"
  )
  expect_identical(rd_out$metric, "obs_normalized_agreement_index")
  expect_equal(
    rd_out$value[[1]],
    evaluate_metrics(sim = sim, obs = obs, metrics = "obs_normalized_agreement_index")$value[[1]]
  )

  expect_no_warning(
    skge_out <- evaluate_metrics(sim = sim, obs = obs, metrics = "skge")
  )
  expect_identical(skge_out$metric, "monthly_grouped_kge")
  expect_equal(
    skge_out$value[[1]],
    evaluate_metrics(sim = sim, obs = obs, metrics = "monthly_grouped_kge")$value[[1]]
  )

  expect_no_warning(
    kgelf_out <- evaluate_metrics(sim = c(1, 2, 3), obs = c(1, 2, 1), metrics = "kgelf")
  )
  expect_identical(kgelf_out$metric, "log_transformed_kge")
  expect_equal(
    kgelf_out$value[[1]],
    evaluate_metrics(sim = c(1, 2, 3), obs = c(1, 2, 1), metrics = "log_transformed_kge")$value[[1]]
  )
})

test_that("engine canonicalizes Batch 4 deprecated aliases during evaluation", {
  sim <- 1:30 + 2
  obs <- 1:30

  expect_warning(
    hfb_out <- evaluate_metrics(sim = sim, obs = obs, metrics = "hfb"),
    "deprecated"
  )
  expect_identical(hfb_out$metric, "high_flow_percent_bias")
  expect_equal(
    hfb_out$value[[1]],
    evaluate_metrics(sim = sim, obs = obs, metrics = "high_flow_percent_bias")$value[[1]]
  )

  tail_sim <- c(1, 2, 3, 7, 8, 4, 3, 2, 6, 7, 3, 2)
  tail_obs <- c(1, 2, 4, 8, 7, 5, 3, 2, 5, 8, 4, 2)

  expect_warning(
    tail_out <- evaluate_metrics(sim = tail_sim, obs = tail_obs, metrics = "tail_dependence_score"),
    "deprecated"
  )
  expect_identical(tail_out$metric, "upper_tail_conditional_exceedance")
  expect_equal(
    tail_out$value[[1]],
    evaluate_metrics(sim = tail_sim, obs = tail_obs, metrics = "upper_tail_conditional_exceedance")$value[[1]]
  )

  score_sim <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  score_obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_warning(
    ext_out <- evaluate_metrics(sim = score_sim, obs = score_obs, metrics = "extended_valindex"),
    "deprecated"
  )
  expect_identical(ext_out$metric, "composite_performance_index")
  expect_equal(
    ext_out$value[[1]],
    evaluate_metrics(sim = score_sim, obs = score_obs, metrics = "composite_performance_index")$value[[1]]
  )
})

test_that("engine forwards metric-call parameters to registered metrics", {
  sim <- c(1.0, 2.2, 2.7, 4.0)
  obs <- c(1.0, 2.0, 3.0, 4.0)

  out <- evaluate_metrics(
    sim = sim,
    obs = obs,
    metrics = list(list(id = "within_tolerance_rate", params = list(tol = 0.05)))
  )

  expect_identical(out$metric, "within_tolerance_rate")
  expect_equal(out$value[[1]], hydroMetrics:::metric_pfactor(sim, obs, tol = 0.05))
})
