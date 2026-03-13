# hydroMetrics

![R-CMD-check](https://github.com/Arcblade-02/hydroMetrics/actions/workflows/R-CMD-check.yml/badge.svg)

`hydroMetrics` is a clean-room MIT-licensed R package for hydrological model
evaluation metrics. The current post-Phase-3 release-hardening line covers
compatibility/default metrics, extended deterministic diagnostics, seasonal
and regime-sensitive evaluation, wrapper-only probabilistic workflows, and
release-facing validation artifacts for reproducible package checks.

## Scope

- Public orchestration entry points: `gof()`, `ggof()`, `preproc()`, and `valindex()`
- Legacy hydroGOF-style public wrappers: `NSE()`, `KGE()`, `MAE()`, `RMSE()`,
  `PBIAS()`, `R2()`, `NRMSE()`, `NSeff()`, `mNSeff()`, `rNSeff()`, and
  `wsNSeff()`
- Additional exported compatibility wrappers retained alongside the legacy
  names: `APFB()`, `HFB()`, `alpha()`, `beta()`, `mae()`, `pbias()`, `r()`,
  and `rsr()`
- Default `gof()` remains compat-oriented, while `gof(extended = TRUE)`
  exposes the broader automatically applicable deterministic surface
- Seasonal, regime-sensitive, information-theory, and tail-sensitive metrics
  are available through exported wrappers and the registered metric surface
  when their documented input contracts hold
- Probabilistic metrics such as `crps()`, `picp()`, `mwpi()`, and
  `skill_score()` remain wrapper-only special-interface workflows rather than
  part of default deterministic `gof(sim, obs)` auto-selection

## Install

For local release validation, build the source bundle with `R CMD build .` and
install the generated tarball:

```r
install.packages("hydroMetrics_0.3.0.tar.gz", repos = NULL, type = "source")
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
- `vignette("metric-reference", package = "hydroMetrics")` for a concise
  metric catalog and navigation guide
- `vignette("calibration-guide", package = "hydroMetrics")` for metric
  selection in calibration workflows
- `vignette("uncertainty-eval", package = "hydroMetrics")` for probabilistic
  and interval-evaluation workflows
- `?gof`, `?ggof`, and `?preproc` for API details

## Validation Notes

- The default public baseline remains the compat-10 `gof()` surface together
  with the exported legacy hydroGOF-style wrappers.
- `gof(extended = TRUE)` expands to the broader deterministic registry surface
  only when each metric's documented applicability conditions are satisfied.
- Seasonal and event/tail metrics are intentionally gated and are not exposed
  for unsupported plain deterministic inputs.
- Release-facing validation summaries and the compact USGS NWIS real-data
  subset artifacts live under `inst/validation/`.
- `ggof()` returns a tabular `hydro_metrics_batch` object and does not open a
  graphics device.
- `APFB()` requires indexed `zoo` or `xts` inputs.
- `preproc()` currently supports single-series vector or indexed inputs only.

## Development Notes

- Clean-room implementation policy: [CLEAN_ROOM_POLICY.md](CLEAN_ROOM_POLICY.md)
- Formula/reference scaffold: [inst/REFERENCES.md](inst/REFERENCES.md)
- Compatibility tracker: [COMPATIBILITY_TRACKER.md](COMPATIBILITY_TRACKER.md)
