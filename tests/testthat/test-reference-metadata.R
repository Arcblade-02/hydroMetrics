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

  expect_match(refs$references[refs$id == "br2"], "Krause")
  expect_match(refs$references[refs$id == "br2"], "piecewise weighting")
  expect_match(refs$references[refs$id == "br2"], "r\\^2 / \\|b\\|")
  expect_match(refs$references[refs$id == "pbias"], "Abdelkader")
  expect_match(refs$references[refs$id == "pbias"], "treats positive values as overestimation")
  expect_match(refs$references[refs$id == "pbias"], "opposite-sign Moriasi thresholds")
  expect_match(refs$references[refs$id == "nrmse"], "published NRMSE variants are not universal")
  expect_match(refs$references[refs$id == "pfactor"], "Abbaspour")
  expect_match(refs$references[refs$id == "pfactor"], "terminology context only")
  expect_match(refs$references[refs$id == "pfactor"], "not the SWAT/95PPU uncertainty-band P-factor")
  expect_match(refs$references[refs$id == "rfactor"], "Abbaspour")
  expect_match(refs$references[refs$id == "rfactor"], "deterministic paired-series compatibility metric")
  expect_match(refs$references[refs$id == "rfactor"], "not the SWAT/95PPU uncertainty-band R-factor")
  expect_match(refs$references[refs$id == "hfb"], "Compatibility-stable retained high-flow subset bias")
  expect_match(refs$references[refs$id == "hfb"], "not promoted as a literature-exact or hydroGOF-equivalent")
  expect_match(refs$references[refs$id == "low_flow_bias"], "Yilmaz")
  expect_match(refs$references[refs$id == "low_flow_bias"], "package-defined observed lower-30% subset percent-bias rule")
  expect_match(refs$references[refs$id == "low_flow_bias"], "does not claim the literature low-flow FDC/log formulation")
  expect_match(refs$references[refs$id == "mutual_information_score"], "retained callable compatibility duplicate")
  expect_match(refs$references[refs$id == "mutual_information_score"], "hidden from canonical discovery")
  expect_match(refs$references[refs$id == "mutual_information_score"], "should not be treated as an independent canonical id")
  expect_match(refs$references[refs$id == "mnse"], "Legates & McCabe")
})

test_that("eight non-runtime provenance targets use strengthened definition framing", {
  refs <- hydroMetrics:::list_metrics()
  refs <- refs[match(
    c("cdf_rmse", "evs", "maxae", "mdae", "rae", "rmsle", "rrse", "sae"),
    refs$id
  ), c("id", "references")]

  expect_false(any(grepl("scikit-learn|github.com/Arcblade-02/hydroMetrics/blob/dev/inst/REFERENCES.md|software convention", refs$references, ignore.case = TRUE)))
  expect_match(refs$references[refs$id == "cdf_rmse"], "pooled support grid")
  expect_match(refs$references[refs$id == "evs"], "sample-variance")
  expect_match(refs$references[refs$id == "maxae"], "worst-case absolute-error")
  expect_match(refs$references[refs$id == "mdae"], "robust absolute-error")
  expect_match(refs$references[refs$id == "rae"], "mean\\(obs\\)")
  expect_match(refs$references[refs$id == "rmsle"], "square-root companion")
  expect_match(refs$references[refs$id == "rrse"], "mean\\(obs\\)")
  expect_match(refs$references[refs$id == "sae"], "sum\\(abs\\(sim - obs\\)\\)")
})
