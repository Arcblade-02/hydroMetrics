# hydroMetrics news

## 0.2.1

- Correct the exported hydroGOF-style wrapper surface so `NSE()`, `KGE()`,
  `RMSE()`, `R2()`, `NRMSE()`, and `PBIAS()` are part of the validated Phase 2
  public release contract.
- Add direct clean-namespace and clean installed-session wrapper verification
  for the corrected compatibility surface.
- Complete the Phase 2 compatibility/export closure and carry that state into
  the `0.2.1` patch baseline.
- Treat `v0.2.0` as a preserved but superseded historical release in favor of
  the corrected `v0.2.1` Phase 2 stable baseline.

## 0.2.0

- Expanded GitHub Actions release hardening to cover Linux, Windows, and macOS
  package checks with release, oldrel, and devel coverage where appropriate.
- Added a minimal getting-started vignette for the current orchestration and
  wrapper surface.
- Aligned package metadata and release-facing materials for the `0.2.0`
  readiness state.
- Added reproducible release-hardening evidence under `notes/release-hardening/`.

## 0.1.0

- Added Phase 2 baseline audit, dynamic verification, compatibility audit, and
  mathematical validation artifacts under `notes/`.
- Stabilized public API documentation and release metadata for Phase 2 fixing.
- Added compatibility aliases in the orchestration layer for `na.rm`, `fun`,
  `keep`, `epsilon.type`, and `epsilon.value` where those behaviors are
  already supported by the existing implementation.
