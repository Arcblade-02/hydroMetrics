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
  target_ids <- c("mnse", "rnse", "wnse", "wsnse", "kgelf", "skge")
  target_refs <- refs[match(target_ids, refs$id), c("id", "references")]

  expect_false(any(is.na(target_refs$references)))
  expect_false(any(grepl("package-defined|project-defined", target_refs$references, ignore.case = TRUE)))
})

test_that("targeted provenance-sensitive metrics carry explicit qualification text", {
  refs <- hydroMetrics:::list_metrics()
  refs <- refs[match(
    c("br2", "pbias", "nrmse", "pfactor", "rfactor", "hfb", "low_flow_bias", "mutual_information_score", "mnse"),
    refs$id
  ), c("id", "references")]

  expect_match(refs$references[refs$id == "br2"], "does not claim a fully reverified literature-exact formula match")
  expect_match(refs$references[refs$id == "pbias"], "positive values indicate overestimation")
  expect_match(refs$references[refs$id == "nrmse"], "published NRMSE variants are not universal")
  expect_match(refs$references[refs$id == "pfactor"], "not the SWAT/95PPU uncertainty-band P-factor")
  expect_match(refs$references[refs$id == "rfactor"], "not the SWAT/95PPU uncertainty-band R-factor")
  expect_match(refs$references[refs$id == "hfb"], "Package-defined compatibility high-flow subset bias")
  expect_match(refs$references[refs$id == "low_flow_bias"], "package-defined observed lower-30% subset percent-bias rule")
  expect_match(refs$references[refs$id == "mutual_information_score"], "should not be treated as an independent canonical id")
  expect_match(refs$references[refs$id == "mnse"], "Legates & McCabe")
})
