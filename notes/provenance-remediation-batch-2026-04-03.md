# Provenance Remediation Batch 2026-04-03

This note records the bounded provenance-first remediation batch for the nine
metrics named in the completed provenance audit:

- `br2`
- `pbias`
- `mnse`
- `nrmse`
- `pfactor`
- `rfactor`
- `hfb`
- `low_flow_bias`
- `mutual_information_score`

## Changed Surfaces

- Registry/reference metadata:
  `R/core_metrics.R`, `R/metrics_layer_a.R`, `R/metrics_layer_c.R`,
  `inst/REFERENCES.md`
- Discovery/provenance policy surfaces:
  `R/metric_search.R`, `README.md`, `DECISIONS.md`,
  `COMPATIBILITY_TRACKER.md`, `CRAN_READINESS.md`
- Wrapper/help wording:
  `R/pbias.R`, `R/HFB.R`, `R/wrappers_layer_a.R`,
  `R/wrappers_layer_c.R`, affected `man/*.Rd`
- Package-facing guidance and regression tests:
  `vignettes/calibration-guide.Rmd`,
  `vignettes/metric-reference.Rmd`,
  `tests/testthat/test-metric_search.R`,
  `tests/testthat/test-reference-metadata.R`

## What Was Fixed

- Registry metadata, references, and package-facing wording were tightened so
  the package no longer overstates literature equivalence for the targeted
  metrics.
- `pbias` documentation now states the retained sign convention explicitly:
  `100 * sum(sim - obs) / sum(obs)`, with positive values indicating
  overestimation.
- `nrmse` documentation now states the exact retained normalization:
  `RMSE / mean(obs)`, and it no longer implies a universal NRMSE definition.
- `mnse` citation support was strengthened toward the Legates & McCabe (1999)
  modified-efficiency context rather than implying package originality.
- `pfactor`, `rfactor`, `hfb`, and `low_flow_bias` are now labeled explicitly
  as package-defined deterministic compatibility / subset metrics rather than
  literature-exact formulas.
- Discovery-facing documentation now treats `mutual_information` as the
  canonical discovery id and no longer surfaces
  `mutual_information_score` as an independent canonical metric in
  `metric_search()`.

## What Was Relabeled

- `br2` is now described as the project-selected `bR2` interpretation retained
  in `D-029`, not as a fully reverified literature-exact `bR2` formula.
- `pbias` is now described with its exact retained sign convention and without
  silently borrowing opposite-sign threshold language.
- `pfactor` and `rfactor` are now described as package-defined deterministic
  compatibility metrics, not as SWAT/95PPU uncertainty metrics.
- `hfb` and `low_flow_bias` are now described as package-defined threshold /
  subset percent-bias diagnostics.
- `mutual_information_score` is now described as a retained compatibility
  duplicate of canonical `mutual_information`, not as an independent
  discovery-canonical metric.

## Explicitly Deferred

- Any runtime or formula change to `br2`.
- Any runtime or formula change to `pbias`.
- Any attempt to reinterpret `pfactor` / `rfactor` as uncertainty-band metrics.
- Any attempt to promote `hfb` or `low_flow_bias` to literature-exact
  diagnostics without stronger formula matching.
- Any alias-lifecycle escalation or export removal for
  `mutual_information_score`.

## Final Classification

### Literature-backed and acceptable

- `mnse`
- `nrmse`
- `pbias`

### Acceptable only if explicitly labeled project-defined

- `pfactor`
- `rfactor`
- `hfb`
- `low_flow_bias`

### Still deferred from CRAN-facing claims

- `mutual_information_score`

### Requires future runtime/formula decision

- `br2`

## Validation Summary

- `devtools::build_vignettes()`: passed
- `devtools::test()`: passed with 1300 PASS, 0 FAIL, 0 WARN, 1 SKIP
- `devtools::check(document = FALSE, error_on = "warning")`: passed with
  0 errors, 0 warnings, 0 notes

## Batch Boundary

This batch was provenance-first and low-risk. It did not:

- change any targeted formula
- remove any export
- escalate alias lifecycle
- reopen broader wrapper-policy or stabilization work
