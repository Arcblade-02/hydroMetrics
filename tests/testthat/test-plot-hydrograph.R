test_that("plot_hydrograph errors cleanly when ggplot2 is unavailable", {
  testthat::local_mocked_bindings(
    .hm_plot_require_ggplot2 = function(helper_name = "plot_hydrograph") {
      stop(
        sprintf("%s() requires the 'ggplot2' package. Install it to use plotting helpers.", helper_name),
        call. = FALSE
      )
    },
    .package = "hydroMetrics"
  )

  expect_error(
    plot_hydrograph(c(1, 2, 3), c(1, 2, 3)),
    "requires the 'ggplot2' package"
  )
})

test_that("plot_hydrograph returns a ggplot object for aligned numeric input", {
  skip_if_not_installed("ggplot2")

  out <- plot_hydrograph(
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
  expect_identical(sort(unique(out$data$x)), c(1L, 3L, 4L))
  expect_identical(out$labels$colour, NULL)
  expect_identical(out$theme$legend.position, "top")
})

test_that("plot_hydrograph respects indexed alignment through preproc", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("zoo")

  sim <- zoo::zoo(c(1, 2, 3), order.by = as.Date("2020-01-01") + 0:2)
  obs <- zoo::zoo(c(10, 20, 30), order.by = as.Date("2020-01-02") + 0:2)

  out <- plot_hydrograph(sim, obs)

  expect_s3_class(out, "ggplot")
  expect_identical(
    sort(unique(as.character(out$data$x))),
    c("2020-01-02", "2020-01-03")
  )
  expect_identical(nrow(out$data), 4L)
})
