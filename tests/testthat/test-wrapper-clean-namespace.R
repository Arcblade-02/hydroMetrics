test_that("clean namespace access exposes the intended wrapper surface", {
  exports <- getNamespaceExports("hydroMetrics")
  expected <- c("NSE", "KGE", "RMSE", "R2", "NRMSE", "PBIAS", "gof", "ggof", "preproc", "valindex")

  expect_true(all(expected %in% exports))
  for (name in expected) {
    expect_true(exists(name, envir = asNamespace("hydroMetrics"), inherits = FALSE), info = name)
  }
})

test_that("clean namespace wrapper calls succeed without package attachment", {
  sim <- c(1, 2, 3, 5)
  obs <- c(1, 2, 2, 4)

  nse <- getExportedValue("hydroMetrics", "NSE")
  kge <- getExportedValue("hydroMetrics", "KGE")
  rmse <- getExportedValue("hydroMetrics", "RMSE")
  r2 <- getExportedValue("hydroMetrics", "R2")
  nrmse <- getExportedValue("hydroMetrics", "NRMSE")
  pbias_fun <- getExportedValue("hydroMetrics", "PBIAS")

  expect_type(nse(sim, obs), "double")
  expect_type(kge(sim, obs), "double")
  expect_equal(rmse(sim, obs), sqrt(0.5), tolerance = 1e-12)
  expect_equal(r2(sim, obs), 0.9398496240601504, tolerance = 1e-12)
  expect_equal(nrmse(sim, obs, norm = "mean"), 0.31426968052735443, tolerance = 1e-12)
  expect_equal(pbias_fun(sim, obs), 22.22222222222222, tolerance = 1e-12)
})

test_that("clean namespace access keeps ggof explicit as non-plotting", {
  batch <- getExportedValue("hydroMetrics", "ggof")(c(1, 2, 3), c(1, 2, 2), methods = "NSE")

  expect_s3_class(batch, "hydro_metrics_batch")
  expect_true(is.data.frame(batch))
  expect_identical(names(batch), c("model", "metric", "value", "n_obs"))
})
