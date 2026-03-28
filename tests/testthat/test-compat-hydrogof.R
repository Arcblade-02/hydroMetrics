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

  idx_hfb <- as.Date("2020-01-01") + 0:29
  sim_hfb <- zoo::zoo(2:31, order.by = idx_hfb)
  obs_hfb <- zoo::zoo(1:30, order.by = idx_hfb)
  hm_hfb <- as.numeric(HFB(sim_hfb, obs_hfb))
  hg_hfb <- as.numeric(hydroGOF::HFB(sim_hfb, obs_hfb))
  expect_true(is.finite(hm_hfb))
  expect_true(is.finite(hg_hfb))
  expect_gt(abs(hm_hfb - hg_hfb), tol)
})

test_that("next hydroGOF-overlap tranche matches on intended comparable cases", {
  skip_if_not_installed("hydroGOF")

  tol <- sqrt(.Machine$double.eps)
  cases <- list(
    list(
      sim = c(1.1, 2.2, 2.8, 4.1, 5.2),
      obs = c(1.0, 2.0, 3.0, 4.0, 5.0)
    ),
    list(
      sim = c(2, 4, 6, 8, 10),
      obs = c(1, 3, 5, 7, 9)
    ),
    list(
      sim = c(0.5, 1.5, 2.0, 3.5, 5.0),
      obs = c(1.0, 1.0, 2.5, 3.0, 4.5)
    )
  )

  for (case in cases) {
    out <- gof(case$sim, case$obs, methods = c("rmse", "mse", "ve", "kge"))

    expect_equal(out[["rmse"]], hydroGOF::rmse(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["mse"]], hydroGOF::mse(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["ve"]], hydroGOF::VE(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["kge"]], hydroGOF::KGE(case$sim, case$obs, method = "2009"), tolerance = tol)
  }
})

test_that("next hydroGOF-overlap tranche records intentional nrmse and r2 divergence", {
  skip_if_not_installed("hydroGOF")

  tol <- sqrt(.Machine$double.eps)
  cases <- list(
    list(
      sim = c(1.1, 2.2, 2.8, 4.1, 5.2),
      obs = c(1.0, 2.0, 3.0, 4.0, 5.0)
    ),
    list(
      sim = c(2, 4, 6, 8, 10),
      obs = c(1, 3, 5, 7, 9)
    ),
    list(
      sim = c(0.5, 1.5, 2.0, 3.5, 5.0),
      obs = c(1.0, 1.0, 2.5, 3.0, 4.5)
    )
  )

  for (case in cases) {
    out <- gof(case$sim, case$obs, methods = c("nrmse", "r2"))

    expect_gt(abs(out[["nrmse"]] - hydroGOF::nrmse(case$sim, case$obs)), tol)
    expect_gt(abs(out[["r2"]] - hydroGOF::R2(case$sim, case$obs)), tol)
  }
})

test_that("moderate hydroGOF-overlap tranche matches on intended comparable cases", {
  skip_if_not_installed("hydroGOF")

  tol <- sqrt(.Machine$double.eps)
  cases <- list(
    list(
      sim = c(1.1, 2.2, 2.8, 4.1, 5.2),
      obs = c(1.0, 2.0, 3.0, 4.0, 5.0)
    ),
    list(
      sim = c(2, 4, 6, 8, 10),
      obs = c(1, 3, 5, 7, 9)
    ),
    list(
      sim = c(0.5, 1.5, 2.0, 3.5, 5.0),
      obs = c(1.0, 1.0, 2.5, 3.0, 4.5)
    )
  )

  for (case in cases) {
    out <- gof(case$sim, case$obs, methods = c("me", "d", "md", "ubrmse", "rspearman", "cp"))

    expect_equal(out[["me"]], hydroGOF::me(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["d"]], hydroGOF::d(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["md"]], hydroGOF::md(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["ubrmse"]], hydroGOF::ubRMSE(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["rspearman"]], hydroGOF::rSpearman(case$sim, case$obs), tolerance = tol)
    expect_equal(out[["cp"]], hydroGOF::cp(case$sim, case$obs), tolerance = tol)
  }
})

