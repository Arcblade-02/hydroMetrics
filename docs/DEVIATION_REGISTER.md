# Deviation Register

- Generated: 2026-03-10 01:27:57 IST

## Source snapshot deviations

- Current branch source version is `0.2.0`, not the requested `0.2.x` target.
- Required public wrappers missing from exports: NSE, KGE, RMSE, MAE, PBIAS, R2, NRMSE, preproc, valindex.
- README present: `TRUE`; NEWS present: `TRUE`; vignettes present: `TRUE`.
- `R2` behaves as squared Pearson correlation and is not interchangeable with `NSE` on biased predictions.
- `br2`, `pfactor`, and `rfactor` are project-defined compatibility metrics/variants rather than verified hydroGOF-equivalent exports on this branch.
- The package currently exports `gof`, `ggof`, and `hm_result`; wrapper compatibility is therefore incomplete from a clean session.
- CI does not currently prove vignette coverage and may not cover macOS or a dedicated coverage workflow on this branch.
