# Compatibility And Wrapper History

This archival note consolidates the smaller compatibility-repair and
wrapper-export closure fragments that were previously spread across:

- `notes/wrapper-export-closure/naming_policy_verification.md`
- `notes/wrapper-export-closure/release_patch_recommendation.md`
- `notes/wrapper-export-closure/wrapper_export_decisions.md`
- `notes/wrapper-export-closure/wrapper_runtime_verification.md`
- `notes/oldrel-compatibility-repair/final_oldrel_repair_summary.md`
- `notes/oldrel-compatibility-repair/repair_log.md`

The associated raw validation files remain in their original directories.

## Oldrel compatibility repair

- The oldrel repair lane focused on indexed-input stability rather than on
  metric redesign.
- Historical notes record two preprocessing helpers added in
  `R/hm_prepare.R`: `.hm_index_key()` and `.hm_align_indexed_series()`.
- Fragile zoo/xts alignment by direct common-index subsetting was replaced by
  ordered position-based matching, with deterministic rejection of non-unique
  indexed inputs to avoid ambiguous oldrel behavior.
- The `APFB()` example was reduced to a minimal deterministic zoo example
  suitable for installed-package checks, and the help page was regenerated.
- Targeted regression coverage was added for preprocessing, exported
  `preproc()`, indexed `gof()`, and `APFB()` paths.
- The recorded local validation outcome for that lane was `PASS 633` with clean
  build/check status and readiness for CI rerun.

## Wrapper/export closure and naming policy

- The wrapper-export closure notes document that the target hydroGOF-style
  wrappers were already present in source, already exported in `NAMESPACE`, and
  already documented in `man/`; the closure work was therefore about
  verification and release honesty rather than formula expansion.
- Historical naming-policy verification preserved three simultaneous layers:
  legacy hydroGOF-style wrapper names, orchestration/public entry points, and
  lowercase compatibility exports that were already public.
- `ggof()` remained explicitly recorded as a deviation because it returned a
  tabular helper object rather than a plotting device effect.
- `R2()` remained explicitly recorded as squared Pearson correlation rather
  than an alias for `NSE()`, and `NRMSE()` remained frozen to
  `norm = "mean"`.

## Clean-install runtime proof

- The wrapper runtime verification note recorded a clean installed-session
  package version `0.2.0` with `24` exports observed from the namespace.
- It also recorded direct successful runtime calls for the target wrapper set:
  `NSE`, `KGE`, `RMSE`, `R2`, `NRMSE`, `PBIAS`, `gof`, `ggof`, `preproc`, and
  `valindex`.
- The same note confirmed that `ggof(sim, obs, methods = "NSE")` returned
  class `hydro_metrics_batch, data.frame`, preserving the non-plotting
  deviation explicitly.

## Historical release implication

- The wrapper/export closure notes recommended preparing the corrective patch
  release `v0.2.1`.
- The stated rationale was that the public compatibility contract had been
  corrected and explicitly validated, while existing deviations such as
  non-plotting `ggof()` and `NRMSE(norm = "mean")` remained openly documented
  rather than silently changed.

