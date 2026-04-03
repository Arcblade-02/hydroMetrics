# hydroMetrics

![R-CMD-check](https://github.com/Arcblade-02/hydroMetrics/actions/workflows/R-CMD-check.yml/badge.svg)

`hydroMetrics` is a clean-room MIT-licensed R package for hydrological model
evaluation. The current `0.4.0` release line combines a compat-oriented
default metric surface with broader gated deterministic diagnostics,
regime-sensitive evaluation, and release-facing validation artifacts for
reproducible package checks.

## Scope

- Stable orchestration entry points: `gof()`, `ggof()`, `preproc()`, and
  `valindex()`
- Stable discovery helpers: `metric_search()` and `metric_preset()`
- Stable plotting helpers: `plot_hydrograph()` and `plot_fdc()`
- Stable exported metric surface: documented exported metric wrappers
- Stable exported utility: `hm_result()` as the low-level constructor for
  `hm_result` S3 objects
- Compatibility exports retained at the `0.4.0` baseline: `HFB()`, `NSeff()`,
  `mNSeff()`, `rNSeff()`, `wsNSeff()`, and `mutual_information_score()`
- Deprecated exported forwarding wrappers retained temporarily at the `0.4.0`
  baseline: `tail_dependence_score()` and `extended_valindex()`
- Uppercase hydroGOF-style labels accepted by `gof()` / `ggof()` are
  orchestration method labels, not exported standalone functions: `NSE`,
  `KGE`, `MAE`, `RMSE`, `PBIAS`, `R2`, `NRMSE`, `mNSE`, `rNSE`, and `wsNSE`
- Deprecated orchestration aliases remain accepted during method selection,
  but they are not discovery-canonical metric ids: `rPearson` resolves to `r`,
  `tail_dependence_score` resolves to
  `upper_tail_conditional_exceedance`, and `extended_valindex` resolves to
  `composite_performance_index`
- Discovery APIs such as `metric_search()` and `metric_preset()` expose the
  lowercase registry-backed canonical metric ids rather than compatibility or
  deprecated aliases
- Default `gof()` remains compat-oriented, while `gof(extended = TRUE)`
  exposes the broader automatically applicable deterministic surface
- Seasonal, regime-sensitive, information-theory, and tail-sensitive metrics
  are available through documented exported wrappers and documented `gof()`
  method selection when their input contracts hold

## Lifecycle Policy

- `stable`: exported orchestration entry points, documented exported helpers
  such as `metric_search()`, `metric_preset()`, `plot_hydrograph()`,
  `plot_fdc()`, and `hm_result()`, and documented exported metric wrappers
  other than the explicit compatibility and deprecated exports below
- `compatibility`: `HFB()`, `NSeff()`, `mNSeff()`, `rNSeff()`, `wsNSeff()`,
  and `mutual_information_score()`
- `deprecated`: exported forwarding wrappers `tail_dependence_score()` and
  `extended_valindex()`, plus orchestration-only deprecated aliases such as
  `rPearson` / `rpearson` that continue to resolve to canonical metric ids
- `experimental`: no exported functions at the `0.4.0` baseline

## Alias Policy

- Exported compatibility wrappers retained for historical continuity route to
  canonical registry metrics or canonical exported wrappers:
  `NSeff() -> nse`, `mNSeff() -> mnse`, `rNSeff() -> rnse`,
  `wsNSeff() -> wsnse`, `HFB() -> hfb`, and
  `mutual_information_score() -> mutual_information()`
- Exported deprecated forwarding wrappers remain callable temporarily, but
  their names are no longer canonical registry metric ids:
  `tail_dependence_score() -> upper_tail_conditional_exceedance()` and
  `extended_valindex() -> composite_performance_index()`
- Uppercase hydroGOF-style names accepted by `gof()` / `ggof()` are
  orchestration-only method labels and are not exported standalone functions
- Deprecated `rPearson` requests are resolved to canonical `r` during
  orchestration-level method selection
- Discovery-facing canonical ids remain the lowercase registry-backed metric
  ids returned by `metric_search()` and `metric_preset()`

## Install

For local release validation, build the source bundle with `R CMD build .` and
install the generated tarball:

```r
install.packages("hydroMetrics_0.4.0.tar.gz", repos = NULL, type = "source")
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

- `vignette("getting-started", package = "hydroMetrics")` for a concise
  discovery-and-evaluation workflow using `preproc()`, `metric_search()`, and
  `gof()`
- `vignette("metric-reference", package = "hydroMetrics")` for a concise
  metric catalog and navigation guide
- `vignette("calibration-guide", package = "hydroMetrics")` for metric
  selection in calibration workflows
- `?gof`, `?ggof`, `?preproc`, and `?hm_result` for API details
- `?metric_search` for the first metric-discovery baseline
- `?metric_preset` for resolving documented preset groups to
  `gof(methods = ...)` ids
- `?plot_hydrograph` and `?plot_fdc` for the lightweight static plotting
  helpers

## Metric Discovery

`metric_search()` provides a small discovery-oriented view over the current
registry metadata. The first baseline can filter by:

- text across metric id, name, description, exported wrapper names, and preset
  labels
- category
- tags
- curated preset groups
- whether a metric has an exported wrapper path
- whether a metric is reached by a documented compatibility export

Discovery results use lowercase registry-backed canonical metric ids. Exported
compatibility wrappers and deprecated forwarding wrappers may appear in the
`exported_wrappers` annotation for a canonical metric, but they are not
returned as independent canonical ids. For example,
`mutual_information_score()` is surfaced under canonical
`mutual_information` rather than as a second discovery-canonical metric.

Current preset groups are:

- `recommended`
- `compatibility_core`
- `deterministic_error`
- `correlation_agreement`
- `flow_duration_distribution`
- `probabilistic_uncertainty`
- `seasonal_regime`

Examples:

```r
metric_search(text = "bias")
metric_search(preset = "probabilistic_uncertainty")
metric_search(category = "correlation", exported = TRUE)
metric_preset("recommended")
gof(sim, obs, methods = metric_preset("recommended"))
```

This first baseline does not search formulas or applicability guards, and it
does not replace the detailed metric reference vignette.

## Validation Notes

- The default public baseline is the compat-10 `gof()` surface together with
  the exported compatibility wrappers, deprecated forwarding wrappers, and
  documented exported metric wrappers.
- Stable return contracts are part of the public API: `gof()` returns a
  `hydro_metrics` numeric vector or matrix, `ggof()` returns a tabular
  `hydro_metrics_batch` object, `preproc()` returns `hydro_preproc`, and
  scalar wrappers return numeric results with documented classes where
  applicable.
- `hm_result()` is a stable low-level constructor for `hm_result`
  `data.frame` objects used by the engine-facing result path.
- Stable condition contracts are also part of the public API: orchestration
  entry points document when they error on invalid inputs, unknown methods,
  incompatible shapes, missing-data mode conflicts, or inherited metric-domain
  failures, and compatibility wrappers document when they error versus warn and
  return `NA`.
- `gof(extended = TRUE)` expands to the broader deterministic registry
  surface, but only when each metric's documented applicability conditions are
  satisfied.
- Seasonal and event/tail metrics are intentionally gated and are not exposed
  for unsupported plain deterministic inputs.
- Release-facing validation summaries and the compact USGS NWIS real-data
  subset artifacts are available under `inst/validation/`.
- `ggof()` returns a tabular `hydro_metrics_batch` object and does not open a
  graphics device.
- `preproc()` currently supports single-series vector or indexed inputs only.

## Development Notes

- Contributor guidance: [CONTRIBUTING.md](CONTRIBUTING.md)
- Published governance summary: [GOVERNANCE.md](GOVERNANCE.md)
- `0.4.x` CRAN/readiness baseline: [CRAN_READINESS.md](CRAN_READINESS.md)
- Clean-room implementation policy: [CLEAN_ROOM_POLICY.md](CLEAN_ROOM_POLICY.md)
- Formula/reference scaffold: [inst/REFERENCES.md](inst/REFERENCES.md)
- Compatibility tracker: [COMPATIBILITY_TRACKER.md](COMPATIBILITY_TRACKER.md)
