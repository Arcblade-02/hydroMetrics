# Workstream B Validation Evidence Summary

This summary consolidates the current scientific-validation evidence added
during Workstream B. It is intentionally concise and review-oriented: the goal
is to state what has explicit evidence, what is intentionally divergent from
comparison packages, what remains only partially validated, and what still
belongs to the backlog before broader benchmarking claims are made.

## HydroGOF Overlap

The current committed hydroGOF-overlap evidence falls into two categories.

Equivalent on the committed comparison cases:

- `nse` / `NSeff`
- `mnse` / `mNSeff`
- `mae`
- `rsr`

Intentionally divergent, with explicit comparison tests and formula/policy
notes recorded in `workstream-b-validation-inventory.md`:

- `rnse` / `rNSeff`
- `wsnse` / `wsNSeff`
- `pbias`
- `apfb` / `APFB`
- `hfb` / `HFB`

These divergences are treated as evidence-backed classification outcomes, not
as unresolved compatibility failures.

## Probabilistic and Distributional Metrics

Currently validated through literature/example-based or base-statistics checks:

- `picp`
- `mwpi`
- `skill_score`
- `quantile_loss`
- `cdf_rmse`
- `quantile_deviation`
- `quantile_kge`
- `quantile_shift_index`
- `distribution_overlap`
- `ks_statistic`
- `anderson_darling_stat`
- `wasserstein_distance`

Currently only partially validated:

- `crps`

`crps` has:

- an explicit empirical-ensemble formula test
- a degenerate-ensemble identity check
- a committed conditional external comparison path against
  `scoringRules::crps_sample(..., method = "edf")`

It remains only partially validated in the shipped evidence summary because
the external-package comparison is conditional on `scoringRules` being present
in the test environment.

## Current Evidence Reading

- Workstream B now has explicit committed evidence for a small but meaningful
  hydroGOF-overlap subset, rather than generic compatibility language.
- The package now distinguishes true equivalence from intentional divergence
  on the tested hydroGOF-overlap metrics.
- The probabilistic/distributional surface now has a clearer validation map:
  most currently audited metrics are supported by direct literature/example-
  based checks, while `crps` is the main remaining conditional external-
  reference item.

## Backlog

The main remaining Workstream B backlog items are:

- broader hydroGOF-overlap reconciliation for the additional overlap metrics
  listed in `workstream-b-validation-inventory.md`
- execution of the committed conditional `scoringRules` comparison path for
  `crps` in an environment where that package is available
- any further external-package cross-checks judged worthwhile for the broader
  probabilistic/distributional surface

This summary is not a benchmarking report and does not claim that Workstream B
is complete. It is the current evidence baseline immediately before the
benchmarking phase.
