# Architecture Decisions

This file separates active canonical governance from retained historical
records. Only the entries under **Active Canonical Decisions** should be
extended with future decision IDs. Entries labeled **Former D-0xx** preserve
earlier numbering drift for traceability and are not the IDs to continue.
`Former D-030A` and `Former D-030B` are document-only disambiguators for the
two duplicated historical `D-030` headings.

## Active Canonical Decisions

### Foundational and Package-Wide Governance

#### D-001: License and Clean-Room Boundary
- Decision: `hydroMetrics` is MIT-licensed and implemented under clean-room rules.
- Status: Accepted
- Notes: No code may be copied from GPL-family projects. Derivations must come from literature and independent design.

#### D-002: Internal Architecture and Output Model
- Decision: Internal architecture uses R6 for registry and engine; public outputs use S3.
- Status: Accepted
- Notes: `MetricRegistry` and `HydroEngine` are R6 classes; evaluation results return S3 `hm_result` over `data.frame`.

#### D-003: Internal Engine Style
- Decision: Functions-first package interfaces sit over R6 internals.
- Status: Accepted
- Notes: The package continues to route plain function entry points over singleton R6 objects. Later compatibility and orchestration decisions define the current user-facing surface more precisely than this early engine record.

#### D-004: Output Data Formats
- Decision: `evaluate_metrics()` returns base `data.frame` with class `c("hm_result", "data.frame")`.
- Status: Accepted
- Notes: Tibble support may be added later behind an optional dependency.

#### D-005: R2 Definition
- Decision: `R2` means Pearson correlation squared (`r^2`) and never NSE.
- Status: Accepted
- Notes: Naming and documentation must keep this distinction explicit.

#### D-006: Metric Registry Storage
- Decision: Registry storage is environment-backed within `MetricRegistry`.
- Status: Accepted
- Notes: Environment storage provides straightforward uniqueness checks and lookup by id.

#### D-007: Registry Schema v1
- Decision: All registered metrics must satisfy schema v1 metadata requirements.
- Status: Accepted
- Notes: Required fields are `id`, `fun`, `name`, `description`, `category`, `perfect`, `range`, `references`, `version_added`, with optional `tags` defaulting to `character()`.

#### D-008: Core Metric Bootstrap Strategy
- Decision: Core metrics (`nse`, `rmse`, `pbias`, `cp`, `pfactor`, `rfactor`, `mae`, `mse`, `nrmse`, `beta`, `alpha`, `r`, `r2`, `kge`, `rsr`, `mape`, `mpe`, `ve`, `nrmse_sd`, `me`, `d`, `md`, `rd`, `dr`, `br2`, `rnse`, `mnse`, `wnse`, `wsnse`, `ubrmse`, `ssq`, `kgekm`, `kgelf`, `kgenp`, `skge`, `pbiasfdc`, `apfb`, `hfb`, `rspearman`, `rsd`) are lazily auto-registered on first registry/engine access.
- Status: Accepted
- Notes: Public API remains stable and users can evaluate core metrics without manual registration. Deprecated `rpearson` requests are handled by alias resolution rather than as a separately registered core metric.

#### D-009: NRMSE Normalization
- Decision: `NRMSE` is defined as `sqrt(mean((sim - obs)^2)) / mean(obs)`.
- Status: Accepted
- Notes: When `mean(obs) == 0`, evaluation fails with an explicit divide-by-zero style error.

#### D-010: R2 Definition Confirmation
- Decision: `R2` is defined as `cor(sim, obs)^2` using Pearson correlation.
- Status: Accepted
- Notes: This reaffirms `R2` as squared Pearson correlation, not NSE.

#### D-011: KGE Formula Variant
- Decision: Use KGE (2009) as `1 - sqrt((r-1)^2 + (alpha-1)^2 + (beta-1)^2)` where `r=cor(sim,obs)`, `alpha=sd(sim)/sd(obs)`, and `beta=mean(sim)/mean(obs)`.
- Status: Accepted
- Notes: Evaluation errors explicitly when `sd(obs) == 0` or `mean(obs) == 0`.

