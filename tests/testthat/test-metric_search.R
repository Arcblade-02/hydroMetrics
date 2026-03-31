test_that("metric_search returns annotated metric metadata", {
  out <- metric_search()

  expect_true(is.data.frame(out))
  expect_true(all(c(
    "id",
    "name",
    "category",
    "exported_wrappers",
    "compatibility_export",
    "presets",
    "description",
    "version_added",
    "tags"
  ) %in% names(out)))
  expect_identical(nrow(out), nrow(hydroMetrics:::list_metrics()))

  nse_row <- out[out$id == "nse", , drop = FALSE]
  mae_row <- out[out$id == "mae", , drop = FALSE]
  mi_row <- out[out$id == "mutual_information", , drop = FALSE]
  mar_row <- out[out$id == "mean_absolute_error_ratio", , drop = FALSE]
  wtr_row <- out[out$id == "within_tolerance_rate", , drop = FALSE]
  ssr2_row <- out[out$id == "slope_scaled_r2", , drop = FALSE]
  onai_row <- out[out$id == "obs_normalized_agreement_index", , drop = FALSE]
  mgk_row <- out[out$id == "monthly_grouped_kge", , drop = FALSE]
  ltk_row <- out[out$id == "log_transformed_kge", , drop = FALSE]
  hfpb_row <- out[out$id == "high_flow_percent_bias", , drop = FALSE]
  utce_row <- out[out$id == "upper_tail_conditional_exceedance", , drop = FALSE]
  cpi_row <- out[out$id == "composite_performance_index", , drop = FALSE]

  expect_identical(nse_row$exported_wrappers[[1]], "NSeff")
  expect_true(nse_row$compatibility_export[[1]])
  expect_identical(mae_row$exported_wrappers[[1]], "mae")
  expect_false(mae_row$compatibility_export[[1]])
  expect_match(mi_row$exported_wrappers[[1]], "mutual_information")
  expect_match(mi_row$exported_wrappers[[1]], "mutual_information_score")
  expect_false(mi_row$compatibility_export[[1]])
  expect_false(any(c("nrmse_sd", "mutual_information_score", "rfactor", "pfactor", "br2", "rd", "skge", "kgelf", "hfb", "tail_dependence_score", "extended_valindex") %in% out$id))
  expect_identical(mar_row$category[[1]], "error")
  expect_false(mar_row$compatibility_export[[1]])
  expect_identical(wtr_row$category[[1]], "efficiency")
  expect_false(wtr_row$compatibility_export[[1]])
  expect_identical(ssr2_row$category[[1]], "correlation")
  expect_false(ssr2_row$compatibility_export[[1]])
  expect_identical(onai_row$category[[1]], "agreement")
  expect_false(onai_row$compatibility_export[[1]])
  expect_identical(mgk_row$category[[1]], "efficiency")
  expect_false(mgk_row$compatibility_export[[1]])
  expect_identical(ltk_row$category[[1]], "efficiency")
  expect_false(ltk_row$compatibility_export[[1]])
  expect_identical(hfpb_row$category[[1]], "bias")
  expect_true(hfpb_row$compatibility_export[[1]])
  expect_match(hfpb_row$exported_wrappers[[1]], "HFB")
  expect_match(hfpb_row$exported_wrappers[[1]], "high_flow_percent_bias")
  expect_identical(utce_row$category[[1]], "agreement")
  expect_false(utce_row$compatibility_export[[1]])
  expect_match(utce_row$exported_wrappers[[1]], "tail_dependence_score")
  expect_match(utce_row$exported_wrappers[[1]], "upper_tail_conditional_exceedance")
  expect_identical(cpi_row$category[[1]], "agreement")
  expect_false(cpi_row$compatibility_export[[1]])
  expect_match(cpi_row$exported_wrappers[[1]], "extended_valindex")
  expect_match(cpi_row$exported_wrappers[[1]], "composite_performance_index")
  expect_true(all(c("sae", "rmsle", "evs", "rae", "rrse") %in% out$id))

  sae_row <- out[out$id == "sae", , drop = FALSE]
  rmsle_row <- out[out$id == "rmsle", , drop = FALSE]
  evs_row <- out[out$id == "evs", , drop = FALSE]
  rae_row <- out[out$id == "rae", , drop = FALSE]
  rrse_row <- out[out$id == "rrse", , drop = FALSE]

  expect_identical(sae_row$category[[1]], "error")
  expect_identical(sae_row$exported_wrappers[[1]], "")
  expect_identical(rmsle_row$category[[1]], "error")
  expect_identical(rmsle_row$exported_wrappers[[1]], "rmsle")
  expect_identical(evs_row$category[[1]], "efficiency")
  expect_identical(evs_row$exported_wrappers[[1]], "")
  expect_identical(rae_row$category[[1]], "error")
  expect_identical(rae_row$exported_wrappers[[1]], "")
  expect_identical(rrse_row$category[[1]], "error")
  expect_identical(rrse_row$exported_wrappers[[1]], "")
})

