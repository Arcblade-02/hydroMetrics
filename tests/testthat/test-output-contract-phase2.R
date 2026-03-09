test_that("Phase 2 output contract covers hm_result creation, print, and coercion", {
  df <- data.frame(metric = "nse", value = 1)
  out <- hm_result(df)

  expect_s3_class(out, "hm_result")
  expect_identical(as.data.frame(out), df)
  expect_output(print(out), "<hm_result: 1 metric")
  expect_error(hm_result(1:3), "`x` must be a data.frame")
})

test_that("Phase 2 output contract covers hydro_metrics print and numeric coercion", {
  out <- gof(c(1, 2, 3, 4), c(1, 2, 2, 4), methods = c("NSE", "rmse"))

  expect_s3_class(out, "hydro_metrics")
  expect_identical(names(as.numeric(out)), NULL)
  expect_equal(as.double(out), as.numeric(out))
  expect_output(print(out), "NSE")
})

test_that("Phase 2 output contract covers ggof single and multi-series formatting", {
  single <- ggof(c(1, 2, 3, 4), c(1, 2, 2, 4), methods = c("NSE", "rmse"), include_meta = TRUE)
  multi <- ggof(
    sim = unname(cbind(c(1, 2, 3), c(2, 3, 4))),
    obs = unname(cbind(c(1, 2, 2), c(2, 2, 3))),
    methods = "NSE",
    include_meta = TRUE
  )

  expect_s3_class(single, "hydro_metrics_batch")
  expect_true(all(c("model", "metric", "value", "n_obs", "transform", "na_strategy", "epsilon_mode") %in% names(single)))
  expect_s3_class(multi, "hydro_metrics_batch")
  expect_true(all(multi$model %in% c("model1", "model2")))
  expect_output(print(multi), "model")
})

test_that("Phase 2 output contract covers hydro_preproc formatting", {
  out <- preproc(c(1, NA, 3), c(1, 2, 3), na.rm = TRUE)

  expect_s3_class(out, "hydro_preproc")
  expect_equal(out$n_removed_na, 1L)
  expect_output(print(out), "<hydro_preproc:")
})

test_that("Phase 2 output contract covers default gof method dispatch and slot access", {
  out <- gof(c(1, 2, 3, 4), c(1, 2, 2, 4))

  expect_s3_class(out, "hydro_metrics")
  expect_true("NSE" %in% names(out))
  expect_type(out$NSE, "double")
  expect_true(all(c("transform", "na_strategy", "epsilon_mode") %in% names(out$meta)))
})