#### D-012: NRMSE Variants
- Decision: Keep two NRMSE variants: `nrmse = RMSE/mean(obs)` and `nrmse_sd = RMSE/sd(obs)`.
- Status: Accepted
- Notes: `nrmse` and `nrmse_sd` are distinct metrics and both are retained for compatibility.

#### D-013: Zero-Observation Percentage Metrics Policy
- Decision: `mape` and `mpe` fail when observed values contain zero.
- Status: Accepted
- Notes: Zero-observation divisions are treated as invalid input; no silent `Inf`/`NaN` handling is applied.

#### D-014: Relative Agreement Variants
- Decision: `rd` and `dr` use observation-normalized relative formulations selected for compatibility tracking.
- Status: Accepted
- Notes: Both metrics fail when `obs` contains zero, and both fail when their denominator evaluates to zero.

### Current Metric and Package Contracts

#### D-016: NSE Family Variants
- Decision: `rnse`, `mnse`, `wnse`, and `wsnse` follow explicit clean-room formulas documented in code and tests.
- Status: Accepted
- Notes: `rnse` fails on `obs == 0` or zero denominator; `wnse`/`wsnse` fail on negative observations and zero denominator; `mnse` fails on zero denominator.

#### D-017: ubRMSE and SSQ Definitions
- Decision: `ubrmse` is anomaly-based RMSE and `ssq` is the sum of squared errors.
- Status: Accepted
- Notes: Both are standard error definitions used for compatibility coverage.

#### D-018: KGE Variant Definitions
- Decision: `kgekm` uses `gamma = CV(sim)/CV(obs)` with standard KGE distance, `kgelf` applies KGE to `log1p`-transformed nonnegative flows, and `kgenp` uses Spearman/IQR/median components.
- Status: Accepted
- Notes: Literature-backed reference metadata for these variants is recorded in `inst/REFERENCES.md`; package decisions still document the exact implementation choices.

#### D-019: Seasonal KGE and FDC Bias Choices
- Decision: `skge` is defined as mean monthly KGE over `ts` inputs with frequency 12, and `pbiasfdc` uses exceedance quantile grid `p = 0.01..0.99`.
- Status: Accepted
- Notes: `skge` currently requires a monthly time index and errors for plain numeric vectors; `pbiasfdc` quantile-grid choice favors deterministic comparability and may be revisited after benchmark review.

#### D-023: Batch 8B pfactor/rfactor Definitions
- Decision: `rfactor` is defined as `mean(abs(sim - obs)) / mean(abs(obs))` and `pfactor` is defined as the proportion where `abs(sim - obs) <= tol * abs(obs)`, with `obs == 0` handled by absolute threshold `tol`.
- Status: Accepted
- Notes: `rfactor` requires at least one non-missing paired value and errors when `mean(abs(obs)) == 0`. `pfactor` requires `tol >= 0` and at least one non-missing paired value; default `tol` is `0.10`.

#### D-024: Phase 2B Batch 1 Parity Policies (rsr/pbias/mae)
- Decision: `rsr`, `pbias`, and `mae` use explicit clean-room formulas with deterministic edge policies and wrappers routed through the Phase 2A preprocessing pipeline.
- Status: Accepted
- Notes: `rsr = RMSE/sd(obs)` requires at least two paired values and `sd(obs) > 0` (`"sd(obs) is zero; RSR undefined"`). `pbias = 100 * sum(sim - obs)/sum(obs)` requires `sum(obs) != 0` (`"sum(obs) is zero; PBIAS undefined"`). `mae = mean(abs(sim - obs))` requires at least one paired value. Metrics remain NA-free/transform-free and rely on preprocessing for alignment, NA strategy, and transformations.

#### D-032: Phase 2 Output Contract Downgrade
- Decision: Phase 2 exits with the shipped S3/data.frame output model rather than a tibble-first output contract, and no `output = "matrix"` switch is introduced.
- Status: Accepted
- Notes: `gof()` returns class `"hydro_metrics"`, `ggof()` returns class `"hydro_metrics_batch"`, and scalar wrappers return numeric outputs. Any earlier tibble-first plan claim is formally downgraded and tracked in the Phase 2 deviation register.

