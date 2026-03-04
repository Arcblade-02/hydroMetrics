test_that("ggof returns hydro_metrics_batch data.frame with expected columns", {
  out <- ggof(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = c("NSE", "rmse"))

  expect_s3_class(out, "hydro_metrics_batch")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("model", "metric", "value", "n_obs"))
  expect_identical(out$model, c("model1", "model1"))
  expect_identical(out$metric, c("NSE", "rmse"))
  expect_true(all(out$n_obs == 3L))
})

test_that("ggof include_meta controls metadata columns", {
  out_no_meta <- ggof(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = "rmse",
    include_meta = FALSE
  )
  out_meta <- ggof(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = "rmse",
    include_meta = TRUE
  )

  expect_false(any(c("transform", "na_strategy", "epsilon_mode") %in% colnames(out_no_meta)))
  expect_true(all(c("transform", "na_strategy", "epsilon_mode") %in% colnames(out_meta)))
})

test_that("ggof returns model rows for matrix input", {
  sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs <- cbind(a = c(1, 2, 1), b = c(2, 2, 3))

  out <- ggof(sim = sim, obs = obs, methods = c("rmse", "pbias"))

  expect_identical(sort(unique(out$model)), c("a", "b"))
  expect_identical(sort(unique(out$metric)), c("pbias", "rmse"))
  expect_equal(nrow(out), 4L)
})
