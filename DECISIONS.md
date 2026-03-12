# Architecture Decisions

## D-001: License and Clean-Room Boundary
- Decision: `hydroMetrics` is MIT-licensed and implemented under clean-room rules.
- Status: Accepted
- Notes: No code may be copied from GPL-family projects. Derivations must come from literature and independent design.

## D-002: Internal Architecture and Output Model
- Decision: Internal architecture uses R6 for registry and engine; public outputs use S3.
- Status: Accepted
- Notes: `MetricRegistry` and `HydroEngine` are R6 classes; evaluation results return S3 `hm_result` over `data.frame`.

## D-003: Internal Engine Style
- Decision: Functions-first public API over R6 internals.
- Status: Accepted
- Notes: Public entry points stay stable (`evaluate_metrics`, `register_metric`, `list_metrics`) and delegate to singleton R6 objects.

## D-004: Output Data Formats
- Decision: `evaluate_metrics()` returns base `data.frame` with class `c("hm_result", "data.frame")`.
- Status: Accepted
- Notes: Tibble support may be added later behind an optional dependency.

## D-005: R2 Definition
- Decision: `R2` means Pearson correlation squared (`r^2`) and never NSE.
- Status: Accepted
- Notes: Naming and documentation must keep this distinction explicit.

## D-006: Metric Registry Storage
- Decision: Registry storage is environment-backed within `MetricRegistry`.
- Status: Accepted
- Notes: Environment storage provides straightforward uniqueness checks and lookup by id.

## D-007: Registry Schema v1
- Decision: All registered metrics must satisfy schema v1 metadata requirements.
- Status: Accepted
- Notes: Required fields are `id`, `fun`, `name`, `description`, `category`, `perfect`, `range`, `references`, `version_added`, with optional `tags` defaulting to `character()`.

## D-008: Core Metric Bootstrap Strategy
- Decision: Core metrics (`nse`, `rmse`, `pbias`, `cp`, `pfactor`, `rfactor`, `mae`, `mse`, `nrmse`, `beta`, `alpha`, `r`, `r2`, `kge`, `rsr`, `mape`, `mpe`, `ve`, `nrmse_sd`, `me`, `d`, `md`, `rd`, `dr`, `br2`, `rnse`, `mnse`, `wnse`, `wsnse`, `ubrmse`, `ssq`, `kgekm`, `kgelf`, `kgenp`, `skge`, `pbiasfdc`, `apfb`, `hfb`, `rspearman`, `rsd`) are lazily auto-registered on first registry/engine access.
- Status: Accepted
- Notes: Public API remains stable and users can evaluate core metrics without manual registration.

## D-009: NRMSE Normalization
- Decision: `NRMSE` is defined as `sqrt(mean((sim - obs)^2)) / mean(obs)`.
- Status: Accepted
- Notes: When `mean(obs) == 0`, evaluation fails with an explicit divide-by-zero style error.

## D-010: R2 Definition Confirmation
- Decision: `R2` is defined as `cor(sim, obs)^2` using Pearson correlation.
- Status: Accepted
- Notes: This reaffirms `R2` as squared Pearson correlation, not NSE.

## D-011: KGE Formula Variant
- Decision: Use KGE (2009) as `1 - sqrt((r-1)^2 + (alpha-1)^2 + (beta-1)^2)` where `r=cor(sim,obs)`, `alpha=sd(sim)/sd(obs)`, and `beta=mean(sim)/mean(obs)`.
- Status: Accepted
- Notes: Evaluation errors explicitly when `sd(obs) == 0` or `mean(obs) == 0`.

## D-012: NRMSE Variants
- Decision: Keep two NRMSE variants: `nrmse = RMSE/mean(obs)` and `nrmse_sd = RMSE/sd(obs)`.
- Status: Accepted
- Notes: `nrmse` and `nrmse_sd` are distinct metrics and both are retained for compatibility.

## D-013: Zero-Observation Percentage Metrics Policy
- Decision: `mape` and `mpe` fail when observed values contain zero.
- Status: Accepted
- Notes: Zero-observation divisions are treated as invalid input; no silent `Inf`/`NaN` handling is applied.

## D-014: Relative Agreement Variants
- Decision: `rd` and `dr` use observation-normalized relative formulations selected for compatibility tracking.
- Status: Accepted
- Notes: Both metrics fail when `obs` contains zero, and both fail when their denominator evaluates to zero.

