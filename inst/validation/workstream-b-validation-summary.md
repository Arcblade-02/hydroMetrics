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
- `rmse`
- `mse`
- `ve`
- `kge` against `hydroGOF::KGE(method = "2009")`
- `me`
- `d`
- `md`
- `ubrmse`
- `rspearman`
- `cp`
- `rsr`

Intentionally divergent, with explicit comparison tests and formula/policy
notes recorded in `workstream-b-validation-inventory.md`:

- `rnse` / `rNSeff`
- `wsnse` / `wsNSeff`
- `pbias`
- `nrmse`
- `r2`
- `apfb` / `APFB`
- `hfb` / `HFB`

These divergences are treated as evidence-backed classification outcomes, not
as unresolved compatibility failures.

## Probabilistic and Distributional Metrics

Currently validated through literature/example-based or base-statistics checks:

- `crps`
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

## Current Evidence Reading

- Workstream B now has explicit committed evidence for a small but meaningful
  hydroGOF-overlap subset, rather than generic compatibility language.
- The package now distinguishes true equivalence from intentional divergence
  on the tested hydroGOF-overlap metrics.
- The next deterministic overlap tranche tightened that distinction further:
  `rmse`, `mse`, `ve`, and `kge` now have explicit equivalence evidence, while
  `nrmse` and `r2` now have explicit divergence classification rather than
  remaining in the unresolved backlog.
- The current moderate-complexity tranche adds explicit equivalence evidence
  for `me`, `d`, `md`, `ubrmse`, `rspearman`, and `cp`; `rsd` remains outside
  this tranche because `hydroGOF` does not expose a direct like-for-like
  `RSD` / `rsd` comparator.
- The probabilistic/distributional surface now has a clearer validation map:
  the currently audited metrics are supported by direct literature/example-
  based checks, and `crps` now also has an exercised `scoringRules`
  comparison path on a small deterministic reference set.

For `crps`, the current recorded tolerance rule is absolute agreement within
`sqrt(.Machine$double.eps)` against
`scoringRules::crps_sample(..., method = "edf")`. The exercised baseline run
observed a maximum absolute difference of `1.39e-17` across the committed
reference cases.

## Backlog

The main remaining Workstream B backlog items are:

- broader hydroGOF-overlap reconciliation for the additional overlap metrics
  listed in `workstream-b-validation-inventory.md`
- any further external-package cross-checks judged worthwhile for the broader
  probabilistic/distributional surface

This summary is not a benchmarking report and does not claim that Workstream B
is complete. It remains the validation evidence baseline before any broader
benchmark expansion or optimization work.
