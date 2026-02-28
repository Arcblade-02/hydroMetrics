test_that("preproc removes NA rows for vector inputs", {
  sim <- c(1, NA, 3, 4)
  obs <- c(1, 2, NA, 4)

  out <- preproc(sim, obs)

  expect_equal(out$sim, c(1, 4))
  expect_equal(out$obs, c(1, 4))
  expect_equal(out$n, 2L)
  expect_equal(out$removed, 2L)
})

test_that("preproc errors when all rows are removed", {
  expect_error(
    preproc(c(NA_real_, NA_real_), c(NA_real_, NA_real_)),
    "No valid rows remain"
  )
})

test_that("preproc aligns and filters matrix-like inputs", {
  sim <- data.frame(
    a = c(1, NA, 3),
    b = c(4, 5, 6)
  )
  obs <- matrix(
    c(
      1, 4,
      2, 5,
      3, NA
    ),
    nrow = 3,
    byrow = TRUE
  )
  colnames(obs) <- c("a", "b")

  out <- preproc(sim, obs, as = "matrix")

  expect_true(is.matrix(out$sim))
  expect_true(is.matrix(out$obs))
  expect_equal(dim(out$sim), c(1, 2))
  expect_equal(dim(out$obs), c(1, 2))
  expect_equal(out$n, c(a = 1L, b = 1L))
  expect_equal(out$removed, 2L)
})

test_that("preproc pairwise mode currently matches complete-case filtering", {
  sim <- c(1, NA, 3, 4)
  obs <- c(1, 2, NA, 4)

  out_complete <- preproc(sim, obs, keep = "complete")
  out_pairwise <- preproc(sim, obs, keep = "pairwise")

  expect_identical(out_pairwise$sim, out_complete$sim)
  expect_identical(out_pairwise$obs, out_complete$obs)
  expect_identical(out_pairwise$n, out_complete$n)
  expect_identical(out_pairwise$removed, out_complete$removed)
})

test_that("preproc handles zoo inputs", {
  skip_if_not_installed("zoo")

  idx <- as.Date("2020-01-01") + 0:3
  sim <- zoo::zoo(c(1, NA, 3, 4), order.by = idx)
  obs <- zoo::zoo(c(1, 2, NA, 4), order.by = idx)

  out <- preproc(sim, obs, as = "matrix")

  expect_true(is.matrix(out$sim))
  expect_true(is.matrix(out$obs))
  expect_equal(out$sim[, 1], c(1, 4))
  expect_equal(out$obs[, 1], c(1, 4))
  expect_equal(out$n, c(2L))
  expect_equal(out$removed, 2L)
})
