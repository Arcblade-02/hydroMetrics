# hydroMetrics news

## 0.2.2

- Closed Phase 3 Layer A on `dev`: all 27 Layer A metrics are implemented,
  registered, exported, documented, and covered by the current validation
  suite. The Batch A5 probabilistic metrics `crps`, `picp`, `mwpi`, and
  `skill_score` remain explicit-wrapper metrics and are intentionally excluded
  from deterministic `gof(sim, obs, extended = TRUE)` auto-selection.
- Continued Phase 3 Layer A with Batch A5 probabilistic metrics `crps`,
  `picp`, `mwpi`, and `skill_score`, using explicit ensemble, interval, and
  baseline-score input contracts with focused regression coverage.
- Continued Phase 3 Layer A with Batch A4 metrics `huber_loss`,
  `quantile_loss`, `trimmed_rmse`, and `winsor_rmse`, including explicit
  parameter defaults, registry entries, wrapper exports, and focused
  regression coverage.
- Continued Phase 3 Layer A with Batch A3 metrics `nrmse_range`,
  `fdc_slope_error`, `fdc_highflow_bias`, `fdc_lowflow_bias`,
  `log_fdc_rmse`, `low_flow_bias`, and `seasonal_bias`, including explicit
  FDC conventions, log/seasonality guards, registry entries, wrapper exports,
  and focused regression coverage.
- Continued Phase 3 Layer A with Batch A2 metrics `smape`, `mare`, `mrb`,
  `log_rmse`, `msle`, and `log_nse`, including explicit zero/log-domain guards,
  registry entries, wrapper exports, and regression coverage.
- Started Phase 3 Layer A Batch A1 with the literature-backed metrics `mdae`,
  `maxae`, `rbias`, `ccc`, `e1`, and `rrmse`, including registry entries,
  wrapper exports, and focused regression coverage.
- Closed the v0.2.2 pre-Layer-A stabilization baseline after confirming
  P3-FIX-01 through P3-FIX-05, `gof(extended = TRUE)`, `gof()` output-contract
  reconciliation, `fast_path`, and `inst/REFERENCES.md` cleanup. The remaining
  `devtools::check()` note on `dev` is the environmental
  `unable to verify current time` note and is accepted as non-blocking.
- Reconciled the canonical Phase 3 governance IDs (`D-025` through `D-031`)
  for the pre-Layer-A release gate and recorded the current exit-gate audit.
- Reconciled the remaining pre-Layer-A blocker drift on `dev`: `pairwise`
  preprocessing now defers NA dropping until pairwise evaluation, `br2`
  now follows the canonical Phase 3 policy, and deprecated `rpearson`
  requests now resolve to canonical `r` without leaving a duplicate registry id.
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