### Canonical Phase 3 and Pre-Phase 4 Governance IDs

The entries below are the canonical active meanings of `D-025` through
`D-035`. Earlier Phase 2B/2C and Phase 2-exit uses of reused numbers are
preserved later in this file as retained or historical records and should not
be extended.

#### D-025: Frozen gof() Output Contract
- Decision: `gof()` must return the metric payload directly: a named numeric vector for single-series input or a named numeric matrix for multi-series input, both with class `hydro_metrics` and metadata carried on attributes.
- Status: Accepted
- Notes: This is the authoritative output-shape contract for `gof()`. The operational implementation currently matches this contract on `dev`.

#### D-026: Canonical Metric ID and Alias Policy
- Decision: Phase 3 metric IDs are unique canonical registry identifiers. Compatibility aliases or deprecated names may remain only as wrappers or resolution aliases and must not persist as duplicate canonical registry entries.
- Status: Accepted
- Notes: Canonical Pearson correlation id is `r`. Deprecated `rpearson` metric-id requests resolve to `r` and no longer persist as an independent registry entry. Engine-level metric-id evaluation currently warns on that deprecated alias, while orchestration-level method selection preserves the requested label and does not currently emit a warning.

#### D-027: gof() Default and Extended Metric-Set Contract
- Decision: `gof()` and `gof(extended = FALSE)` default to the compat-10 baseline set (`nse`, `kge`, `rmse`, `pbias`, `mae`, `mse`, `r2`, `ve`, `rsr`, `nrmse`), while `gof(extended = TRUE)` expands omitted or `NULL` selection to the full registered metric set supported by the current input context.
- Status: Accepted
- Notes: Explicit `methods` input always takes precedence. This canonical Phase 3 ID supersedes the earlier implementation-drift use of `D-030` for the same contract.

#### D-028: Internal Fast-Path Scope and Fallback Rule
- Decision: Any internal direct-computation fast path is limited to simple public single-metric wrapper calls on plain numeric, finite, no-NA vectors with no preprocessing-sensitive options; all other cases must fall back to the full orchestration path unchanged.
- Status: Accepted
- Notes: The current `dev` implementation matches this scope and fallback rule.

#### D-029: br2 Literature Correction Policy
- Decision: `br2` must follow the Krause et al. (2005) `bR2` interpretation selected by project policy, and this canonical decision supersedes the earlier project-specific formula recorded in `D-015`.
- Status: Accepted
- Notes: This is a release-governance correction, not a new metric. `dev` now implements `bR2 = abs(slope(sim ~ obs)) * cor(sim, obs)^2`, with the older `D-015` formula retained only as historical record.

#### D-030: Information-Theoretic Metric Disclosure Rule
- Decision: Information-theoretic metrics may not be added or released without explicit bandwidth-sensitivity disclosure, estimator assumptions, and literature citations sufficient for reproducible interpretation.
- Status: Accepted
- Notes: This rule remains forward-looking. No current public metric on `dev` claims exemption from this disclosure requirement.

#### D-031: No Uncited Layer C / Research-Frontier Additions
- Decision: No uncited Layer C metric or other research-frontier metric may be added to the package. Any such addition must carry literature grounding in `inst/REFERENCES.md` before implementation is considered release-ready.
- Status: Accepted
- Notes: Project-defined compatibility behavior remains allowed only when explicitly documented as package-defined and backed by a stable decision record.

