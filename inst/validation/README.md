# Validation Artifacts

This directory contains concise, release-facing validation summaries for the
current pre-1.0 `hydroMetrics` milestone. It is intentionally narrower than
the historical working evidence under `notes/` and does not duplicate every
intermediate audit artifact generated during development.

## Included Artifacts

- `phase3-pre1.0-validation-summary.md`: current registry, vignette, test, and
  package-check status for the Phase 3 / pre-1.0 stabilization line.
- `usgs_nwis_manifest.csv`: fixed NWIS station manifest for the Stage 6
  real-data validation subset.
- `usgs_nwis_provenance.md`: retrieval, provenance, and benchmark-scenario
  documentation for the NWIS subset.
- `usgs_nwis_observed_subset_summary.csv`: compact observed-series summary
  statistics for the selected NWIS stations and date window.
- `usgs_nwis_metric_validation_summary.csv`: representative metric outputs for
  deterministic benchmark scenarios derived from the observed NWIS series.

## Scope

The validation material in this directory is limited to what can be stated
truthfully from the shipped repository contents:

- registry integrity and current metric-surface state
- recommended-shortlist presence
- vignette build status
- test and package-check status
- release-document placeholder and citation cleanliness
- current API-stability scope for the pre-1.0 milestone

## Real-Dataset Validation

This directory now includes a compact real-data validation layer based on a
fixed subset of USGS NWIS daily streamflow observations.

The packaged artifacts remain intentionally lightweight:

- no large raw NWIS data dumps are committed
- the real-data layer uses a fixed retrieval design and derived summaries
- metric tables are computed from clearly labeled benchmark simulation
  scenarios derived from the observed NWIS series

These artifacts are useful as reproducible validation anchors, but they should
not be interpreted as external real-model benchmark outputs.

## Related Evidence

Broader historical or workflow-specific validation evidence remains in:

- `inst/benchmarks/`
- `notes/release-readiness/`
- `notes/final-cran-evidence/`
- other `notes/` subdirectories created during earlier stabilization work

The NWIS validation artifacts can be regenerated from the repository root with:

```r
source("tools/generate_usgs_nwis_validation_artifacts.R")
```