test_that("direct hydroGOF-overlap tranche reconciles wnse, dr, and rd", {
  skip_if_not_installed("hydroGOF")

  tol <- sqrt(.Machine$double.eps)
  cases <- list(
    list(
      sim = c(1.1, 2.2, 2.8, 4.1, 5.2),
      obs = c(1.0, 2.0, 3.0, 4.0, 5.0)
    ),
    list(
      sim = c(2, 4, 6, 8, 10),
      obs = c(1, 3, 5, 7, 9)
    ),
    list(
      sim = c(0.5, 1.5, 2.0, 3.5, 5.0),
      obs = c(1.0, 1.0, 2.5, 3.0, 4.5)
    )
  )

  for (case in cases) {
    out <- gof(case$sim, case$obs, methods = c("wnse", "dr", "rd"))

    expect_equal(out[["wnse"]], hydroGOF::wNSE(case$sim, case$obs), tolerance = tol)
    expect_gt(abs(out[["dr"]] - hydroGOF::dr(case$sim, case$obs)), tol)
    expect_gt(abs(out[["rd"]] - hydroGOF::rd(case$sim, case$obs)), tol)
  }
})

test_that("specialized KGE-family overlap tranche is intentionally divergent", {
  skip_if_not_installed("hydroGOF")

  tol <- sqrt(.Machine$double.eps)
  cases <- list(
    list(
      sim = c(1.1, 2.2, 2.8, 4.1, 5.2),
      obs = c(1.0, 2.0, 3.0, 4.0, 5.0)
    ),
    list(
      sim = c(2, 4, 6, 8, 10),
      obs = c(1, 3, 5, 7, 9)
    ),
    list(
      sim = c(0.5, 1.5, 2.0, 3.5, 5.0),
      obs = c(1.0, 1.0, 2.5, 3.0, 4.5)
    )
  )

  for (case in cases) {
    out <- gof(case$sim, case$obs, methods = c("kgekm", "kgelf", "kgenp"))

    expect_gt(abs(out[["kgekm"]] - hydroGOF::KGEkm(case$sim, case$obs)), tol)
    expect_gt(abs(out[["kgelf"]] - hydroGOF::KGElf(case$sim, case$obs)), tol)
    expect_gt(abs(out[["kgenp"]] - hydroGOF::KGEnp(case$sim, case$obs)), tol)
  }
})

test_that("specialized seasonal KGE overlap tranche is intentionally divergent", {
  skip_if_not_installed("hydroGOF")
  skip_if_not_installed("zoo")

  tol <- sqrt(.Machine$double.eps)
  idx <- seq(as.Date("2020-01-01"), by = "month", length.out = 24)

  cases <- list(
    list(
      sim = zoo::zoo(
        c(1.2, 1.4, 1.8, 2.2, 2.4, 2.6, 2.5, 2.3, 2.0, 1.8, 1.5, 1.3,
          1.1, 1.5, 1.9, 2.1, 2.5, 2.7, 2.6, 2.4, 2.1, 1.7, 1.4, 1.2),
        idx
      ),
      obs = zoo::zoo(
        c(1.0, 1.3, 1.7, 2.0, 2.2, 2.5, 2.4, 2.2, 1.9, 1.7, 1.4, 1.1,
          1.0, 1.4, 1.8, 2.0, 2.3, 2.6, 2.5, 2.2, 1.8, 1.5, 1.2, 1.0),
        idx
      )
    ),
    list(
      sim = zoo::zoo(
        c(1.0, 1.2, 1.6, 2.1, 2.7, 3.0, 2.8, 2.4, 1.9, 1.5, 1.1, 0.9,
          2.0, 2.3, 2.8, 3.4, 4.0, 4.3, 4.1, 3.5, 2.8, 2.2, 1.7, 1.3),
        idx
      ),
      obs = zoo::zoo(
        c(1.1, 1.3, 1.7, 2.0, 2.4, 2.8, 2.7, 2.3, 1.8, 1.4, 1.1, 0.8,
          1.1, 1.4, 1.8, 2.1, 2.5, 2.9, 2.8, 2.4, 1.9, 1.5, 1.2, 0.9),
        idx
      )
    )
  )

  for (case in cases) {
    out <- gof(case$sim, case$obs, methods = "skge")

    expect_gt(abs(out[["skge"]] - hydroGOF::sKGE(case$sim, case$obs)), tol)
  }
})

test_that("remaining hydroGOF-overlap backlog metrics are divergent or not directly comparable", {
  skip_if_not_installed("hydroGOF")

  tol <- sqrt(.Machine$double.eps)
  sim <- c(1.1, 1.4, 1.8, 2.2, 2.6, 3.0, 3.4, 3.8, 4.1, 4.5)
  obs <- c(1.0, 1.3, 1.7, 2.0, 2.4, 2.8, 3.2, 3.6, 4.0, 4.3)

  expect_false("rsd" %in% getNamespaceExports("hydroGOF"))
  expect_false("RSD" %in% getNamespaceExports("hydroGOF"))

  expect_identical(names(formals(hydroGOF::pfactor.default))[1:3], c("x", "lband", "uband"))
  expect_identical(names(formals(hydroGOF::rfactor.default))[1:3], c("x", "lband", "uband"))
})