test_that("metric_search filters by text, category, tags, preset, and export flags", {
  expect_true("pbias" %in% metric_search(text = "percent bias")$id)
  expect_true("sae" %in% metric_search(text = "sum absolute error")$id)
  expect_true("rmsle" %in% metric_search(text = "logarithmic")$id)
  expect_true("evs" %in% metric_search(text = "explained variance")$id)
  expect_true("rae" %in% metric_search(text = "relative absolute error")$id)
  expect_true("rrse" %in% metric_search(text = "root relative squared error")$id)

  category_out <- metric_search(category = "correlation")
  expect_true(nrow(category_out) > 0L)
  expect_true(all(category_out$category == "correlation"))

  tag_out <- metric_search(tags = "kge-component")
  expect_true(all(grepl("kge-component", tag_out$tags, fixed = TRUE)))
  expect_true(all(c("alpha", "beta") %in% tag_out$id))

  preset_out <- metric_search(preset = "probabilistic_uncertainty")
  expect_true(all(c(
    "quantile_loss",
    "quantile_kge",
    "cdf_rmse",
    "distribution_overlap"
  ) %in% preset_out$id))

  exported_out <- metric_search(exported = TRUE)
  expect_true(all(nzchar(exported_out$exported_wrappers)))
  expect_true("rmsle" %in% exported_out$id)
  expect_true(all(c("high_flow_percent_bias", "upper_tail_conditional_exceedance", "composite_performance_index") %in% exported_out$id))
  expect_false(any(c("sae", "evs", "rae", "rrse") %in% exported_out$id))

  compat_out <- metric_search(compatibility = TRUE)
  expect_true(all(compat_out$compatibility_export))
  expect_true(all(c("nse", "mnse", "rnse", "wsnse", "high_flow_percent_bias") %in% compat_out$id))
  expect_false(any(c("nrmse_sd", "mutual_information_score", "rfactor", "pfactor", "br2", "rd", "skge", "kgelf", "hfb", "tail_dependence_score", "extended_valindex") %in% compat_out$id))

  deterministic_error_out <- metric_search(preset = "deterministic_error")
  expect_true(all(c("sae", "rmsle", "rae", "rrse") %in% deterministic_error_out$id))
  expect_false("evs" %in% deterministic_error_out$id)
})

test_that("metric_search validates discovery filters conservatively", {
  expect_error(metric_search(text = NA_character_), "`text` must be NULL or a character vector")
  expect_error(metric_search(exported = NA), "`exported` must be TRUE, FALSE, or NULL")
  expect_error(metric_search(compatibility = c(TRUE, FALSE)), "`compatibility` must be TRUE, FALSE, or NULL")
  expect_error(metric_search(preset = "not_a_preset"), "Unknown `preset` value")
})

test_that("metric_preset resolves documented presets to canonical metric ids", {
  out <- metric_preset("recommended")

  expect_type(out, "character")
  expect_true(length(out) > 0L)
  expect_true(all(out %in% hydroMetrics:::list_metrics()$id))
  expect_true(all(c("nse", "kge", "rmse", "pbias") %in% out))

  exported_out <- metric_preset("compatibility_core", exported_only = TRUE)
  expect_type(exported_out, "character")
  expect_true(all(exported_out %in% hydroMetrics:::metric_search(exported = TRUE)$id))
  expect_true(all(c("nse", "mnse", "rnse", "wsnse", "high_flow_percent_bias") %in% exported_out))
})

test_that("metric_preset validates input conservatively", {
  expect_error(metric_preset("not_a_preset"), "Unknown `preset` value")
  expect_error(metric_preset(NA_character_), "`preset` must be NULL or a character vector")
  expect_error(metric_preset("recommended", exported_only = NA), "`exported_only` must be TRUE, FALSE, or NULL")
})

test_that("metric_preset output works directly with gof(methods = ...)", {
  methods <- metric_preset("recommended")
  out <- gof(c(1, 2, 3, 4), c(1, 2, 2, 4), methods = methods)

  expect_s3_class(out, "hydro_metrics")
  expect_true(all(methods %in% names(out)))
})