## D-015: Bias-Corrected R2 Formula
- Decision: `br2` is defined as `r^2 * (min(sd(sim), sd(obs))/max(sd(sim), sd(obs)))^2 * (min(mean(sim), mean(obs))/max(mean(sim), mean(obs)))^2`.
- Status: Accepted
- Notes: This is a conservative project definition pending dedicated literature confirmation; failures are explicit for zero sd/mean and NA correlation.

## D-016: NSE Family Variants
- Decision: `rnse`, `mnse`, `wnse`, and `wsnse` follow explicit clean-room formulas documented in code and tests.
- Status: Accepted
- Notes: `rnse` fails on `obs == 0` or zero denominator; `wnse`/`wsnse` fail on negative observations and zero denominator; `mnse` fails on zero denominator.

## D-017: ubRMSE and SSQ Definitions
- Decision: `ubrmse` is anomaly-based RMSE and `ssq` is the sum of squared errors.
- Status: Accepted
- Notes: Both are standard error definitions used for compatibility coverage.

## D-018: KGE Variant Definitions
- Decision: `kgekm` uses `gamma = CV(sim)/CV(obs)` with standard KGE distance, `kgelf` applies KGE to `log1p`-transformed nonnegative flows, and `kgenp` uses Spearman/IQR/median components.
- Status: Accepted
- Notes: These are conservative clean-room variant definitions from common hydrology practice; citations remain marked for refinement.

## D-019: Seasonal KGE and FDC Bias Choices
- Decision: `skge` is defined as mean monthly KGE over `ts` inputs with frequency 12, and `pbiasfdc` uses exceedance quantile grid `p = 0.01..0.99`.
- Status: Accepted
- Notes: `skge` currently requires a monthly time index and errors for plain numeric vectors; `pbiasfdc` quantile-grid choice favors deterministic comparability and may be revisited after benchmark review.

## D-020: Correlation and Scale Compatibility Metrics
- Decision: Canonical Pearson correlation is `r`; `rpearson` is retained only as a deprecated compatibility alias, while `rspearman` remains a direct correlation metric and `rsd` is defined as `sd(sim)/sd(obs)`.
- Status: Accepted
- Notes: `rsd` errors only when `sd(obs) == 0`; `sd(sim) == 0` remains valid and yields `0`.

## D-021: gof/ggof Compatibility Wrappers
- Decision: `gof()` resolves method names case-insensitively and returns named numeric vector (single series) or numeric matrix with metrics as rows (multi-series); `ggof()` builds a simple bar plot from `gof()` output.
- Status: Accepted
- Notes: `ggof()` requires `ggplot2` in Suggests and errors gracefully if unavailable.

## D-022: Batch 8A Compatibility Definitions
- Decision: `cp` is defined as `1 - sum((obs_t - sim_t)^2)/sum((obs_t - obs_{t-1})^2)` on aligned `t = 2..n`; `preproc(keep = "pairwise")` defers NA dropping until pairwise metric evaluation instead of collapsing to `keep = "complete"`; `valindex` is a project-defined weighted aggregate of normalized `gof()` metrics.
- Status: Accepted
- Notes: `cp` errors when persistence denominator is zero or length < 2. `valindex` v1 supports `NSE`, `KGE`, `rmse`, `pbias`, and `rPearson` with fixed normalization transforms and returns scalar (single series) or `1 x n` matrix (multi-series).

## D-023: Batch 8B pfactor/rfactor Definitions
- Decision: `rfactor` is defined as `mean(abs(sim - obs)) / mean(abs(obs))` and `pfactor` is defined as the proportion where `abs(sim - obs) <= tol * abs(obs)`, with `obs == 0` handled by absolute threshold `tol`.
- Status: Accepted
- Notes: `rfactor` requires at least one non-missing paired value and errors when `mean(abs(obs)) == 0`. `pfactor` requires `tol >= 0` and at least one non-missing paired value; default `tol` is `0.10`.

## D-024: Phase 2B Batch 1 Parity Policies (rsr/pbias/mae)
- Decision: `rsr`, `pbias`, and `mae` use explicit clean-room formulas with deterministic edge policies and wrappers routed through the Phase 2A preprocessing pipeline.
- Status: Accepted
- Notes: `rsr = RMSE/sd(obs)` requires at least two paired values and `sd(obs) > 0` (`"sd(obs) is zero; RSR undefined"`). `pbias = 100 * sum(sim - obs)/sum(obs)` requires `sum(obs) != 0` (`"sum(obs) is zero; PBIAS undefined"`). `mae = mean(abs(sim - obs))` requires at least one paired value. Metrics remain NA-free/transform-free and rely on preprocessing for alignment, NA strategy, and transformations.

