test_that("metric_search returns annotated metric metadata", {
  out <- hydroMetrics::metric_search()

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

  expect_true(nrow(out) > 0L)
  expect_identical(anyDuplicated(out$id), 0L)
  expect_true(all(nzchar(out$id)))
  expect_true(all(c(
    "mae",
    "nse",
    "hfb",
    "mutual_information",
    "r",
    "upper_tail_conditional_exceedance",
    "composite_performance_index"
  ) %in% out$id))

  nse_row <- out[out$id == "nse", , drop = FALSE]
  mae_row <- out[out$id == "mae", , drop = FALSE]
  mi_row <- out[out$id == "mutual_information", , drop = FALSE]
  hfb_row <- out[out$id == "hfb", , drop = FALSE]
  r_row <- out[out$id == "r", , drop = FALSE]
  tail_row <- out[out$id == "upper_tail_conditional_exceedance", , drop = FALSE]
  composite_row <- out[out$id == "composite_performance_index", , drop = FALSE]

  expect_identical(nse_row$exported_wrappers[[1]], "NSeff")
  expect_true(nse_row$compatibility_export[[1]])

  expect_identical(mae_row$exported_wrappers[[1]], "mae")
  expect_false(mae_row$compatibility_export[[1]])

  expect_match(mi_row$exported_wrappers[[1]], "mutual_information")
  expect_match(mi_row$exported_wrappers[[1]], "mutual_information_score")
  expect_true(mi_row$compatibility_export[[1]])

  expect_identical(hfb_row$exported_wrappers[[1]], "HFB")
  expect_true(hfb_row$compatibility_export[[1]])

  expect_identical(r_row$exported_wrappers[[1]], "r")
  expect_false(r_row$compatibility_export[[1]])

  expect_identical(
    tail_row$exported_wrappers[[1]],
    "tail_dependence_score; upper_tail_conditional_exceedance"
  )
  expect_false(tail_row$compatibility_export[[1]])

  expect_identical(
    composite_row$exported_wrappers[[1]],
    "composite_performance_index; extended_valindex"
  )
  expect_false(composite_row$compatibility_export[[1]])
})

test_that("metric_search filters by text, category, tags, preset, and export flags", {
  expect_true("pbias" %in% hydroMetrics::metric_search(text = "percent bias")$id)
  expect_true("msle" %in% hydroMetrics::metric_search(text = "logarithmic")$id)

  category_out <- hydroMetrics::metric_search(category = "correlation")
  expect_true(nrow(category_out) > 0L)
  expect_true(all(category_out$category == "correlation"))

  tag_out <- hydroMetrics::metric_search(tags = "kge-component")
  expect_true(all(grepl("kge-component", tag_out$tags, fixed = TRUE)))
  expect_true(all(c("alpha", "beta") %in% tag_out$id))

  preset_out <- hydroMetrics::metric_search(preset = "probabilistic_uncertainty")
  expect_true(all(c(
    "quantile_loss",
    "quantile_kge",
    "cdf_rmse",
    "distribution_overlap"
  ) %in% preset_out$id))

  exported_out <- hydroMetrics::metric_search(exported = TRUE)
  expect_true(all(nzchar(exported_out$exported_wrappers)))
  expect_true(all(c(
    "msle",
    "mutual_information",
    "upper_tail_conditional_exceedance",
    "composite_performance_index"
  ) %in% exported_out$id))

  compat_out <- hydroMetrics::metric_search(compatibility = TRUE)
  expect_true(all(compat_out$compatibility_export))
  expect_true(all(c("nse", "mnse", "rnse", "wsnse", "hfb") %in% compat_out$id))
  expect_false(any(c(
    "upper_tail_conditional_exceedance",
    "composite_performance_index"
  ) %in% compat_out$id))

  deterministic_error_out <- hydroMetrics::metric_search(preset = "deterministic_error")
  expect_true(all(c(
    "mae",
    "mape",
    "mare",
    "maxae",
    "mdae",
    "msle",
    "rmse",
    "rrmse",
    "rsr"
  ) %in% deterministic_error_out$id))
  expect_false("kge" %in% deterministic_error_out$id)
})

test_that("metric_search keeps canonical ids distinct from deprecated and orchestration-only aliases", {
  out <- hydroMetrics::metric_search()

  expect_false(any(c(
    "rpearson",
    "tail_dependence_score",
    "extended_valindex"
  ) %in% out$id))

  tail_row <- out[out$id == "upper_tail_conditional_exceedance", , drop = FALSE]
  composite_row <- out[out$id == "composite_performance_index", , drop = FALSE]

  expect_match(tail_row$exported_wrappers[[1]], "tail_dependence_score")
  expect_match(composite_row$exported_wrappers[[1]], "extended_valindex")
})

test_that("metric_search validates discovery filters conservatively", {
  expect_error(hydroMetrics::metric_search(text = NA_character_), "`text` must be NULL or a character vector")
  expect_error(hydroMetrics::metric_search(exported = NA), "`exported` must be TRUE, FALSE, or NULL")
  expect_error(hydroMetrics::metric_search(compatibility = c(TRUE, FALSE)), "`compatibility` must be TRUE, FALSE, or NULL")
  expect_error(hydroMetrics::metric_search(preset = "not_a_preset"), "Unknown `preset` value")
})

test_that("metric_preset resolves documented presets to canonical metric ids", {
  out <- hydroMetrics::metric_preset("recommended")
  all_ids <- hydroMetrics::metric_search()$id

  expect_type(out, "character")
  expect_true(length(out) > 0L)
  expect_true(all(out %in% all_ids))
  expect_true(all(c("nse", "kge", "rmse", "pbias") %in% out))

  exported_out <- hydroMetrics::metric_preset("compatibility_core", exported_only = TRUE)
  expect_type(exported_out, "character")
  expect_true(all(exported_out %in% hydroMetrics::metric_search(exported = TRUE)$id))
  expect_true(all(c("nse", "mnse", "rnse", "wsnse", "hfb") %in% exported_out))
})

test_that("metric_preset validates input conservatively", {
  expect_error(hydroMetrics::metric_preset("not_a_preset"), "Unknown `preset` value")
  expect_error(hydroMetrics::metric_preset(NA_character_), "`preset` must be NULL or a character vector")
  expect_error(hydroMetrics::metric_preset("recommended", exported_only = NA), "`exported_only` must be TRUE, FALSE, or NULL")
})

test_that("metric_preset output works directly with gof(methods = ...)", {
  methods <- hydroMetrics::metric_preset("recommended")
  out <- hydroMetrics::gof(c(1, 2, 3, 4), c(1, 2, 2, 4), methods = methods)

  expect_s3_class(out, "hydro_metrics")
  expect_true(all(methods %in% names(out)))
})
