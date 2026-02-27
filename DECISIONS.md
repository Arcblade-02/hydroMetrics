# Architecture Decisions

## D-001: License and Clean-Room Boundary
- Decision: `hydroMetrics` is MIT-licensed and implemented under clean-room rules.
- Status: Accepted
- Notes: No code may be copied from GPL-family projects. Derivations must come from literature and independent design.

## D-002: Output Object Model
- Decision: Public API returns S3 objects.
- Status: Accepted
- Notes: `evaluate_metrics()` now returns `hydrometrics_result` as an S3 class over `data.frame`.

## D-003: Internal Engine Style
- Decision: Functions-first internal engine (not R6) for Phase 0/1.
- Status: Accepted
- Notes: Keep internals simple and testable; reconsider R6 only if stateful workflows become necessary.

## D-004: Output Data Formats
- Decision: `evaluate_metrics()` returns base `data.frame` (Phase-1), wrapped as `hydrometrics_result`.
- Status: Accepted
- Notes: Tibble support may be added later behind an optional dependency.

## D-005: R2 Definition
- Decision: `R2` means Pearson correlation squared (`r^2`) and never NSE.
- Status: Accepted
- Notes: Naming and documentation must keep this distinction explicit.

## D-006: Metric Registry Storage
- Decision: Registry is stored in a package-internal environment.
- Status: Accepted
- Notes: Environment storage gives O(1)-style id lookup and straightforward uniqueness checks.
