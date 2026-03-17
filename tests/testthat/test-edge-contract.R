test_that("gof errors on incompatible public input shapes and invalid flags", {
  expect_error(
    gof(c(1, 2, 3), cbind(a = c(1, 2, 3))),
    "must both be single-series or both be matrix-like inputs"
  )

  expect_error(
    gof(c(1, 2, 3), c(1, 2, 3), extended = 1),
    "`extended` must be TRUE or FALSE"
  )
})

test_that("gof errors on invalid compatibility alias values", {
  expect_error(
    gof(c(1, 2, 3), c(1, 2, 3), na.rm = "yes"),
    "`na.rm` must be TRUE or FALSE"
  )

  expect_error(
    gof(c(1, 2, 3), c(1, 2, 3), epsilon.type = "bad"),
    "`epsilon.type` must be one of"
  )
})

test_that("ggof and valindex preserve documented error propagation from gof", {
  expect_error(
    ggof(c(1, 2, 3), c(1, 2, 3), methods = "not_a_metric"),
    "Unknown metric"
  )

  expect_error(
    valindex(c(1, NA, 3), c(1, 2, 3), fun = "rmse", na.rm = FALSE),
    "Missing values found"
  )
})
