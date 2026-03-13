# hydroMetrics news

## 0.2.2

- Recorded the Stage 6 pre-1.0 stabilization audit on `dev`: release-facing
  validation summaries now live under `inst/validation/`; the default
  `gof()`/`gof(extended = FALSE)` compat surface is treated as the current
  stable API baseline; `gof(extended = TRUE)` remains a broader but
  applicability-gated deterministic route; wrapper-only probabilistic metrics
  and other special-interface metrics remain outside default deterministic
  auto-selection; `pareto_skill` remains deferred pending stronger direct
  metric literature; and no genuine packaged real-dataset validation outputs
  are currently shipped in the repository.
- Closed Phase 3 Layer C on `dev`: all 12 Layer C metrics are implemented,
  registered, exported, documented, and covered by the current validation
  gate. The information-theory and tail-sensitive metrics keep the narrow
  reproducible package conventions introduced in Layer C, and
  `tail_dependence_score`, `extreme_event_ratio`, and
  `quantile_shift_index` are auto-selected by deterministic
  `gof(sim, obs, extended = TRUE)` only when their documented tail/event/IQR
  preconditions hold. Closure validation passed `load_all`, Layer C and
  structural-integrity tests, full `devtools::test()`, and
  `devtools::check(document = FALSE, error_on = 'warning')` with only the
  accepted environmental `unable to verify current time` note.
- Continued Phase 3 Layer B with the narrow Batch B4 delivery `event_nse`,
  implemented as NSE on pooled observed event windows defined by contiguous
  observed values strictly above the observed 0.8 quantile, with no broader
  public event framework introduced.
- Continued Phase 3 Layer B with Batch B3 hydrograph diagnostics
  `hydrograph_slope_error`, `derivative_nse`, `peak_timing_error`,
  `rising_limb_error`, `recession_constant`, and
  `baseflow_index_error`, with explicit ordered-series, peak-tie, recession,
  and baseflow-proxy conventions plus focused regression coverage.
- Continued Phase 3 Layer B with Batch B2 metrics `sqrt_nse`,
  `seasonal_nse`, `weighted_kge`, and `quantile_kge`, including explicit
  transform, monthly-seasonality, weighting, and fixed-quantile-grid
  conventions. `seasonal_nse` follows the same monthly-structure policy as
  `seasonal_bias` and is not auto-selected by deterministic
  `gof(sim, obs, extended = TRUE)` unless monthly seasonality is available.
- Started Phase 3 Layer B Batch B1 with empirical-distribution comparison
  metrics `ks_statistic`, `cdf_rmse`, `quantile_deviation`,
  `fdc_shape_distance`, `anderson_darling_stat`, and
  `wasserstein_distance`, including explicit EDF/FDC conventions, registry
  entries, wrapper exports, and focused regression coverage.
- Closed Phase 3 Layer B on `dev`: all 17 Layer B metrics are implemented,
  registered, exported, documented, and covered by the current validation
  gate. `seasonal_nse` is auto-applicable only when valid monthly seasonal
  structure is available, `event_nse` remains the only public event metric and
  keeps the narrow observed-window-only policy, and the Batch A5
  probabilistic metrics `crps`, `picp`, `mwpi`, and `skill_score` remain
  explicit-wrapper metrics excluded from deterministic
  `gof(sim, obs, extended = TRUE)` auto-selection. Closure validation passed
  `load_all`, Layer B and structural-integrity tests, full `devtools::test()`,
  and `devtools::check(document = FALSE, error_on = 'warning')`.
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
