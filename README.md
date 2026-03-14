# hydroMetrics

![R-CMD-check](https://github.com/Arcblade-02/hydroMetrics/actions/workflows/R-CMD-check.yml/badge.svg)

`hydroMetrics` is a clean-room MIT-licensed R package for hydrological model
evaluation. The current `0.3.1` release line combines a compat-oriented
default metric surface with broader gated deterministic diagnostics,
seasonal/regime-sensitive evaluation, wrapper-only probabilistic workflows,
and release-facing validation artifacts for reproducible package checks.

## Scope

- Stable orchestration entry points: `gof()`, `ggof()`, `preproc()`, and
  `valindex()`
- Stable exported metric surface: documented exported metric wrappers
- Stable exported utility: `hm_result()` as the low-level constructor for
  `hm_result` S3 objects
- Compatibility exports retained at the `0.3.1` baseline: `APFB()`, `HFB()`,
  `NSeff()`, `mNSeff()`, `rNSeff()`, and `wsNSeff()`
- Uppercase hydroGOF-style labels accepted by `gof()`/`ggof()` are
  orchestration method labels, not exported standalone functions: `NSE`,
  `KGE`, `MAE`, `RMSE`, `PBIAS`, `R2`, `NRMSE`, `mNSE`, `rNSE`, and `wsNSE`
- Deprecated orchestration alias: `rPearson` resolves to canonical `r` during
  method selection
- Default `gof()` remains compat-oriented, while `gof(extended = TRUE)`
  exposes the broader automatically applicable deterministic surface
- Seasonal, regime-sensitive, information-theory, and tail-sensitive metrics
  are available through documented exported wrappers and documented `gof()`
  method selection when their input contracts hold
- Probabilistic metrics such as `crps()`, `picp()`, `mwpi()`, and
  `skill_score()` remain wrapper-only special-interface workflows rather than
  part of default deterministic `gof(sim, obs)` auto-selection

## Install

For local release validation, build the source bundle with `R CMD build .` and
install the generated tarball:

```r
install.packages("hydroMetrics_0.3.1.tar.gz", repos = NULL, type = "source")
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

gof(sim, obs, methods = c("nse", "rmse", "pbias"))
ggof(sim, obs, methods = c("nse", "rmse"))
NSeff(sim, obs)
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
- `?gof`, `?ggof`, `?preproc`, and `?hm_result` for API details

## Validation Notes

- The default public baseline is the compat-10 `gof()` surface together with
  the exported compatibility wrappers and documented exported metric wrappers.
- Stable return contracts are part of the public API: `gof()` returns a
  `hydro_metrics` numeric vector or matrix, `ggof()` returns a tabular
  `hydro_metrics_batch` object, `preproc()` returns `hydro_preproc`, and
  scalar wrappers return numeric results with documented classes where
  applicable.
- `hm_result()` is a stable low-level constructor for `hm_result`
  `data.frame` objects used by the engine-facing result path.
- `gof(extended = TRUE)` expands to the broader deterministic registry
  surface, but only when each metric's documented applicability conditions are
  satisfied.
- Seasonal and event/tail metrics are intentionally gated and are not exposed
  for unsupported plain deterministic inputs.
- Release-facing validation summaries and the compact USGS NWIS real-data
  subset artifacts are available under `inst/validation/`.
- `ggof()` returns a tabular `hydro_metrics_batch` object and does not open a
  graphics device.
- `APFB()` requires indexed `zoo` or `xts` inputs.
- `preproc()` currently supports single-series vector or indexed inputs only.

## Development Notes

- Clean-room implementation policy: [CLEAN_ROOM_POLICY.md](CLEAN_ROOM_POLICY.md)
- Formula/reference scaffold: [inst/REFERENCES.md](inst/REFERENCES.md)
- Compatibility tracker: [COMPATIBILITY_TRACKER.md](COMPATIBILITY_TRACKER.md)
