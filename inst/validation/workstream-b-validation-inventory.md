# Workstream B Validation Inventory

This file records the initial empirical-validation baseline for Workstream B.
It is intentionally narrow: the goal is to state what validation evidence is
already present in the repository, what now has an explicit baseline check,
and where further validation work is still needed.

For the hydroGOF-overlap section below, the status column records the current
reconciliation outcome: `equivalent`, `intentionally divergent`, or
`unresolved`.

## Priority HydroGOF-Overlap Metrics

| Metric | Category | Intended validation source | Current evidence | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `nse` / `NSeff` | compatibility overlap | `hydroGOF::NSE` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Baseline scalar compatibility check present |
| `mnse` / `mNSeff` | compatibility overlap | `hydroGOF::mNSE` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Exported compatibility wrapper covered |
| `rnse` / `rNSeff` | compatibility overlap | `hydroGOF::rNSE` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | `hydroMetrics` uses observation-scaled denominator terms `((obs - mean(obs)) / obs)^2`; `hydroGOF` uses `((obs - mean(obs)) / mean(obs))^2` and warning-based zero handling |
| `wsnse` / `wsNSeff` | compatibility overlap | `hydroGOF::wsNSE` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | `hydroMetrics` fixes weights at `obs^2`; `hydroGOF` uses quantile-based weights with `lambda`, `j`, and threshold parameters |
| `mae` | compatibility overlap | `hydroGOF::mae` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Exported wrapper covered |
| `pbias` | compatibility overlap | `hydroGOF::pbias` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | Core formula aligns before presentation, but `hydroGOF` rounds to `dec = 1` by default while `hydroMetrics` returns the unrounded scalar |
| `rsr` | compatibility overlap | `hydroGOF::rsr` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Exported wrapper covered |
| `apfb` / `APFB` | compatibility overlap | `hydroGOF::APFB` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | `hydroMetrics` returns signed mean percent bias over annual peaks; `hydroGOF` returns mean absolute relative annual-peak error on `zoo` inputs |
| `hfb` / `HFB` | compatibility overlap | `hydroGOF::HFB` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | `hydroMetrics` computes percent bias over observations above a global threshold; `hydroGOF` computes a per-year median absolute relative high-flow bias on `zoo` inputs |

## Additional HydroGOF-Overlap Metrics Still Needing Explicit Comparison Evidence

These metrics overlap materially with `hydroGOF`, but the repository does not
yet carry explicit reference-package comparison tests for them:

- `cp`
- `d`
- `dr`
- `kge`
- `kgekm`
- `kgelf`
- `kgenp`
- `md`
- `me`
- `mse`
- `nrmse`
- `pbiasfdc`
- `pfactor`
- `r2`
- `rd`
- `rfactor`
- `rmse`
- `rsd`
- `rspearman`
- `skge`
- `ubrmse`
- `ve`
- `wnse`

Current status for this broader overlap set: not yet validated through
explicit committed `hydroGOF` comparison tests in the package repository.

## Probabilistic Metrics

| Metric | Category | Intended validation source | Current evidence | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `crps` | probabilistic | reference package such as `scoringRules`, plus literature-backed formula checks | internal formula/contract tests in `test-metrics-layer-a.R`; literature references in `inst/REFERENCES.md`; no reference-package comparison artifact in repo | partially validated | No external scoring reference package is currently used in committed validation |
| `picp` | probabilistic | literature-backed manual interval-coverage calculation | internal formula/contract tests in `test-metrics-layer-a.R`; literature references in `inst/REFERENCES.md` | partially validated | Straightforward deterministic formula, but no separate external validation artifact yet |
| `mwpi` | probabilistic | literature-backed manual interval-width calculation | internal formula/contract tests in `test-metrics-layer-a.R`; literature references in `inst/REFERENCES.md` | partially validated | No reference-package comparison artifact yet |
| `skill_score` | probabilistic / verification | literature-backed manual normalization and, where feasible, verification-package cross-check | internal formula/contract tests in `test-metrics-layer-a.R`; literature references in `inst/REFERENCES.md` | partially validated | No external verification-package comparison artifact yet |

## Current Baseline Reading

- The repository now has a truthful initial validation baseline for a narrow
  set of exported hydroGOF-overlap wrappers whose behavior matches committed
  `hydroGOF` comparison examples.
- The previously unresolved overlap metrics targeted in this pass now have
  explicit reconciliation outcomes: `rnse`, `wsnse`, `pbias`, `apfb`, and
  `hfb` are intentionally divergent rather than unresolved.
- The repository does not yet have a broader explicit comparison matrix for
  the full hydroGOF-overlap surface.
- Probabilistic metrics have formula and contract tests, but external
  reference-package validation remains largely absent and should be treated as
  the next major empirical-validation gap in Workstream B.
