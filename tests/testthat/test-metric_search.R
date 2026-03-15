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
})

test_that("metric_search filters by text, category, tags, preset, and export flags", {
  expect_true("pbias" %in% metric_search(text = "percent bias")$id)

  category_out <- metric_search(category = "correlation")
  expect_true(nrow(category_out) > 0L)
  expect_true(all(category_out$category == "correlation"))

  tag_out <- metric_search(tags = "probabilistic")
  expect_true(all(grepl("probabilistic", tag_out$tags, fixed = TRUE)))
  expect_true(all(c("crps", "picp", "mwpi", "skill_score") %in% tag_out$id))

  preset_out <- metric_search(preset = "probabilistic_uncertainty")
  expect_true(all(c(
    "crps",
    "picp",
    "mwpi",
    "skill_score",
    "quantile_loss",
    "quantile_kge",
    "cdf_rmse",
    "distribution_overlap"
  ) %in% preset_out$id))

  exported_out <- metric_search(exported = TRUE)
  expect_true(all(nzchar(exported_out$exported_wrappers)))

  compat_out <- metric_search(compatibility = TRUE)
  expect_true(all(compat_out$compatibility_export))
  expect_true(all(c("nse", "mnse", "rnse", "wsnse", "apfb", "hfb") %in% compat_out$id))
})

test_that("metric_search validates discovery filters conservatively", {
  expect_error(metric_search(text = NA_character_), "`text` must be NULL or a character vector")
  expect_error(metric_search(exported = NA), "`exported` must be TRUE, FALSE, or NULL")
  expect_error(metric_search(compatibility = c(TRUE, FALSE)), "`compatibility` must be TRUE, FALSE, or NULL")
  expect_error(metric_search(preset = "not_a_preset"), "Unknown `preset` value")
})
