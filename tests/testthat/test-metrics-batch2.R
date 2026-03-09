test_that("batch2 metrics return expected hm_result structure and ids", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("mae", "mse", "nrmse", "r", "r2")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("mae", "mse", "nrmse", "r", "r2"))
})

test_that("batch2 perfect-fit case returns expected values", {
  out <- evaluate_metrics(
    sim = c(2, 4, 6),
    obs = c(2, 4, 6),
    metrics = c("mae", "mse", "nrmse", "r", "r2")
  )
  values <- setNames(out$value, out$metric)

  expect_equal(values[["mae"]], 0)
  expect_equal(values[["mse"]], 0)
  expect_equal(values[["nrmse"]], 0)
  expect_equal(values[["r"]], 1)
  expect_equal(values[["r2"]], 1)
})

test_that("batch2 metrics match hand-computable vectors", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)

  out <- evaluate_metrics(sim = sim, obs = obs, metrics = c("mae", "mse", "nrmse", "r", "r2"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["mae"]], 2 / 3)
  expect_equal(values[["mse"]], 4 / 3)
  expect_equal(values[["nrmse"]], sqrt(4 / 3) / mean(obs))

  expected_r <- stats::cor(sim, obs)
  expect_equal(values[["r"]], expected_r)
  expect_equal(values[["r2"]], expected_r^2)
})

test_that("nrmse errors when mean(obs) is zero", {
  expect_error(
    evaluate_metrics(sim = c(1, 2), obs = c(-1, 1), metrics = "nrmse"),
    "mean\\(obs\\)|divide by zero"
  )
})

test_that("r and r2 error for constant series", {
  expect_error(
    evaluate_metrics(sim = c(1, 1, 1), obs = c(1, 2, 3), metrics = "r"),
    "zero variance|constant|sd"
  )
  expect_error(
    evaluate_metrics(sim = c(1, 2, 3), obs = c(4, 4, 4), metrics = "r2"),
    "constant|sd"
  )
})
