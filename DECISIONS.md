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
- Decision: Core metrics (`nse`, `rmse`, `pbias`, `mae`, `mse`, `nrmse`, `r`, `r2`, `kge`, `rsr`, `mape`, `mpe`, `ve`, `nrmse_sd`) are lazily auto-registered on first registry/engine access.
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
