test_that("package metadata and core exports are present at runtime", {
  desc <- utils::packageDescription("hydroMetrics")

  expect_match(desc$Maintainer, "pritamparida432@gmail.com", fixed = TRUE)
  expect_match(desc$URL, "https://github.com/Arcblade-02/hydroMetrics", fixed = TRUE)
  expect_match(desc$BugReports, "https://github.com/Arcblade-02/hydroMetrics/issues", fixed = TRUE)

  expect_true(is.function(utils::getS3method("print", "hydro_metrics")))
  expect_true(is.function(utils::getS3method("print", "hydro_metrics_batch")))
  expect_true(is.function(utils::getS3method("print", "hydro_preproc")))
  expect_true(all(c("gof", "ggof", "preproc") %in% getNamespaceExports("hydroMetrics")))
  expect_true("rmsle" %in% getNamespaceExports("hydroMetrics"))
  expect_false(any(c("sae", "evs", "rae", "rrse") %in% getNamespaceExports("hydroMetrics")))
})

test_that("KGE component metadata separates KGE-specific and standard-correlation provenance honestly", {
  refs <- hydroMetrics:::list_metrics()
  refs <- refs[match(c("alpha", "beta", "r"), refs$id), c("id", "references")]

  expect_true(all(grepl("\\(2009\\)", refs$references[refs$id %in% c("alpha", "beta")])))
  expect_match(refs$references[refs$id == "r"], "Pearson")
  expect_match(refs$references[refs$id == "r"], "KGE correlation component")
})
