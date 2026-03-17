# Workstream B Benchmark Summary

- Generated: 2026-03-15 10:55:03 +0530
- Status: active current benchmark baseline for the remediated `0.3.1` development line.
- Methodology: benchmark current public-facing orchestration paths rather than internal metric functions or retired uppercase wrapper calls.
- Targets: `NSeff(sim, obs)`, `gof(sim, obs, methods = "nse")`, `gof(sim, obs)`, and `gof(sim_matrix, obs_matrix, methods = c("nse", "rmse"))`.
- Input scales: `1e3`, `1e5`, and `1e6` rows; the multi-series path uses `3` aligned columns.
- Timing backend: `microbenchmark` nanosecond timer. This baseline requires `microbenchmark` rather than silently changing timing methodology.
- Repetitions: `20` at `1e3`, `10` at `1e5`, and `3` at `1e6`.
- Assumptions: deterministic seeded Gaussian-style numeric inputs, no missing values, and no preprocessing-sensitive options.
- Intended usage: local/manual reproducible baseline first; optional CI summary generation later, but not a gating performance budget.
- Relative overhead is reported against `NSeff` at the same scale for the single-series paths; the matrix path is reported directly and left `NA` for that comparison.

## Results

| target | shape | n | iterations | mean_sec | median_sec | rel_mean_vs_NSeff | rel_median_vs_NSeff |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `NSeff` | `single` | 1000 | 20 | 0.000570 | 0.000041 | 1.000000 | 1.000000 |
| `gof_nse` | `single` | 1000 | 20 | 0.012265 | 0.004028 | 21.507214 | 99.341570 |
| `gof_default_compat10` | `single` | 1000 | 20 | 0.005553 | 0.005137 | 9.737183 | 126.670119 |
| `gof_matrix_nse_rmse` | `matrix_3col` | 1000 | 20 | 0.004851 | 0.004733 | NA | NA |
| `NSeff` | `single` | 100000 | 10 | 0.002553 | 0.002445 | 1.000000 | 1.000000 |
| `gof_nse` | `single` | 100000 | 10 | 0.005351 | 0.005232 | 2.095789 | 2.139641 |
| `gof_default_compat10` | `single` | 100000 | 10 | 0.012046 | 0.012003 | 4.717965 | 4.908678 |
| `gof_matrix_nse_rmse` | `matrix_3col` | 100000 | 10 | 0.015270 | 0.015575 | NA | NA |
| `NSeff` | `single` | 1000000 |  3 | 0.023957 | 0.023779 | 1.000000 | 1.000000 |
| `gof_nse` | `single` | 1000000 |  3 | 0.028421 | 0.026015 | 1.186333 | 1.094038 |
| `gof_default_compat10` | `single` | 1000000 |  3 | 0.082327 | 0.082867 | 3.436388 | 3.484942 |
| `gof_matrix_nse_rmse` | `matrix_3col` | 1000000 |  3 | 0.116212 | 0.099862 | NA | NA |

## Session Info

R version 4.5.2 (2025-10-31 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 11 x64 (build 26200)

Matrix products: default
  LAPACK version 3.12.1

locale:
[1] LC_COLLATE=English_India.utf8  LC_CTYPE=English_India.utf8   
[3] LC_MONETARY=English_India.utf8 LC_NUMERIC=C                  
[5] LC_TIME=English_India.utf8    

time zone: Asia/Calcutta
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] hydroMetrics_0.3.1 testthat_3.3.2    

loaded via a namespace (and not attached):
 [1] desc_1.4.3           R6_2.6.1             microbenchmark_1.5.0
 [4] devtools_2.4.6       fastmap_1.2.0        magrittr_2.0.4      
 [7] glue_1.8.0           cachem_1.1.0         remotes_2.5.0       
[10] memoise_2.0.1        lifecycle_1.0.5      cli_3.6.5           
[13] sessioninfo_1.2.3    vctrs_0.7.1          pkgload_1.5.0       
[16] compiler_4.5.2       rprojroot_2.1.1      rstudioapi_0.18.0   
[19] purrr_1.2.1          tools_4.5.2          pkgbuild_1.4.8      
[22] brio_1.1.5           ellipsis_0.3.2       otel_0.2.0          
[25] rlang_1.1.7          fs_1.6.6             usethis_3.2.1       
