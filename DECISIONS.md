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
- Decision: Core metrics (`nse`, `rmse`, `pbias`, `mae`, `mse`, `nrmse`, `r`, `r2`, `kge`, `rsr`, `mape`, `mpe`, `ve`, `nrmse_sd`, `me`, `d`, `md`, `rd`, `dr`, `br2`, `rnse`, `mnse`, `wnse`, `wsnse`, `ubrmse`, `ssq`, `kgekm`, `kgelf`, `kgenp`, `skge`, `pbiasfdc`) are lazily auto-registered on first registry/engine access.
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
