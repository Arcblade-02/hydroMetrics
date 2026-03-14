# Phase 3 / Pre-1.0 Validation Summary

This summary records the current repository-level validation state for the
Phase 3 / pre-1.0 stabilization line.

## Phase 3 Completion

Phase 3 is fully closed for the current milestone-ready repository state.

Completed areas include:

- Layer A, Layer B, and Layer C implementation and closure
- original-plan recovery items including `gof(extended = TRUE)`, canonical
  information-theory reconciliation, `seasonal_skill`, `extended_valindex`,
  and the completed vignette set
- Stage 6 validation artifacts and the compact NWIS-backed real-data
  validation layer under `inst/validation/`

Explicit deferment:

- `pareto_skill` remains deferred on citation and architecture grounds
- any future Pareto-based support should be delivered as a helper/utility
  outside the metric registry

## Maintainer Readiness Note

- Current package version: `0.3.1`
- Repository status: milestone-ready post-Phase-3 state with aligned release
  docs, validation summaries, and merged completion work
- Suggested future tag label: `v0.3.1` (recommendation only; not created here)
- Suggested next track: post-1.0 utility design such as `pareto_evaluate()`

## Current Registry State

- Registered metric ids: `102`
- Registry uniqueness: confirmed (`unique_ids = TRUE`)
- Recommended shortlist size: `10`

These counts reflect the current audited `dev` branch state at the time this
summary was created.

## Validation Status

The current hardening pass validated:

- package load via `devtools::load_all('.')`
- vignette builds for:
  - `getting-started`
  - `metric-reference`
  - `calibration-guide`
  - `uncertainty-eval`
- full `devtools::test()`
- `devtools::check(document = FALSE, error_on = 'warning')`
- release-facing placeholder audit across:
  - `DECISIONS.md`
  - `NEWS.md`
  - `inst/REFERENCES.md`
  - current vignettes

The placeholder audit was clean at the time of the Stage 6 pass.

## API Stability Declaration

The current package state is still pre-1.0, but the following surface is being
treated as stable for the present milestone:

- the default deterministic `gof()` / `gof(extended = FALSE)` compat-10
  surface
- the current `ggof()` and `preproc()` orchestration contracts
- the current public compatibility wrappers already shipped by the package

The broader `gof(extended = TRUE)` surface is available and validated, but it
remains conditional on metric-specific applicability rules. It should be
treated as a broader deterministic discovery path rather than as an
unconditional default contract.

Wrapper-only or special-interface metrics remain outside ordinary deterministic
auto-selection. This includes the current probabilistic wrappers `crps`,
`picp`, `mwpi`, and `skill_score`, along with metrics that require special
seasonal, event, interval, or ensemble structure.

`pareto_skill` remains deferred and unimplemented because the current
literature audit did not establish a strong enough direct metric basis for a
safe addition.

## Real-Dataset Validation Status

The repository now includes a compact real-data validation layer under
`inst/validation/` based on a fixed USGS NWIS subset of daily mean discharge
observations.

Current scope:

- three fixed NWIS gauges
- parameter `00060` daily mean discharge (`statCd = 00003`)
- a fixed date window from `2016-01-01` to `2020-12-31`
- derived manifest, provenance, observed-summary, and metric-summary artifacts
- deterministic benchmark comparison scenarios derived from the observed NWIS
  series

This is a truthful real-data validation layer because the observed series are
retrieved from a real external hydrologic data source and the derived metric
tables are reproducible from those observations.

It is still narrower than a full external model-validation archive:

- no packaged raw NWIS dump is shipped
- no external model simulation archive is bundled
- the metric tables are benchmark scenarios derived from observed data, not
  third-party model outputs

## Additional Release-Facing Evidence

Related evidence already present in the repository includes:

- `inst/benchmarks/benchmark_summary.md`
- `notes/release-readiness/`
- `notes/final-cran-evidence/`

These materials remain useful supporting evidence, but they are not being
recast here as packaged real-dataset validation.
