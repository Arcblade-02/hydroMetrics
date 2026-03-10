# Wrapper Runtime Verification

- Review date: 2026-03-10
- Package version installed in clean library: `0.2.0`
- Clean library path: `D:/R Package/hydroMetrics/notes/wrapper-export-closure/clean-lib`
- Export count: `24`

## Target wrapper availability

- `NSE`: `present`
- `KGE`: `present`
- `RMSE`: `present`
- `R2`: `present`
- `NRMSE`: `present`
- `PBIAS`: `present`
- `gof`: `present`
- `ggof`: `present`
- `preproc`: `present`
- `valindex`: `present`

## Direct runtime call results

- `NSE(sim, obs)`: `0.5789473684210527`
- `KGE(sim, obs)`: `0.5781739727203405`
- `RMSE(sim, obs)`: `0.7071067811865476`
- `R2(sim, obs)`: `0.9398496240601505`
- `NRMSE(sim, obs, norm = "mean")`: `0.3142696805273545`
- `PBIAS(sim, obs)`: `22.2222222222222214`
- `ggof(sim, obs, methods = "NSE")` class: `hydro_metrics_batch, data.frame`
- `valindex(sim, obs, fun = "NSE")` class: `hydro_metrics`

Warnings or deviations: no runtime warnings; attaching the package emits the
expected name-masking message for exported `beta()` versus `base::beta()`.

Overall status: PASS
