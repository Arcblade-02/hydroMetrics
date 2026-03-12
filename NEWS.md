# hydroMetrics news

## 0.2.2

- Added `gof(extended = TRUE)` to expose the full automatically applicable
  registered metric set while keeping the default
  `gof()`/`gof(extended = FALSE)` behavior frozen to the compat-10
  hydroGOF-style metric set.
- Corrected `gof()` to return the metric payload directly as a
  `hydro_metrics` vector or matrix, with `n_obs`, `meta`, and `call`
  preserved as attributes instead of top-level wrapper fields.
- Added an internal fast path for simple single-metric wrapper calls on plain
  numeric no-NA vectors, with conservative fallback to the full engine for all
  non-trivial cases.

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
