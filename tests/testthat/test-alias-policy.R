test_that("exported compatibility and alias surface matches the documented policy", {
  ns_exports <- getNamespaceExports("hydroMetrics")
  compat_exports <- c(
    "APFB", "HFB", "NSeff", "mNSeff", "rNSeff", "wsNSeff",
    "mutual_information_score", "kl_divergence_flow"
  )
  label_only_aliases <- c(
    "NSE", "KGE", "MAE", "RMSE", "PBIAS", "R2", "NRMSE",
    "mNSE", "rNSE", "wsNSE", "rPearson"
  )

  expect_true(all(compat_exports %in% ns_exports))
  expect_false(any(label_only_aliases %in% ns_exports))
})

test_that("exported canonical and compatibility alias pairs remain numerically aligned", {
  sim <- c(1, 2, 2, 4, 5, 7)
  obs <- c(1, 1, 3, 4, 6, 8)

  expect_equal(mutual_information_score(sim, obs), mutual_information(sim, obs))
  expect_equal(kl_divergence_flow(sim, obs), kl_divergence(sim, obs))
})
