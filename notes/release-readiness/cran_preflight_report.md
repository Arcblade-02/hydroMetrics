# CRAN Preflight Report

- Generated: 2026-03-10 01:27:57 IST
- Source package version: `0.2.0`
- Pipeline stop point: `none`
- Final recommendation: `NO-GO`

## Stage summary

- `clean install/load`: `WARN` - Fresh-session install/load succeeded via `R CMD INSTALL` after an environment-specific `devtools::install()` failure.
- `public API wrapper verification`: `FAIL` - Required public surface is incomplete on the current snapshot; missing or non-exported: NSE, KGE, RMSE, MAE, PBIAS, R2, NRMSE, preproc, valindex.
- `behavioral correctness matrix`: `FAIL` - Edge-case matrix captured current runtime behavior, but the following representative functions are not exported: NSE, KGE, RMSE, PBIAS, R2, NRMSE, preproc.
- `mathematical contract verification`: `PASS` - Runtime probes support the current mathematical contract for R2, NRMSE, NSE, KGE, and PBIAS.
- `tests and coverage`: `FAIL` - Test commands status: FAIL / PASS; coverage overall: 95.17%.
- `vignette build and documentation regeneration`: `FAIL` - Vignette command status: FAIL; documentation command status: PASS; README present: TRUE; NEWS present: TRUE.
- `checks and CI cross-check`: `FAIL` - Build/check/devtools::check statuses: PASS/PASS/FAIL; devtools::check(cran=TRUE): FAIL (environment-specific); CI remote status: unverified.

## Key observations

- Required exported API surface available: `2/11`.
- Package source version on this branch is `0.2.0`, which should be compared against the requested `0.2.x` target.
- Fatal stop occurred: `FALSE`.
