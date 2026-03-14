test_that("registry references contain no placeholder citation text", {
  refs <- hydroMetrics:::list_metrics()$references
  placeholder_pattern <- paste(
    c(
      paste(c("citation", "to", "refine"), collapse = " "),
      paste(c("citation", "to", "be", "refined"), collapse = " "),
      paste(c("exact", "citation", "to", "be", "refined"), collapse = " "),
      paste(c("pending", "definitive", "citation"), collapse = " "),
      paste(c("pending", "dedicated", "paper", "citation"), collapse = " "),
      paste(c("reference", "not", "provided"), collapse = " ")
    ),
    collapse = "|"
  )

  expect_false(any(grepl(placeholder_pattern, refs, ignore.case = TRUE)))
})
