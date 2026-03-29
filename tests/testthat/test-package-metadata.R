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
  expect_false(any(c("sae", "evs") %in% getNamespaceExports("hydroMetrics")))
})

test_that("KGE component reference metadata remains literature-backed", {
  refs <- hydroMetrics:::list_metrics()
  refs <- refs[refs$id %in% c("alpha", "beta", "r"), "references", drop = TRUE]

  expect_true(all(grepl("\\(2009\\)", refs)))
})