#### D-034: Public API Boundary
- Decision: The stable public API of `hydroMetrics` consists of the exported orchestration functions (`gof`, `ggof`, `preproc`, `valindex`), the exported `hm_result()` utility constructor, and the documented exported metric wrappers present at the `0.3.1` baseline; uppercase hydroGOF-style names used as method labels inside `gof()` / `ggof()` are orchestration labels, not exported standalone functions, unless explicitly exported in a future release.
- Status: Accepted
- Notes: `hm_result()` is a stable low-level utility constructor for `hm_result` S3 objects, not a primary metric-evaluation entry point. Internal registries, engine internals, helper functions, and implementation-location details are not part of the stable public API unless explicitly promoted later. Public aliases are allowed only for compatibility continuity, transition support, or clear usability value, and every exported alias must have a canonical target and lifecycle status (`stable`, `compatibility`, `deprecated`, or explicitly documented `experimental`). No stable exported function may be removed or renamed without an explicit deprecation path, NEWS entry, and migration guidance where relevant.

#### D-035: Return Object Contract
- Decision: API stability in `hydroMetrics` includes return type, output shape, naming/schema, and warning/error behavior in addition to function signatures. Scalar metric wrappers are expected to return successful length-1 numeric results unless explicitly documented otherwise; `gof`, `ggof`, `preproc`, and `valindex` must preserve their documented return classes, output structure, and interpretation rules; and changes in warning/error behavior for stable functions are treated as public-contract changes unless clearly documented as bug fixes.
- Status: Accepted
- Notes: Output names, row/column interpretation, and single-series vs multi-series shape rules are part of the stable contract where documented. Missing-data handling, undefined-domain handling, and edge-case behavior are part of the return contract because they determine whether users receive a value, `NA`, warning, or error. Stable functions must not silently switch default output mode from numeric/vector/matrix/data.frame/S3 structure to a materially different default structure without deliberate versioned API change.

### Stage 6 Pareto Disposition
- Decision: Phase 3 is complete, `pareto_skill` remains deferred, and any future Pareto-based calibration support should be implemented as a helper/evaluation utility rather than as a registry metric.
- Status: Accepted
- Notes: Current literature support fits multi-objective calibration workflows, Pareto-front evaluation, and best-compromise selection more strongly than a `sim, obs -> scalar` Pareto metric. A future `pareto_evaluate()`-style helper remains the preferred direction.

## Retained Supporting Records (Former Numbering; Not Canonical IDs)

These records preserve decisions whose numbering was later reused but whose
substance still helps explain the current package structure. They are retained
for traceability and should not be extended as the active canonical decision
sequence.

#### Former D-025: Phase 2B Batch 2 KGE Component Metrics (beta/alpha/r)
- Decision: Add clean-room parity metrics `beta`, `alpha`, and `r` as explicit KGE components, with wrappers routed through the Phase 2A preprocessing pipeline.
- Status: Retained supporting record
- Notes: Former numbering only. The package still exposes these metrics, but active canonical `D-025` now refers to the `gof()` output contract.

#### Former D-026: Phase 2B Batch 3 Legacy NSE Alias Exports
- Decision: Add `NSeff`, `mNSeff`, `rNSeff`, and `wsNSeff` as thin compatibility wrappers that route to existing metric ids (`nse`, `mnse`, `rnse`, `wsnse`) through `gof()`.
- Status: Retained supporting record
- Notes: Former numbering only. Wrapper behavior remains current, but active canonical `D-026` now governs canonical metric IDs and alias handling.

#### Former D-027: Phase 2B Batch 4A APFB/HFB Modern Scalar Exports
- Decision: Add `APFB` and `HFB` as clean-room compatibility exports that return numerically coercible S3 scalars with class `c("hydro_metric_scalar", "numeric")`.
- Status: Retained supporting record
- Notes: Former numbering only. The scalar-output contract remains current, while the exact wrapper-routing path is governed by the later orchestration and consolidation records below.

#### Former D-028: Phase 2B Batch 4B Modern Orchestration Compatibility Layer
- Decision: Export `preproc`, `gof`, `ggof`, and `valindex` as clean-room compatibility wrappers over the existing preprocessing engine and registered metric dispatch, with structured S3 returns.
- Status: Retained supporting record
- Notes: Former numbering only. `preproc` remains a public wrapper around `.hm_prepare_inputs`; `gof` returns class `hydro_metrics`; `ggof` is tabular-only (class `hydro_metrics_batch`) and does not produce plots; `valindex` is a thin wrapper delegating to `gof(methods = fun, ...)`.

