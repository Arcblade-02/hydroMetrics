test_that("exported compatibility and alias surface matches the documented policy", {
  ns_exports <- getNamespaceExports("hydroMetrics")
  compat_exports <- c(
    "HFB", "NSeff", "mNSeff", "rNSeff", "wsNSeff"
  )
  deprecated_exports <- c("mutual_information_score", "tail_dependence_score", "extended_valindex")
  canonical_exports <- c("high_flow_percent_bias", "upper_tail_conditional_exceedance", "composite_performance_index")
  label_only_aliases <- c(
    "NSE", "KGE", "MAE", "RMSE", "PBIAS", "R2", "NRMSE",
    "mNSE", "rNSE", "wsNSE", "rPearson"
  )

  expect_true(all(compat_exports %in% ns_exports))
  expect_true(all(deprecated_exports %in% ns_exports))
  expect_true(all(canonical_exports %in% ns_exports))
  expect_false(any(label_only_aliases %in% ns_exports))
})

test_that("metric-id alias lifecycle keeps rpearson deprecated and wrapper compatibility unchanged", {
  policy <- hydroMetrics:::.hm_metric_alias_policy()

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
  expect_true("mutual_information_score" %in% getNamespaceExports("hydroMetrics"))
})

test_that("exported canonical and compatibility alias pairs remain numerically aligned", {
  sim <- c(1, 2, 2, 4, 5, 7)
  obs <- c(1, 1, 3, 4, 6, 8)

  expect_warning(
    expect_equal(mutual_information_score(sim, obs), mutual_information(sim, obs)),
    "deprecated"
  )
})

test_that("mutual_information_score wrapper warns once per call", {
  sim <- c(1, 2, 2, 4, 5, 7)
  obs <- c(1, 1, 3, 4, 6, 8)
  warn_count <- 0L

  out <- withCallingHandlers(
    mutual_information_score(sim, obs),
    warning = function(w) {
      warn_count <<- warn_count + 1L
      invokeRestart("muffleWarning")
    }
  )

  expect_identical(warn_count, 1L)
  expect_equal(out, mutual_information(sim, obs))
})

test_that("Batch 4 deprecated wrappers warn once per call and forward to canonical wrappers", {
  warn_count <- 0L
  out_hfb <- withCallingHandlers(
    HFB(1:30 + 2, 1:30),
    warning = function(w) {
      warn_count <<- warn_count + 1L
      invokeRestart("muffleWarning")
    }
  )
  expect_identical(warn_count, 1L)
  expect_equal(as.numeric(out_hfb), as.numeric(high_flow_percent_bias(1:30 + 2, 1:30)))

  warn_count <- 0L
  sim_tail <- c(1, 2, 3, 7, 8, 4, 3, 2, 6, 7, 3, 2)
  obs_tail <- c(1, 2, 4, 8, 7, 5, 3, 2, 5, 8, 4, 2)
  out_tail <- withCallingHandlers(
    tail_dependence_score(sim_tail, obs_tail),
    warning = function(w) {
      warn_count <<- warn_count + 1L
      invokeRestart("muffleWarning")
    }
  )
  expect_identical(warn_count, 1L)
  expect_equal(out_tail, upper_tail_conditional_exceedance(sim_tail, obs_tail))

  warn_count <- 0L
  sim_ext <- c(1.2, 1.8, 3.4, 3.9, 5.1)
  obs_ext <- c(1.0, 2.0, 3.0, 4.0, 5.0)
  out_ext <- withCallingHandlers(
    extended_valindex(sim_ext, obs_ext),
    warning = function(w) {
      warn_count <<- warn_count + 1L
      invokeRestart("muffleWarning")
    }
  )
  expect_identical(warn_count, 1L)
  expect_equal(out_ext, composite_performance_index(sim_ext, obs_ext))
})
