# Phase 3 / Pre-1.0 Validation Summary

This summary records the current repository-level validation state for the
Phase 3 / pre-1.0 stabilization line.

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

No genuine packaged real-dataset validation outputs are currently present in
the repository. During the Stage 6 audit:

- `data/` was not present
- `inst/extdata/` was not present
- `inst/validation/` did not previously contain real-dataset outputs

This means the current repository is validated at the package, registry,
documentation, and test/check level, but it does not yet ship reproducible
real-dataset validation outputs.

## Additional Release-Facing Evidence

Related evidence already present in the repository includes:

- `inst/benchmarks/benchmark_summary.md`
- `notes/release-readiness/`
- `notes/final-cran-evidence/`

These materials remain useful supporting evidence, but they are not being
recast here as packaged real-dataset validation.
