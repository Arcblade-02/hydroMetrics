test_that("valindex returns deterministic scalar for vector inputs", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)

  out1 <- valindex(sim, obs, metrics = c("NSE", "rmse", "pbias"))
  out2 <- valindex(sim, obs, metrics = c("NSE", "rmse", "pbias"))

  expect_true(is.numeric(out1))
  expect_length(out1, 1L)
  expect_equal(out1, out2)
  expect_gte(out1, 0)
  expect_lte(out1, 1)
})

test_that("valindex returns one-row matrix for multi-series inputs", {
  sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs <- cbind(a = c(1, 2, 1), b = c(2, 2, 3))

  out <- valindex(sim, obs, metrics = c("NSE", "rmse", "pbias"))

  expect_true(is.matrix(out))
  expect_equal(dim(out), c(1, 2))
  expect_identical(rownames(out), "valindex")
  expect_identical(colnames(out), c("a", "b"))
  expect_true(all(out >= 0 & out <= 1))
})

test_that("valindex errors for unsupported metrics", {
  expect_error(
    valindex(c(1, 2, 3), c(1, 2, 1), metrics = c("cp")),
    "Unsupported metric"
  )
})

test_that("valindex validates weights", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  metrics <- c("NSE", "rmse", "pbias")

  expect_error(
    valindex(sim, obs, metrics = metrics, weights = c(1, 2)),
    "same length"
  )
  expect_error(
    valindex(sim, obs, metrics = metrics, weights = c(1, -1, 1)),
    "nonnegative"
  )
  expect_error(
    valindex(sim, obs, metrics = metrics, weights = c(0, 0, 0)),
    "positive sum"
  )
})
