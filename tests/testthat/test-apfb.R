test_that("APFB computes annual peak-flow bias for zoo input", {
  skip_if_not_installed("zoo")

  idx <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
  obs <- zoo::zoo(c(10, 20, 30, 40), order.by = idx)
  sim <- zoo::zoo(c(12, 18, 33, 35), order.by = idx)

  out <- APFB(sim, obs)
  expect_s3_class(out, "hydro_metric_scalar")
  expect_s3_class(out, "numeric")
  expect_equal(as.numeric(out), -11.25)
  expect_identical(attr(out, "metric"), "APFB")
  expect_identical(attr(out, "n_obs"), 4L)
  expect_identical(attr(out, "meta")$years, 2L)
  expect_identical(attr(out, "meta")$aligned, TRUE)
  expect_identical(attr(out, "meta")$na_method, "remove")
  expect_true(is.call(attr(out, "call")))
})

test_that("APFB supports xts input", {
  skip_if_not_installed("xts")

  idx <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
  obs <- xts::xts(c(10, 20, 30, 40), order.by = idx)
  sim <- xts::xts(c(12, 18, 33, 35), order.by = idx)

  out <- APFB(sim, obs)
  expect_equal(as.numeric(out), -11.25)
  expect_identical(attr(out, "meta")$years, 2L)
})

test_that("APFB errors when time index is absent", {
  expect_error(
    APFB(c(1, 2, 3), c(1, 2, 3)),
    "requires zoo/xts inputs"
  )
})

test_that("APFB errors when fewer than two years remain", {
  skip_if_not_installed("zoo")

  idx <- as.Date(c("2020-01-01", "2020-02-01", "2020-03-01"))
  obs <- zoo::zoo(c(1, 2, 3), order.by = idx)
  sim <- zoo::zoo(c(1, 2, 4), order.by = idx)

  expect_error(
    APFB(sim, obs),
    "at least 2 years"
  )
})

test_that("APFB returns a numerically coercible scalar", {
  skip_if_not_installed("zoo")

  idx <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
  obs <- zoo::zoo(c(10, 20, 30, 40), order.by = idx)
  sim <- zoo::zoo(c(12, 18, 33, 35), order.by = idx)

  out <- APFB(sim, obs)
  expect_type(as.numeric(out), "double")
  expect_length(as.numeric(out), 1L)
})

test_that("APFB supports partially overlapping zoo inputs after deterministic alignment", {
  skip_if_not_installed("zoo")

  sim <- zoo::zoo(
    c(8, 12, 18, 25, 20, 27),
    order.by = as.Date(c(
      "2020-01-01",
      "2020-06-01",
      "2021-01-01",
      "2021-06-01",
      "2022-01-01",
      "2022-06-01"
    ))
  )
  obs <- zoo::zoo(
    c(11, 19, 24, 18, 30, 29),
    order.by = as.Date(c(
      "2020-06-01",
      "2021-01-01",
      "2021-06-01",
      "2022-01-01",
      "2022-06-01",
      "2022-12-01"
    ))
  )

  expect_no_error(
    out <- APFB(sim, obs)
  )
  expect_s3_class(out, "hydro_metric_scalar")
  expect_true(is.finite(as.numeric(out)))
  expect_identical(attr(out, "meta")$years, 3L)
  expect_identical(attr(out, "meta")$aligned, FALSE)
})