## D-025: Phase 2B Batch 2 KGE Component Metrics (beta/alpha/r)
- Decision: Add clean-room parity metrics `beta`, `alpha`, and `r` as explicit KGE components, with wrappers routed through the Phase 2A preprocessing pipeline.
- Status: Accepted
- Notes: `beta = mean(sim)/mean(obs)` requires at least one value and `mean(obs) != 0` (`"mean(obs) is zero; beta undefined"`). `alpha = sd(sim)/sd(obs)` requires at least two values and `sd(obs) > 0` (`"sd(obs) is zero; alpha undefined"`). `r = cor(sim, obs, method = "pearson")` requires at least two values and fails on zero-variance inputs (`"zero variance; correlation undefined"`). No NA/transform logic is implemented in metric bodies.

## D-026: Phase 2B Batch 3 Legacy NSE Alias Exports
- Decision: Add `NSeff`, `mNSeff`, `rNSeff`, and `wsNSeff` as thin compatibility wrappers that route to existing metric ids (`nse`, `mnse`, `rnse`, `wsnse`) through `gof()`.
- Status: Accepted
- Notes: No new NSE-family formulas were introduced, and no NA handling was added to metric bodies. Wrapper behavior fully inherits existing implementation guards, including the `rNSeff` zero-observation policy from `rnse` (`obs == 0` is invalid and errors deterministically).

## D-027: Phase 2B Batch 4A APFB/HFB Modern Scalar Exports
- Decision: Add `APFB` and `HFB` as clean-room compatibility exports that must call `preproc()` and return numerically coercible S3 scalars with class `c("hydro_metric_scalar", "numeric")`.
- Status: Accepted
- Notes: `APFB` requires indexed zoo/xts input, aggregates annual maxima by calendar year, requires at least two years, and errors when any annual `obs_peak == 0`; invalid denominator states return `NA` with warning. `HFB` uses deterministic high-flow threshold `quantile(obs, probs = threshold_prob, type = 7)` (default `0.9`), requires at least three selected points, and returns `NA` with warning when `sum(obs_high) == 0`. Both metrics keep NA/alignment handling centralized via `preproc()` and attach metadata (`n_obs`, metric-specific `meta`, and call).

## D-028: Phase 2B Batch 4B Modern Orchestration Compatibility Layer
- Decision: Export `preproc`, `gof`, `ggof`, and `valindex` as clean-room compatibility wrappers over the existing preprocessing engine and registered metric dispatch, with structured S3 returns.
- Status: Accepted
- Notes: `preproc` is a public wrapper around `.hm_prepare_inputs` returning class `hydro_preproc`; `gof` returns the metric payload directly as a named numeric vector for single-series input or a named numeric matrix for multi-series input, with class `hydro_metrics` and metadata attached via `n_obs`, `meta`, and `call` attributes; `ggof` is tabular-only (class `hydro_metrics_batch`) and does not produce plots; `valindex` is a thin wrapper delegating to `gof(methods = fun, ...)`. Thin single-metric compatibility wrappers may use an internal fast path only for plain numeric, finite, no-NA vector inputs with no extra preprocessing options; all other cases fall back to the full orchestration path unchanged. No metric formulas are duplicated in orchestration code.

## D-029: Phase 2C Metric Engine Consolidation
- Decision: Consolidate to a single canonical metric tree in `R/core_metrics.R`, remove duplicate `R/metrics/*` definitions, and enforce registry-only metric execution from orchestration wrappers.
- Status: Accepted
- Notes: `gof` remains the sole orchestration path (`gof -> preproc -> .hm_prepare_inputs -> registry -> metric`). Exported compatibility wrappers (`APFB`, `HFB`, `pfactor`, `rfactor`) now dispatch through `gof` and no longer call `preproc` directly. Metric implementations were kept formula-equivalent while removing hidden NA-handling branches from the metric layer.

