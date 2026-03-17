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

test_that("seven target metrics no longer use package-defined reference wording", {
  refs <- hydroMetrics:::list_metrics()
  target_ids <- c("mnse", "rnse", "wnse", "wsnse", "kgelf", "skge", "pbiasfdc")
  target_refs <- refs[match(target_ids, refs$id), c("id", "references")]

  expect_false(any(is.na(target_refs$references)))
  expect_false(any(grepl("package-defined|project-defined", target_refs$references, ignore.case = TRUE)))
})
