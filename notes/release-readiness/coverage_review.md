# Coverage Review

- Generated: 2026-03-10 00:14:43 IST
- Overall coverage: `86.59%`
- Exported public surface under review: `NSE, KGE, RMSE, MAE, PBIAS, R2, NRMSE, gof, ggof, preproc, valindex`
- Public preprocessing/export files observed in coverage output: `R/ggof.R||62.50; R/gof.R||84.31; R/preproc.R||80.36; R/valindex.R||73.81`

## Interpretation

- One or both test commands failed; see the raw log for exact output.
- Wrapper-specific coverage is constrained by the current exported surface. On this snapshot only `gof`, `ggof`, and `hm_result` are exported.
- Preprocessing coverage is reviewed through any `R/preproc.R` entries emitted by `covr`; absence of a file-level line item is recorded rather than inferred.
- Edge-case branch coverage requires manual follow-up where `covr` does not expose branch-level detail in the current environment.

## Raw coverage output

```text
$ C:/PROGRA~1/R/R-45~1.2/bin/x64/Rscript.exe --vanilla C:\Users\prita\AppData\Local\Temp\RtmpYpWrUr\release-readiness-d40c493b564f.R
OVERALL==86.59
FILE==R/classes.R||22.22
FILE==R/core_metrics.R||90.64
FILE==R/cp.R||75.00
FILE==R/engine.R||100.00
FILE==R/ggof.R||62.50
FILE==R/gof.R||84.31
FILE==R/HydroEngine.R||83.33
FILE==R/MetricRegistry.R||28.57
FILE==R/pfactor.R||70.00
FILE==R/preproc.R||80.36
FILE==R/registry.R||76.00
FILE==R/rfactor.R||70.00
FILE==R/validate.R||66.67
FILE==R/valindex.R||73.81
FILE==R/zzz.R||0.00
[stderr]
      1 [main] sh (72680) C:\rtools45\usr\bin\sh.exe: *** fatal error - couldn't create signal pipe, Win32 error 5
      0 [main] sh (67080) C:\rtools45\usr\bin\sh.exe: *** fatal error - couldn't create signal pipe, Win32 error 5
```