#### Former D-029: Phase 2C Metric Engine Consolidation
- Decision: Consolidate to a single canonical metric tree in `R/core_metrics.R`, remove duplicate `R/metrics/*` definitions, and enforce registry-only metric execution from orchestration wrappers.
- Status: Retained supporting record
- Notes: Former numbering only. The current package still follows the single-tree / registry-execution model, while active canonical `D-029` now refers to the `br2` literature correction policy.

## Historical and Superseded Decisions

These entries are preserved for traceability but should not be treated as the
current governing record.

#### D-015: Bias-Corrected R2 Formula
- Decision: `br2` is defined as `r^2 * (min(sd(sim), sd(obs))/max(sd(sim), sd(obs)))^2 * (min(mean(sim), mean(obs))/max(mean(sim), mean(obs)))^2`.
- Status: Superseded
- Notes: Superseded by active canonical `D-029`. This older project definition is retained only as historical record.

#### D-020: Correlation and Scale Compatibility Metrics
- Decision: `rpearson` and `rspearman` are direct correlation wrappers with explicit constant-series NA guards; `rsd` is defined as `sd(sim)/sd(obs)`.
- Status: Historical
- Notes: Retained as a mixed Phase 2 compatibility record. The current canonical Pearson alias policy is governed by active `D-026`, while `rsd` and `rspearman` remain part of the package metric surface.

#### D-021: gof/ggof Compatibility Wrappers
- Decision: `gof()` resolves method names case-insensitively and returns named numeric vector (single series) or numeric matrix with metrics as rows (multi-series); `ggof()` builds a simple bar plot from `gof()` output.
- Status: Historical
- Notes: The `gof()` method-resolution and output-shape portions were refined into active `D-025` and `D-027`. The `ggof()` plotting statement no longer matches the remediated package state, where `ggof()` is a non-plotting tabular helper.

#### D-022: Batch 8A Compatibility Definitions
- Decision: `cp` is defined as `1 - sum((obs_t - sim_t)^2)/sum((obs_t - obs_{t-1})^2)` on aligned `t = 2..n`; `preproc(keep = "pairwise")` currently uses the same complete-case row filter as `keep = "complete"`; `valindex` is a project-defined weighted aggregate of normalized `gof()` metrics.
- Status: Historical
- Notes: Retained as a Phase 2 compatibility checkpoint. The current `valindex()` contract is the thin wrapper preserved in Former `D-028`, and this earlier aggregate-definition wording is no longer the active governing record.

#### Former D-030A: Phase 2 Wrapper Naming Freeze
- Decision: Freeze the Phase 2 public compatibility surface with legacy hydroGOF-style uppercase exports (`NSE`, `KGE`, `MAE`, `RMSE`, `PBIAS`, `R2`, `NRMSE`) while retaining existing lowercase Phase 2 exports for backward compatibility.
- Status: Historical
- Notes: This record no longer matches the remediated `0.3.1` package state. Uppercase hydroGOF-style names remain compatibility method labels through orchestration entry points rather than standalone exported wrapper functions.

#### Former D-030B: gof Extended Metric Selection Contract
- Decision: `gof()` defaults to the compat-10 metric set (`nse`, `kge`, `rmse`, `pbias`, `mae`, `mse`, `r2`, `ve`, `rsr`, `nrmse`), while `gof(extended = TRUE)` expands omitted/`NULL` selection to all automatically applicable registered metrics for the current input context.
- Status: Superseded
- Notes: Superseded by active canonical `D-027`. This record is retained only because `D-030` was historically reused before the canonical Phase 3 numbering was reconciled.

#### Former D-031: Phase 2 Benchmark Outcome
- Decision: `fast = TRUE` is not needed for Phase 2 and is not added to the public API.
- Status: Historical
- Notes: Retained as a Phase 2 release-governance record. The benchmark evidence it referenced is no longer part of the active package-boundary governance for the remediated `0.3.1` baseline.
