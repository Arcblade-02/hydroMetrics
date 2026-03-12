test_that("valindex is a thin wrapper over gof(methods = fun)", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)

  out <- valindex(sim, obs, fun = c("NSE", "rmse"))
  ref <- gof(sim, obs, methods = c("NSE", "rmse"))

  expect_s3_class(out, "hydro_metrics")
  expect_equal(as.numeric(out), as.numeric(ref))
  expect_identical(names(out), names(ref))
  expect_identical(attr(out, "n_obs"), attr(ref, "n_obs"))
  expect_equal(attr(out, "meta"), attr(ref, "meta"))
  expect_equal(as.numeric(out), as.numeric(ref))
})

test_that("valindex supports multi-series inputs through gof", {
  sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs <- cbind(a = c(1, 2, 1), b = c(2, 2, 3))

  out <- valindex(sim, obs, fun = c("rmse", "pbias"))

  expect_s3_class(out, "hydro_metrics")
  expect_true(is.matrix(out))
  expect_identical(rownames(out), c("rmse", "pbias"))
})

test_that("valindex errors when fun is missing", {
  expect_error(
    valindex(c(1, 2, 3), c(1, 2, 1)),
    "`fun` must be provided"
  )
})
