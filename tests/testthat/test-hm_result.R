test_that("hm_result is exported as a stable utility constructor", {
  expect_true("hm_result" %in% getNamespaceExports("hydroMetrics"))

  payload <- data.frame(
    metric = "rmse",
    name = "Root Mean Squared Error",
    value = 0.5,
    stringsAsFactors = FALSE
  )

  out <- hm_result(payload)

  expect_s3_class(out, "hm_result")
  expect_true(is.data.frame(out))
  expect_identical(class(out), c("hm_result", "data.frame"))
  expect_identical(as.data.frame(out), payload)
})

test_that("hm_result rejects non-data-frame inputs", {
  expect_error(
    hm_result(list(metric = "rmse", value = 0.5)),
    "`x` must be a data.frame."
  )
})
