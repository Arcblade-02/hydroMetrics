test_that("metric_nse matches hydroGOF::NSE", {
  skip_if_not_installed("hydroGOF")

  sim <- c(1, 2, 3, 4, 5)
  obs <- c(1.1, 1.9, 3.2, 3.8, 5.1)

  expect_equal(
    hydroMetrics:::metric_nse(sim, obs),
    hydroGOF::NSE(sim, obs),
    tolerance = sqrt(.Machine$double.eps)
  )
})

test_that("selected exported hydroGOF-overlap wrappers match hydroGOF references", {
  skip_if_not_installed("hydroGOF")

  sim <- c(1.1, 2.2, 2.8, 4.1, 5.2)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  tol <- sqrt(.Machine$double.eps)

  expect_equal(NSeff(sim, obs), hydroGOF::NSE(sim, obs), tolerance = tol)
  expect_equal(mNSeff(sim, obs), hydroGOF::mNSE(sim, obs), tolerance = tol)
  expect_equal(mae(sim, obs), hydroGOF::mae(sim, obs), tolerance = tol)
  expect_equal(rsr(sim, obs), hydroGOF::rsr(sim, obs), tolerance = tol)
})

test_that("selected hydroGOF-overlap metrics are intentionally divergent", {
  skip_if_not_installed("hydroGOF")
  skip_if_not_installed("zoo")

  tol <- sqrt(.Machine$double.eps)
  sim <- c(1.1, 2.2, 2.8, 4.1, 5.2)
  obs <- c(1.0, 2.0, 3.0, 4.0, 5.0)

  expect_gt(abs(rNSeff(sim, obs) - hydroGOF::rNSE(sim, obs)), tol)
  expect_gt(abs(wsNSeff(sim, obs) - hydroGOF::wsNSE(sim, obs)), tol)

  hm_pbias <- pbias(sim, obs)
  hg_pbias <- hydroGOF::pbias(sim, obs)
  expect_gt(abs(hm_pbias - hg_pbias), tol)
  expect_equal(round(hm_pbias, 1), hg_pbias, tolerance = tol)

  idx_apfb <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01", "2021-06-01"))
  sim_apfb <- zoo::zoo(c(12, 15, 25, 35), order.by = idx_apfb)
  obs_apfb <- zoo::zoo(c(10, 10, 20, 30), order.by = idx_apfb)
  hm_apfb <- as.numeric(APFB(sim_apfb, obs_apfb))
  hg_apfb <- as.numeric(hydroGOF::APFB(sim_apfb, obs_apfb))
  expect_gt(abs(hm_apfb - hg_apfb), tol)
  expect_equal(hm_apfb / 100, hg_apfb, tolerance = tol)

  idx_hfb <- as.Date("2020-01-01") + 0:29
  sim_hfb <- zoo::zoo(2:31, order.by = idx_hfb)
  obs_hfb <- zoo::zoo(1:30, order.by = idx_hfb)
  hm_hfb <- as.numeric(HFB(sim_hfb, obs_hfb))
  hg_hfb <- as.numeric(hydroGOF::HFB(sim_hfb, obs_hfb))
  expect_true(is.finite(hm_hfb))
  expect_true(is.finite(hg_hfb))
  expect_gt(abs(hm_hfb - hg_hfb), tol)
})
