# Coverage Review

- Generated: 2026-03-10 01:27:19 IST
- Overall coverage: `95.17%`
- Exported public surface under review: `NSE, KGE, RMSE, MAE, PBIAS, R2, NRMSE, gof, ggof, preproc, valindex`
- Public preprocessing/export files observed in coverage output: `R/ggof.R||85.71; R/gof.R||93.26; R/preproc.R||81.82; R/valindex.R||100.00`

## Interpretation

- One or both test commands failed; see the raw log for exact output.
- Wrapper-specific coverage is constrained by the current exported surface. On this snapshot only `gof`, `ggof`, and `hm_result` are exported.
- Preprocessing coverage is reviewed through any `R/preproc.R` entries emitted by `covr`; absence of a file-level line item is recorded rather than inferred.
- Edge-case branch coverage requires manual follow-up where `covr` does not expose branch-level detail in the current environment.

## Raw coverage output

```text
$ C:/PROGRA~1/R/R-45~1.2/bin/x64/Rscript.exe --vanilla C:\Users\prita\AppData\Local\Temp\RtmpGU4si6\release-readiness-137d44f575891.R
OVERALL==95.17
FILE==R/alpha.R||75.00
FILE==R/APFB.R||77.27
FILE==R/beta.R||75.00
FILE==R/classes.R||100.00
FILE==R/core_metrics.R||93.95
FILE==R/cp.R||75.00
FILE==R/engine.R||100.00
FILE==R/ggof.R||85.71
FILE==R/gof.R||93.26
FILE==R/HFB.R||100.00
FILE==R/hm_prepare.R||84.08
FILE==R/HydroEngine.R||97.14
FILE==R/mae.R||75.00
FILE==R/MetricRegistry.R||92.86
FILE==R/mNSeff.R||75.00
FILE==R/NSeff.R||75.00
FILE==R/pbias.R||75.00
FILE==R/pfactor.R||93.33
FILE==R/phase2_compat_wrappers.R||93.75
FILE==R/preproc.R||81.82
FILE==R/r.R||75.00
FILE==R/registry.R||100.00
FILE==R/rfactor.R||80.00
FILE==R/rNSeff.R||75.00
FILE==R/rsr.R||75.00
FILE==R/validate.R||100.00
FILE==R/valindex.R||100.00
FILE==R/wsNSeff.R||75.00
FILE==R/zzz.R||100.00
[stderr]
      0 [main] sh (84540) C:\rtools45\usr\bin\sh.exe: *** fatal error - couldn't create signal pipe, Win32 error 5
      0 [main] sh (71600) C:\rtools45\usr\bin\sh.exe: *** fatal error - couldn't create signal pipe, Win32 error 5
```
