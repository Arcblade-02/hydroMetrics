test_that("gof returns named numeric vector for single series", {
  out <- gof(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    methods = c("NSE", "rmse", "rPearson")
  )

  expect_true(is.numeric(out))
  expect_true(all(c("NSE", "rmse", "rPearson") %in% names(out)))
})

test_that("gof returns numeric matrix for multi-series input", {
  sim <- cbind(a = c(1, 2, 3), b = c(2, 3, 4))
  obs <- cbind(a = c(1, 2, 1), b = c(2, 2, 3))

  out <- gof(sim = sim, obs = obs, methods = c("rmse", "pbias"))

  expect_true(is.matrix(out))
  expect_true(is.numeric(out))
  expect_identical(rownames(out), c("rmse", "pbias"))
  expect_identical(colnames(out), c("a", "b"))
})

test_that("gof errors for unknown method names with available list hint", {
  expect_error(
    gof(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = "not_a_metric"),
    "available"
  )
})

test_that("ggof errors gracefully when ggplot2 is missing", {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    skip("ggplot2 is installed; skipping missing-package behavior check.")
  }

  expect_error(
    ggof(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = c("NSE", "rmse")),
    "ggplot2 is required"
  )
})

test_that("ggof returns ggplot object when ggplot2 is installed", {
  skip_if_not_installed("ggplot2")

  p <- ggof(sim = c(1, 2, 3), obs = c(1, 2, 1), methods = c("NSE", "rmse"))
  expect_s3_class(p, "ggplot")
})