## D-030: gof Extended Metric Selection Contract
- Decision: `gof()` defaults to the compat-10 metric set (`nse`, `kge`, `rmse`, `pbias`, `mae`, `mse`, `r2`, `ve`, `rsr`, `nrmse`), while `gof(extended = TRUE)` expands omitted/`NULL` selection to all automatically applicable registered metrics for the current input context.
- Status: Accepted
- Notes: Explicit `methods` input always takes precedence over `extended`. Context-bound metrics that require unsupported side inputs remain available through explicit `methods` plus params, but are not auto-selected when the current inputs cannot support them. Output structure remains unchanged: named numeric vector for single-series inputs or named numeric matrix for multi-series inputs, with class `hydro_metrics` and metadata preserved on attributes rather than top-level wrapper fields.

## Phase 3 Canonical Decision Reconciliation (v0.2.2 Pre-Layer-A Gate)
- Decision: The entries below are the canonical Phase 3 execution-plan IDs for release-governance and cross-reference purposes.
- Status: Accepted
- Notes: Earlier `D-025` through `D-030` headings above record historical implementation decisions from Phase 2B/2C. Where numbering drift occurred during implementation, the canonical meanings for pre-Layer-A closure are the `D-025` through `D-031` entries in this section.

## D-025: Frozen gof() Output Contract (Canonical Phase 3 ID)
- Decision: `gof()` must return the metric payload directly: a named numeric vector for single-series input or a named numeric matrix for multi-series input, both with class `hydro_metrics` and metadata carried on attributes.
- Status: Accepted
- Notes: This is the authoritative Phase 3 contract for `gof()` output shape. The operational implementation currently matches this contract on `dev`.

## D-026: Canonical Metric ID and Alias Policy (Canonical Phase 3 ID)
- Decision: Phase 3 metric IDs are unique canonical registry identifiers. Compatibility aliases or deprecated names may remain only as wrappers or resolution aliases and must not persist as duplicate canonical registry entries.
- Status: Accepted
- Notes: Canonical Pearson correlation id is `r`. Deprecated `rpearson` requests resolve to `r` with a warning and no longer persist as an independent registry entry.

## D-027: gof() Default and Extended Metric-Set Contract (Canonical Phase 3 ID)
- Decision: `gof()` and `gof(extended = FALSE)` default to the compat-10 baseline set (`nse`, `kge`, `rmse`, `pbias`, `mae`, `mse`, `r2`, `ve`, `rsr`, `nrmse`), while `gof(extended = TRUE)` expands omitted or `NULL` selection to the full registered metric set supported by the current input context.
- Status: Accepted
- Notes: Explicit `methods` input always takes precedence. This canonical Phase 3 ID supersedes the earlier implementation-drift use of `D-030` for the same contract.

## D-028: Internal Fast-Path Scope and Fallback Rule (Canonical Phase 3 ID)
- Decision: Any internal direct-computation fast path is limited to simple public single-metric wrapper calls on plain numeric, finite, no-NA vectors with no preprocessing-sensitive options; all other cases must fall back to the full orchestration path unchanged.
- Status: Accepted
- Notes: The current `dev` implementation matches this scope and fallback rule. This canonical Phase 3 ID aligns with the fast-path behavior already captured operationally in the earlier orchestration decision.

## D-029: br2 Literature Correction Policy (Canonical Phase 3 ID)
- Decision: `br2` must follow the Krause et al. (2005) `bR2` interpretation selected by project policy, and this canonical decision supersedes the earlier project-specific formula recorded in `D-015`.
- Status: Accepted
- Notes: This is a release-governance correction, not a new metric. `dev` now implements `bR2 = abs(slope(sim ~ obs)) * cor(sim, obs)^2`, with the older `D-015` formula retained only as historical record.

## D-030: Information-Theoretic Metric Disclosure Rule (Canonical Phase 3 ID)
- Decision: Information-theoretic metrics may not be added or released without explicit bandwidth-sensitivity disclosure, estimator assumptions, and literature citations sufficient for reproducible interpretation.
- Status: Accepted
- Notes: This rule is forward-looking for Phase 3 expansion. No current public metric on `dev` claims exemption from this disclosure requirement.

## D-031: No Uncited Layer C / Research-Frontier Additions (Canonical Phase 3 ID)
- Decision: No uncited Layer C metric or other research-frontier metric may be added to the package. Any such addition must carry literature grounding in `inst/REFERENCES.md` before implementation is considered release-ready.
- Status: Accepted
- Notes: Project-defined compatibility behavior remains allowed only when explicitly documented as package-defined and backed by a stable decision record. This rule is part of the pre-Layer-A governance gate and is now recorded explicitly.
