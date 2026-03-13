# Deviation Register

- Generated: 2026-03-10
- Source package version reviewed: `0.2.0`

## Active deviations retained after wrapper/export closure

- `ggof()` remains a non-plotting compatibility helper. It returns a tabular
  `hydro_metrics_batch` object and does not open or mutate a graphics device.
- `R2()` remains squared Pearson correlation and is not interchangeable with
  `NSE()` on biased predictions.
- Phase 2 freezes `NRMSE()` at `norm = "mean"` only.
- Lowercase/internal-style compatibility exports remain available where they
  were already public in Phase 2: `alpha()`, `beta()`, `mae()`, `pbias()`,
  `r()`, and `rsr()`.
- `APFB()` remains an indexed compatibility wrapper that requires univariate
  `zoo` or `xts` inputs with a time index.
- `preproc()` remains intentionally limited to single-series numeric or indexed
  inputs; matrix/data.frame preprocessing is not added in this closure.

## Closed deviations

- The public compatibility/export surface is no longer treated as incomplete on
  the current source branch. The legacy hydroGOF-style wrappers `NSE()`,
  `KGE()`, `RMSE()`, `R2()`, `NRMSE()`, and `PBIAS()` are present in source,
  exported in `NAMESPACE`, documented, and covered by direct wrapper tests and
  clean-install verification evidence.
