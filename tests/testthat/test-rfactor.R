test_that("rfactor matches hand-calculated value", {
  obs <- c(1, 2, 3)
  sim <- c(1, 1, 4)
  expected <- (2 / 3) / 2

  expect_warning(
    expect_equal(rfactor(sim, obs), expected),
    "deprecated"
  )

  expect_warning(out <- evaluate_metrics(sim, obs, "rfactor"), "deprecated")
  expect_identical(out$metric, "mean_absolute_error_ratio")
  expect_equal(out$value[[1]], expected)
})

test_that("rfactor errors when denominator is zero", {
  expect_warning(
    expect_error(
      rfactor(sim = c(0, 1, 2), obs = c(0, 0, 0)),
      "mean\\(abs\\(obs\\)\\) is zero"
    ),
    "deprecated"
  )
})

test_that("rfactor errors when no valid data remain after NA removal", {
  expect_error(
    rfactor(sim = c(NA_real_, NA_real_), obs = c(NA_real_, NA_real_)),
    "At least 1 valid paired value"
  )
})

test_that("rfactor NA handling uses complete paired values", {
  obs <- c(1, NA, 3)
  sim <- c(1, 2, NA)

  expect_warning(
    expect_equal(rfactor(sim, obs, na.rm = TRUE), 0),
    "deprecated"
  )
})
