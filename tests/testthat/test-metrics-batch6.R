test_that("batch6 metrics return expected hm_result structure and ids", {
  out <- evaluate_metrics(
    sim = c(1, 2, 3),
    obs = c(1, 2, 1),
    metrics = c("kgekm", "kgelf", "kgenp", "pbiasfdc")
  )

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(colnames(out), c("metric", "name", "value"))
  expect_identical(out$metric, c("kgekm", "kgelf", "kgenp", "pbiasfdc"))
})

test_that("batch6 perfect-fit values are correct", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 3, 4)

  out <- evaluate_metrics(sim, obs, c("kgekm", "kgelf", "kgenp", "pbiasfdc"))
  values <- setNames(out$value, out$metric)

  expect_equal(values[["kgekm"]], 1)
  expect_equal(values[["kgelf"]], 1)
  expect_equal(values[["kgenp"]], 1)
  expect_equal(values[["pbiasfdc"]], 0)
})

test_that("kgekm matches inline formula", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)

  r <- stats::cor(sim, obs)
  gamma <- (stats::sd(sim) / mean(sim)) / (stats::sd(obs) / mean(obs))
  beta <- mean(sim) / mean(obs)
  expected <- 1 - sqrt((r - 1)^2 + (gamma - 1)^2 + (beta - 1)^2)

  out <- evaluate_metrics(sim, obs, "kgekm")
  expect_equal(out$value[[1]], expected)
})

test_that("kgelf matches inline transformed KGE formula", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  sim_lf <- log1p(sim)
  obs_lf <- log1p(obs)

  r <- stats::cor(sim_lf, obs_lf)
  alpha <- stats::sd(sim_lf) / stats::sd(obs_lf)
  beta <- mean(sim_lf) / mean(obs_lf)
  expected <- 1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)

  out <- evaluate_metrics(sim, obs, "kgelf")
  expect_equal(out$value[[1]], expected)
})

test_that("kgenp matches inline nonparametric formula", {
  sim <- c(1, 2, 3, 5)
  obs <- c(1, 2, 1, 4)

  r <- stats::cor(sim, obs, method = "spearman")
  alpha <- stats::IQR(sim) / stats::IQR(obs)
  beta <- stats::median(sim) / stats::median(obs)
  expected <- 1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)

  out <- evaluate_metrics(sim, obs, "kgenp")
  expect_equal(out$value[[1]], expected)
})

test_that("pbiasfdc matches inline quantile-grid formula", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  p <- seq(0.01, 0.99, by = 0.01)
  qobs <- stats::quantile(obs, probs = 1 - p, type = 7, names = FALSE)
  qsim <- stats::quantile(sim, probs = 1 - p, type = 7, names = FALSE)
  expected <- 100 * sum(qsim - qobs) / sum(qobs)

  out <- evaluate_metrics(sim, obs, "pbiasfdc")
  expect_equal(out$value[[1]], expected)
})

test_that("skge works for monthly ts input", {
  obs_ts <- stats::ts(c(1:12, 2:13), start = c(2000, 1), frequency = 12)
  sim_ts <- obs_ts

  out <- evaluate_metrics(sim_ts, obs_ts, "skge")
  expect_true(is.numeric(out$value[[1]]))
  expect_true(out$value[[1]] <= 1)
  expect_equal(out$value[[1]], 1)
})

test_that("skge falls back to KGE for plain numeric vectors", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 2, 3, 4)

  out <- evaluate_metrics(sim, obs, "skge")
  expect_equal(out$value[[1]], 1)
})

test_that("kgelf errors on negative flows", {
  expect_error(
    evaluate_metrics(c(-0.1, 1, 2), c(1, 1, 2), "kgelf"),
    "negative values"
  )
})

test_that("kgekm errors on zero mean or zero sd observed series", {
  expect_error(
    evaluate_metrics(c(-1, 1), c(-1, 1), "kgekm"),
    "mean\\(sim\\) == 0 or mean\\(obs\\) == 0"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "kgekm"),
    "sd\\(obs\\) == 0"
  )
})

test_that("kgenp errors on invalid observed robust moments", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "kgenp"),
    "IQR\\(obs\\) == 0"
  )
  expect_error(
    evaluate_metrics(c(0, 1, 2), c(0, 1, 0), "kgenp"),
    "median\\(obs\\) == 0"
  )
})

test_that("pbiasfdc errors when sum(Qobs) is zero", {
  expect_error(
    evaluate_metrics(c(0, 0, 0), c(0, 0, 0), "pbiasfdc"),
    "sum\\(Qobs\\) == 0"
  )
})
