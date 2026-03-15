# Benchmark Artifacts

This directory stores repo-tracked benchmark artifacts for the current
`hydroMetrics` development line. The active Workstream B benchmark baseline is
intentionally small and reviewable: it is meant to establish a reproducible
starting point before any broader benchmarking or optimization work.

## Active Baseline

The current benchmark source of truth is:

- `workstream_b_benchmark_suite.R`
- `workstream_b_benchmark_summary.md`
- `workstream_b_benchmark_results.csv`
- `tools/run_workstream_b_benchmark_baseline.R`

This baseline measures current public-facing orchestration paths on
deterministic numeric inputs with no missing values:

- `NSeff(sim, obs)`
- `gof(sim, obs, methods = "nse")`
- `gof(sim, obs)`
- `gof(sim_matrix, obs_matrix, methods = c("nse", "rmse"))`

Current baseline assumptions:

- synthetic aligned numeric inputs with fixed random seeds
- input scales `1e3`, `1e5`, and `1e6`
- three columns for the multi-series path
- `microbenchmark` is required so the timing backend is explicit and stable
- primary use is local/manual reproducibility; CI use is optional and summary-
  oriented rather than gating

Run the active baseline from the repository root with:

```r
Rscript tools/run_workstream_b_benchmark_baseline.R
```

## Historical and Exploratory Artifacts

The following files are retained for traceability, but they are not the active
benchmark baseline for the current `0.3.1` development state:

- `phase2_benchmark_suite.R`
- `benchmark_summary.md`
- `benchmark_results.csv`

These Phase 2 artifacts benchmarked internal `metric_nse()`, the old `NSE()`
wrapper path, and `gof(methods = "NSE")`, and the recorded session summary
shows package version `0.2.0`.

The broader exploratory/stress suite remains available here:

- `performance_suite.R`
- `tools/run_performance_suite.R`

That suite is still useful for ad hoc profiling and stress checks, but it is
not the authoritative baseline summary for Workstream B.
