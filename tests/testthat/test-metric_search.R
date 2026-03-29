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

  expect_identical(nse_row$exported_wrappers[[1]], "NSeff")
  expect_true(nse_row$compatibility_export[[1]])
  expect_identical(mae_row$exported_wrappers[[1]], "mae")
  expect_false(mae_row$compatibility_export[[1]])
  expect_match(mi_row$exported_wrappers[[1]], "mutual_information")
  expect_match(mi_row$exported_wrappers[[1]], "mutual_information_score")
  expect_true(all(c("sae", "rmsle", "evs") %in% out$id))

  sae_row <- out[out$id == "sae", , drop = FALSE]
  rmsle_row <- out[out$id == "rmsle", , drop = FALSE]
  evs_row <- out[out$id == "evs", , drop = FALSE]

  expect_identical(sae_row$category[[1]], "error")
  expect_identical(sae_row$exported_wrappers[[1]], "")
  expect_identical(rmsle_row$category[[1]], "error")
  expect_identical(rmsle_row$exported_wrappers[[1]], "rmsle")
  expect_identical(evs_row$category[[1]], "efficiency")
  expect_identical(evs_row$exported_wrappers[[1]], "")
})

test_that("metric_search filters by text, category, tags, preset, and export flags", {
  expect_true("pbias" %in% metric_search(text = "percent bias")$id)
  expect_true("sae" %in% metric_search(text = "sum absolute error")$id)
  expect_true("rmsle" %in% metric_search(text = "logarithmic")$id)
  expect_true("evs" %in% metric_search(text = "explained variance")$id)

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
  expect_false(any(c("sae", "evs") %in% exported_out$id))

  compat_out <- metric_search(compatibility = TRUE)
  expect_true(all(compat_out$compatibility_export))
  expect_true(all(c("nse", "mnse", "rnse", "wsnse", "hfb") %in% compat_out$id))

  deterministic_error_out <- metric_search(preset = "deterministic_error")
  expect_true(all(c("sae", "rmsle") %in% deterministic_error_out$id))
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
  expect_true(all(c("nse", "mnse", "rnse", "wsnse", "hfb") %in% exported_out))
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
