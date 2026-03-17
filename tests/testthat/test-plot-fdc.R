test_that("plot_fdc errors cleanly when ggplot2 is unavailable", {
  testthat::local_mocked_bindings(
    .hm_plot_require_ggplot2 = function(helper_name = "plot_fdc") {
      stop(
        sprintf("%s() requires the 'ggplot2' package. Install it to use plotting helpers.", helper_name),
        call. = FALSE
      )
    },
    .package = "hydroMetrics"
  )

  expect_error(
    plot_fdc(c(1, 2, 3), c(1, 2, 3)),
    "plot_fdc\\(\\) requires the 'ggplot2' package"
  )
})

test_that("plot_fdc returns a ggplot object for aligned numeric input", {
  skip_if_not_installed("ggplot2")

  out <- plot_fdc(
    sim = c(1, NA, 3, 4),
    obs = c(1, 2, 3, 5),
    na_strategy = "remove",
    sim_label = "Model",
    obs_label = "Observed"
  )

  expect_s3_class(out, "ggplot")
  expect_true(is.data.frame(out$data))
  expect_identical(sort(unique(as.character(out$data$series))), c("Model", "Observed"))
  expect_identical(levels(out$data$series), c("Observed", "Model"))
  expect_identical(nrow(out$data), 6L)
  expect_equal(sort(unique(out$data$exceedance)), c(25, 50, 75))
  expect_identical(out$labels$colour, NULL)
  expect_identical(out$theme$legend.position, "top")
})

test_that("plot_fdc respects indexed alignment through preproc", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("zoo")

  sim <- zoo::zoo(c(1, 2, 3), order.by = as.Date("2020-01-01") + 0:2)
  obs <- zoo::zoo(c(10, 20, 30), order.by = as.Date("2020-01-02") + 0:2)

  out <- plot_fdc(sim, obs)

  expect_s3_class(out, "ggplot")
  expect_identical(nrow(out$data), 4L)
  expect_equal(sort(unique(out$data$exceedance)), c(100 / 3, 200 / 3))
})

test_that("plot_fdc guards log_scale for nonpositive aligned values", {
  skip_if_not_installed("ggplot2")

  expect_error(
    plot_fdc(c(0, 2, 3), c(1, 2, 3), log_scale = TRUE),
    "requires strictly positive aligned values"
  )
})

test_that("plot_fdc applies log scale when requested", {
  skip_if_not_installed("ggplot2")

  out <- plot_fdc(c(1, 2, 3), c(1.5, 2.5, 3.5), log_scale = TRUE)

  expect_s3_class(out, "ggplot")
  y_scale <- out$scales$get_scales("y")
  expect_false(is.null(y_scale))
  expect_identical(y_scale$trans$name, "log-10")
})
