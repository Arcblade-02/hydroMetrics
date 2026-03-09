# v0.2.0 Pre-Tag Performance Validation Record

Run date: 2026-03-05  
Runner: `Rscript tools/run_performance_suite.R`

Snapshot (from `performance_summary.csv`):

- `direct_nse_median_ns`: `48.05`
- `gof_single_median_ns`: `2079.2`
- `gof_multi_median_ns`: `2714.85`
- `gof_batch_median_ns`: `3989.8`
- `large_vector_elapsed_sec`: `0.07`
- `matrix_scaling_elapsed_sec`: `0.11`
- `memory_delta_mb`: `0`
- `metric_time_pct`: `2.310985`
- `registry_dispatch_pct`: `97.689015`
- `load_time_elapsed_sec`: `0.05`

Section notes:

- Matrix scaling ratio (`m=20` vs `m=10`) was `2.20` (`linear_scaling_confirmed: TRUE`).
- `Rprof` emitted zero samples on this run; registry/metric split used fallback ratio from section 1 medians, and the raw `summaryRprof` output is preserved in `registry_profile_summary.txt`.
