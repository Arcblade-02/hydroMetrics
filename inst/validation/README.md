# Validation Artifacts

This directory contains concise, release-facing validation summaries for the
current pre-1.0 `hydroMetrics` milestone. It is intentionally narrower than
the historical working evidence under `notes/` and does not duplicate every
intermediate audit artifact generated during development.

## Included Artifacts

- `phase3-pre1.0-validation-summary.md`: current registry, vignette, test, and
  package-check status for the Phase 3 / pre-1.0 stabilization line.

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

No genuine real-dataset validation outputs are currently bundled in the
repository under `data/`, `inst/extdata/`, or `inst/validation/`.

Accordingly, this directory does not claim packaged real-dataset validation
results. If such validation is performed later from an external or newly added
dataset, the resulting artifacts should be added here only if they are fully
reproducible from repository contents and can be documented without ambiguity.

## Related Evidence

Broader historical or workflow-specific validation evidence remains in:

- `inst/benchmarks/`
- `notes/release-readiness/`
- `notes/final-cran-evidence/`
- other `notes/` subdirectories created during earlier stabilization work
