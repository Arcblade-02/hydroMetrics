# hydroMetrics

`hydroMetrics` is a clean-room MIT-licensed R package for hydrological model
evaluation metrics.

## Scope

- Public orchestration entry points: `gof()`, `ggof()`, `preproc()`, and `valindex()`
- Exported compatibility wrappers: `APFB()`, `HFB()`, `NSeff()`, `mNSeff()`,
  `rNSeff()`, `wsNSeff()`, `alpha()`, `beta()`, `mae()`, `pbias()`, `r()`,
  and `rsr()`
- Additional metric ids are available through `gof(methods = ...)` and the
  internal metric registry

## Install

```r
install.packages("pak")
pak::pak("Arcblade-02/hydroMetrics")
```

## Minimal Usage

```r
library(hydroMetrics)

sim <- c(1, 2, 3, 4)
obs <- c(1, 2, 2, 4)

gof(sim, obs, methods = c("NSE", "rmse", "pbias"))
ggof(sim, obs, methods = c("NSE", "rmse"))
mae(sim, obs)
```

## Compatibility Notes

- `ggof()` returns a tabular `hydro_metrics_batch` object and does not open a
  graphics device.
- `APFB()` requires indexed `zoo` or `xts` inputs.
- `preproc()` currently supports single-series vector or indexed inputs only.

## Development Notes

- Clean-room implementation policy: [CLEAN_ROOM_POLICY.md](CLEAN_ROOM_POLICY.md)
- Formula/reference scaffold: [inst/REFERENCES.md](inst/REFERENCES.md)
- Compatibility tracker: [COMPATIBILITY_TRACKER.md](COMPATIBILITY_TRACKER.md)
