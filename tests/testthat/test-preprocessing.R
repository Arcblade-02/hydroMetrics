test_that("hm_prepare aligns zoo indices and returns deterministic metadata", {
  skip_if_not_installed("zoo")

  sim_idx <- as.Date("2021-01-01") + 0:3
  obs_idx <- as.Date("2021-01-03") + 0:3
  sim <- zoo::zoo(c(1, 2, 3, 4), order.by = sim_idx)
  obs <- zoo::zoo(c(30, 40, 50, 60), order.by = obs_idx)

  out <- .hm_prepare_inputs(sim, obs, na_strategy = "fail")

  expect_equal(out$sim, c(3, 4))
  expect_equal(out$obs, c(30, 40))
  expect_identical(
    out$meta,
    list(
      n_original = 4L,
      n_aligned = 2L,
      n_used = 2L,
      n_removed_na = 0L,
      transform = "none",
      epsilon_mode = "constant"
    )
  )
})

test_that("hm_prepare aligns xts indices", {
  skip_if_not_installed("xts")

  idx_sim <- as.Date("2022-01-01") + 0:2
  idx_obs <- as.Date("2022-01-02") + 0:2
  sim <- xts::xts(c(2, 4, 6), order.by = idx_sim)
  obs <- xts::xts(c(1, 3, 5), order.by = idx_obs)

  out <- .hm_prepare_inputs(sim, obs, na_strategy = "fail")

  expect_equal(out$sim, c(4, 6))
  expect_equal(out$obs, c(1, 3))
  expect_identical(out$meta$n_aligned, 2L)
})

test_that("hm_prepare NA strategies behave as specified", {
  sim <- c(1, NA, 3, 4)
  obs <- c(1, 2, NA, 4)

  expect_error(
    .hm_prepare_inputs(sim, obs, na_strategy = "fail"),
    "Missing values found"
  )

  removed <- .hm_prepare_inputs(sim, obs, na_strategy = "remove")
  pairwise <- .hm_prepare_inputs(sim, obs, na_strategy = "pairwise")

  expect_identical(removed$sim, c(1, 4))
  expect_identical(removed$obs, c(1, 4))
  expect_identical(removed$meta$n_removed_na, 2L)
  expect_identical(removed$meta$n_used, 2L)

  expect_identical(pairwise$sim, removed$sim)
  expect_identical(pairwise$obs, removed$obs)
  expect_identical(pairwise$meta$n_removed_na, removed$meta$n_removed_na)
})

test_that("hm_prepare supports transform and epsilon modes", {
  out_log <- .hm_prepare_inputs(
    sim = c(0, 1),
    obs = c(1, 2),
    na_strategy = "fail",
    transform = "log",
    epsilon_mode = "constant",
    epsilon = 0.5
  )
  expect_equal(out_log$sim, log(c(0.5, 1.5)))
  expect_equal(out_log$obs, log(c(1.5, 2.5)))

  out_sqrt <- .hm_prepare_inputs(
    sim = c(-1, 1),
    obs = c(2, 3),
    na_strategy = "fail",
    transform = "sqrt",
    epsilon_mode = "auto_min_positive",
    epsilon_factor = 1
  )
  expect_equal(out_sqrt$sim, sqrt(c(0, 2)))
  expect_equal(out_sqrt$obs, sqrt(c(3, 4)))

  out_recip <- .hm_prepare_inputs(
    sim = c(0, 2),
    obs = c(2, 2),
    na_strategy = "fail",
    transform = "reciprocal",
    epsilon_mode = "obs_mean_factor",
    epsilon_factor = 1
  )
  expect_equal(out_recip$sim, c(1 / 2, 1 / 4))
  expect_equal(out_recip$obs, c(1 / 4, 1 / 4))
})

test_that("hm_prepare transform validation catches invalid epsilon setup", {
  expect_error(
    .hm_prepare_inputs(
      sim = c(0, -1),
      obs = c(0, -2),
      transform = "log",
      epsilon_mode = "auto_min_positive"
    ),
    "No positive values available"
  )
})

test_that("hm_prepare errors on zero-length inputs", {
  expect_error(
    .hm_prepare_inputs(numeric(0), numeric(0)),
    "At least 1 paired value is required"
  )
})

test_that("hm_prepare errors on ts mismatch", {
  sim <- stats::ts(1:6, frequency = 12)
  obs <- stats::ts(1:4, frequency = 12)

  expect_error(
    .hm_prepare_inputs(sim, obs),
    "identical frequency and length"
  )
})
