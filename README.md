# hydroMetrics

![R-CMD-check](https://github.com/Arcblade-02/hydroMetrics/actions/workflows/R-CMD-check.yml/badge.svg)

`hydroMetrics` is a clean-room MIT-licensed R package for hydrological model
evaluation metrics. The current release-hardening line is aligned for the
corrected `0.2.1` Phase 2 stable package version.

## Scope

- Public orchestration entry points: `gof()`, `ggof()`, `preproc()`, and `valindex()`
- Legacy hydroGOF-style public wrappers: `NSE()`, `KGE()`, `MAE()`, `RMSE()`,
  `PBIAS()`, `R2()`, `NRMSE()`, `NSeff()`, `mNSeff()`, `rNSeff()`, and
  `wsNSeff()`
- Additional exported compatibility wrappers retained alongside the legacy
  names: `APFB()`, `HFB()`, `alpha()`, `beta()`, `mae()`, `pbias()`, `r()`,
  and `rsr()`
- Additional metric ids are available through `gof(methods = ...)` and the
  internal metric registry

## Install

For local release validation, build the source bundle with `R CMD build .` and
install the generated tarball:

```r
install.packages("hydroMetrics_0.2.1.tar.gz", repos = NULL, type = "source")
```

If you want the latest repository snapshot instead:

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
NSE(sim, obs)
mae(sim, obs)
```

## Documentation

- `vignette("getting-started", package = "hydroMetrics")` for a minimal
  end-to-end walkthrough
- `?gof`, `?ggof`, and `?preproc` for API details

## Compatibility Notes

- Phase 2 keeps both the legacy hydroGOF-style public wrapper names and the
  previously exported lowercase/internal-style compatibility names where they
  already existed.
- `ggof()` returns a tabular `hydro_metrics_batch` object and does not open a
  graphics device.
- `APFB()` requires indexed `zoo` or `xts` inputs.
- `preproc()` currently supports single-series vector or indexed inputs only.

## Development Notes

- Clean-room implementation policy: [CLEAN_ROOM_POLICY.md](CLEAN_ROOM_POLICY.md)
- Formula/reference scaffold: [inst/REFERENCES.md](inst/REFERENCES.md)
- Compatibility tracker: [COMPATIBILITY_TRACKER.md](COMPATIBILITY_TRACKER.md)
