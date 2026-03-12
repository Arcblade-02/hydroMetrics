test_that("rPearson matches base cor pearson", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  expected <- stats::cor(sim, obs, method = "pearson")

  expect_warning(
    out <- evaluate_metrics(sim, obs, "rpearson"),
    "deprecated"
  )
  expect_equal(out$value[[1]], expected)
})

test_that("rSpearman matches base cor spearman", {
  sim <- c(1, 2, 3, 4)
  obs <- c(1, 3, 2, 4)
  expected <- stats::cor(sim, obs, method = "spearman")

  out <- evaluate_metrics(sim, obs, "rspearman")
  expect_equal(out$value[[1]], expected)
})

test_that("rSD matches sd(sim)/sd(obs)", {
  sim <- c(1, 2, 3)
  obs <- c(1, 2, 1)
  expected <- stats::sd(sim) / stats::sd(obs)

  out <- evaluate_metrics(sim, obs, "rsd")
  expect_equal(out$value[[1]], expected)
})

test_that("rPearson and rSpearman error for constant observed series", {
  expect_warning(
    expect_error(
      evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "rpearson"),
      "undefined"
    ),
    "deprecated"
  )
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "rspearman"),
    "correlation undefined"
  )
})

test_that("rSD errors when sd(obs) is zero and allows sd(sim)==0", {
  expect_error(
    evaluate_metrics(c(1, 2, 3), c(2, 2, 2), "rsd"),
    "sd\\(obs\\) == 0"
  )

  out <- evaluate_metrics(c(3, 3, 3), c(1, 2, 3), "rsd")
  expect_equal(out$value[[1]], 0)
})
