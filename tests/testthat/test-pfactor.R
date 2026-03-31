test_that("pfactor with tol=0 counts exact matches only", {
  obs <- c(1, 2, 3)
  sim <- c(1, 2.01, 3)

  expect_equal(pfactor(sim, obs, tol = 0), 2 / 3)
})

test_that("pfactor tol=0.1 example returns 2/3", {
  obs <- c(10, 10, 10)
  sim <- c(9, 11, 12)

  expect_equal(pfactor(sim, obs, tol = 0.1), 2 / 3)
})

test_that("pfactor uses absolute tolerance tol for obs == 0", {
  obs <- c(0, 0, 10)
  sim <- c(0.05, 0.2, 9.5)

  expect_equal(pfactor(sim, obs, tol = 0.1), 2 / 3)
})

test_that("pfactor errors for negative tolerance", {
  expect_error(
    pfactor(sim = c(1, 2, 3), obs = c(1, 2, 3), tol = -0.1),
    "non-negative numeric scalar"
  )
})

test_that("pfactor errors when no valid data remain after NA removal", {
  expect_error(
    pfactor(sim = c(NA_real_, NA_real_), obs = c(NA_real_, NA_real_)),
    "At least 1 valid paired value"
  )
})

test_that("registered pfactor metric uses default tolerance", {
  obs <- c(10, 10, 10)
  sim <- c(9, 11, 12)

  out <- evaluate_metrics(sim, obs, "pfactor")
  expect_equal(out$value[[1]], 2 / 3)
})
