# Release Patch Recommendation

Recommendation: prepare patch release `v0.2.1`

## Decision

The published `v0.2.0` artifact should be treated as superseded by a corrected
patch release built from this source state.

## Rationale

- The public compatibility contract is corrected and explicitly validated.
- The exported wrapper surface now matches the intended Phase 2 story for
  `NSE()`, `KGE()`, `RMSE()`, `R2()`, `NRMSE()`, `PBIAS()`, `gof()`, `ggof()`,
  `preproc()`, and `valindex()`.
- The clean installed-session verification confirms the target wrappers are
  exported and directly callable from a fresh library.
- No metric formulas were expanded or redesigned beyond wrapper/export closure
  scope.
- The remaining documented deviations are explicit and unchanged, including the
  non-plotting `ggof()` behavior and `NRMSE(norm = "mean")` freeze.
