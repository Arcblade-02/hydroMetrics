test_that("preproc returns hydro_preproc for numeric input", {
  out <- preproc(c(1, NA, 3, 4), c(1, 2, 3, 5), na_strategy = "remove")

  expect_s3_class(out, "hydro_preproc")
  expect_equal(out$sim, c(1, 3, 4))
  expect_equal(out$obs, c(1, 3, 5))
  expect_identical(out$n_original, 4L)
  expect_identical(out$n_aligned, 4L)
  expect_identical(out$n_removed_na, 1L)
  expect_identical(out$transform_applied, "none")
  expect_true(is.list(out$epsilon_details))
})

test_that("preproc aligns zoo inputs", {
  skip_if_not_installed("zoo")

  sim <- zoo::zoo(c(1, 2, 3), order.by = as.Date("2020-01-01") + 0:2)
  obs <- zoo::zoo(c(10, 20, 30), order.by = as.Date("2020-01-02") + 0:2)

  out <- preproc(sim, obs, na_strategy = "fail")

  expect_equal(out$sim, c(2, 3))
  expect_equal(out$obs, c(10, 20))
  expect_equal(length(out$index), 2L)
  expect_identical(out$n_original, 3L)
  expect_identical(out$n_aligned, 2L)
})

test_that("preproc aligns xts inputs", {
  skip_if_not_installed("xts")

  sim <- xts::xts(c(2, 4, 6), order.by = as.Date("2021-01-01") + 0:2)
  obs <- xts::xts(c(1, 3, 5), order.by = as.Date("2021-01-02") + 0:2)

  out <- preproc(sim, obs, na_strategy = "fail")

  expect_equal(out$sim, c(4, 6))
  expect_equal(out$obs, c(1, 3))
  expect_identical(out$n_aligned, 2L)
})

test_that("preproc supports NA strategies", {
  sim <- c(1, NA, 3)
  obs <- c(1, 2, 3)

  expect_error(preproc(sim, obs, na_strategy = "fail"), "Missing values found")
  out_remove <- preproc(sim, obs, na_strategy = "remove")
  out_pairwise <- preproc(sim, obs, na_strategy = "pairwise")

  expect_identical(out_remove$sim, c(1, 3))
  expect_identical(out_pairwise$sim, out_remove$sim)
  expect_identical(out_pairwise$n_removed_na, out_remove$n_removed_na)
})

test_that("preproc supports transform and epsilon modes", {
  out <- preproc(
    sim = c(0, 1),
    obs = c(1, 2),
    na_strategy = "fail",
    transform = "log",
    epsilon_mode = "constant",
    epsilon = 0.5
  )

  expect_equal(out$sim, log(c(0.5, 1.5)))
  expect_equal(out$obs, log(c(1.5, 2.5)))
  expect_identical(out$transform_applied, "log")
  expect_true(isTRUE(out$epsilon_details$applied))
})

test_that("preproc supports formal compatibility aliases", {
  out_alias <- preproc(
    sim = c(0, NA, 1),
    obs = c(1, 2, 2),
    na.rm = TRUE,
    transform = "log",
    epsilon.type = "constant",
    epsilon.value = 0.5
  )
  out_native <- preproc(
    sim = c(0, NA, 1),
    obs = c(1, 2, 2),
    na_strategy = "remove",
    transform = "log",
    epsilon_mode = "constant",
    epsilon = 0.5
  )

  expect_equal(out_alias$sim, out_native$sim)
  expect_equal(out_alias$obs, out_native$obs)
  expect_identical(out_alias$epsilon_details$mode, "constant")
})

test_that("preproc rejects matrix-like public inputs with a stable error", {
  sim <- cbind(a = c(1, 2), b = c(3, 4))
  obs <- cbind(a = c(1, 2), b = c(3, 5))

  expect_error(
    preproc(sim, obs),
    "must be numeric, ts, zoo, or xts"
  )
})
