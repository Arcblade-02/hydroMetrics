# hydroMetrics news

## 0.2.1 (planned)

- Close the Phase 2 wrapper/export contract so the hydroGOF-style public
  wrappers `NSE()`, `KGE()`, `RMSE()`, `R2()`, `NRMSE()`, and `PBIAS()` are
  explicitly validated from a clean installed session.
- Regenerate the wrapper-facing documentation and record the naming-policy
  relationship between legacy uppercase wrappers and retained lowercase
  compatibility exports.
- Add direct wrapper export, signature, return-type, and `na.rm` tests for the
  released compatibility surface.

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
