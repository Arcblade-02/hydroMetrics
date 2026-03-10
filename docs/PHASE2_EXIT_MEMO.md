# Phase 2 Exit Memo

- Generated: 2026-03-10
- Source package version reviewed: `0.2.1`
- Final recommendation: `GO - FINAL PHASE 2 STABLE BASELINE`

## Executive assessment

The remaining Phase 2 blocker was the public wrapper/export contract. That
closure state is now merged, versioned, validated, and prepared as the formal
`0.2.1` corrective release baseline without changing metric formulas or
preprocessing design.

## Closure status

- `wrapper/export surface`: `PASS` - `NSE()`, `KGE()`, `RMSE()`, `R2()`,
  `NRMSE()`, and `PBIAS()` are part of the exported source contract and are
  verified directly by tests and clean-install evidence.
- `naming policy`: `PASS` - legacy hydroGOF-style wrapper names remain public,
  while lowercase/internal-style compatibility exports remain documented rather
  than silently removed.
- `documentation`: `PASS` - wrapper-facing docs, README scope text, and release
  notes reflect the corrected compatibility story.
- `ggof deviation`: `PASS` - the non-plotting `ggof()` behavior remains
  explicit and unchanged.
- `validation`: `PASS` - `devtools::test()`, `R CMD build .`,
  `R CMD check --no-manual hydroMetrics_0.2.1.tar.gz`, clean installed-session
  verification, and an unrestricted `devtools::check(document = FALSE,
  manual = FALSE)` all completed successfully.
- `release baseline`: `PASS` - `v0.2.1` is the corrected Phase 2 stable
  release candidate while `v0.2.0` remains preserved as the superseded older
  release.

## Release implication

The current source branch is suitable as the corrected Phase 2 stable release
once the recorded validation artifacts remain green and the `v0.2.1` release
tag is in place. Phase 3 should branch from `v0.2.1`, not from the superseded
`v0.2.0` artifact.

## Evidence references

- `notes/wrapper-export-closure/wrapper_gap_inventory.csv`
- `notes/wrapper-export-closure/wrapper_export_decisions.md`
- `notes/wrapper-export-closure/naming_policy_verification.md`
- `notes/wrapper-export-closure/wrapper_runtime_verification.md`
- `notes/wrapper-export-closure/validation_results.txt`
- `notes/wrapper-export-closure/release_patch_recommendation.md`
