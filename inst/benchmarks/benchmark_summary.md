# Historical Phase 2 Benchmark Summary

Historical artifact retained for traceability. The active Workstream B
benchmark baseline now lives in `workstream_b_benchmark_summary.md`.

- Generated: 2026-03-09 22:28:08 +0530
- Methodology: compare direct `metric_nse()` execution, the `NSE()` compatibility wrapper, and `gof(methods = "NSE")` on identical numeric inputs.
- Input sizes: 1e3, 1e4, 1e5, and 1e6.
- Timing backend: `microbenchmark` nanosecond timer.
- Repetitions: 10 iterations for sizes below 1e6; 3 iterations at 1e6 for feasibility.
- Reproducibility: deterministic random seed per input size; results written to `inst/benchmarks/benchmark_results.csv`.

## Aggregated Results

- `direct_metric_nse`, n=1000: mean elapsed 0.000012s, median elapsed 0.000008s, mean relative overhead 1.000000x, median relative overhead 1.000000x
- `gof_NSE`, n=1000: mean elapsed 0.002242s, median elapsed 0.002232s, mean relative overhead 188.519765x, median relative overhead 187.758621x
- `NSE_wrapper`, n=1000: mean elapsed 0.005993s, median elapsed 0.002854s, mean relative overhead 504.024390x, median relative overhead 240.016821x
- `direct_metric_nse`, n=10000: mean elapsed 0.000089s, median elapsed 0.000081s, mean relative overhead 1.000000x, median relative overhead 1.000000x
- `gof_NSE`, n=10000: mean elapsed 0.002579s, median elapsed 0.002586s, mean relative overhead 28.871697x, median relative overhead 28.947044x
- `NSE_wrapper`, n=10000: mean elapsed 0.002408s, median elapsed 0.002385s, mean relative overhead 26.960479x, median relative overhead 26.697268x
- `direct_metric_nse`, n=100000: mean elapsed 0.000804s, median elapsed 0.000800s, mean relative overhead 1.000000x, median relative overhead 1.000000x
- `gof_NSE`, n=100000: mean elapsed 0.003212s, median elapsed 0.003225s, mean relative overhead 3.995907x, median relative overhead 4.012129x
- `NSE_wrapper`, n=100000: mean elapsed 0.003777s, median elapsed 0.003790s, mean relative overhead 4.698401x, median relative overhead 4.714561x
- `direct_metric_nse`, n=1000000: mean elapsed 0.008598s, median elapsed 0.008499s, mean relative overhead 1.000000x, median relative overhead 1.000000x
- `gof_NSE`, n=1000000: mean elapsed 0.019167s, median elapsed 0.019723s, mean relative overhead 2.229399x, median relative overhead 2.293972x
- `NSE_wrapper`, n=1000000: mean elapsed 0.024329s, median elapsed 0.024200s, mean relative overhead 2.829738x, median relative overhead 2.814714x

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
[1] hydroMetrics_0.2.0 testthat_3.3.2    

loaded via a namespace (and not attached):
 [1] microbenchmark_1.5.0 vctrs_0.7.1          cli_3.6.5           
 [4] rlang_1.1.7          otel_0.2.0           purrr_1.2.1         
 [7] pkgload_1.5.0        glue_1.8.0           zoo_1.8-15          
[10] xts_0.14.2           rprojroot_2.1.1      pkgbuild_1.4.8      
[13] brio_1.1.5           grid_4.5.2           ellipsis_0.3.2      
[16] fastmap_1.2.0        lifecycle_1.0.5      memoise_2.0.1       
[19] compiler_4.5.2       fs_1.6.6             sessioninfo_1.2.3   
[22] rstudioapi_0.18.0    lattice_0.22-9       R6_2.6.1            
[25] usethis_3.2.1        magrittr_2.0.4       tools_4.5.2         
[28] withr_3.0.2          devtools_2.4.6       remotes_2.5.0       
[31] cachem_1.1.0         desc_1.4.3          
