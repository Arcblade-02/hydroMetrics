# Workstream B Validation Inventory

This file records the initial empirical-validation baseline for Workstream B.
It is intentionally narrow: the goal is to state what validation evidence is
already present in the repository, what now has an explicit baseline check,
and where further validation work is still needed.

## Priority HydroGOF-Overlap Metrics

| Metric | Category | Intended validation source | Current evidence | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `nse` / `NSeff` | compatibility overlap | `hydroGOF::NSE` | explicit comparison test in `test-compat-hydrogof.R` | validated | Baseline scalar compatibility check present |
| `mnse` / `mNSeff` | compatibility overlap | `hydroGOF::mNSE` | explicit comparison test in `test-compat-hydrogof.R` | validated | Exported compatibility wrapper covered |
| `rnse` / `rNSeff` | compatibility overlap | `hydroGOF::rNSE` | no committed equivalence test; local spot check showed a numeric mismatch on a simple vector | not yet validated | Needs explicit reconciliation before any equivalence claim |
| `wsnse` / `wsNSeff` | compatibility overlap | `hydroGOF::wsNSE` | no committed equivalence test; local spot check showed numeric mismatch on a simple vector | not yet validated | Needs explicit reconciliation before any equivalence claim |
| `mae` | compatibility overlap | `hydroGOF::mae` | explicit comparison test in `test-compat-hydrogof.R` | validated | Exported wrapper covered |
| `pbias` | compatibility overlap | `hydroGOF::pbias` | no committed equivalence test; local spot check showed a small but real numeric mismatch on a simple vector | not yet validated | Needs explicit reconciliation before any equivalence claim |
| `rsr` | compatibility overlap | `hydroGOF::rsr` | explicit comparison test in `test-compat-hydrogof.R` | validated | Exported wrapper covered |
| `apfb` / `APFB` | compatibility overlap | `hydroGOF::APFB` | no committed equivalence test; local indexed spot check showed a material numeric mismatch | not yet validated | Needs explicit reconciliation before any equivalence claim |
| `hfb` / `HFB` | compatibility overlap | `hydroGOF::HFB` | no committed equivalence test; local indexed spot check showed a material numeric mismatch | not yet validated | Needs explicit reconciliation before any equivalence claim |

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

`rnse`, `pbias`, `apfb`, and `hfb` are also still open validation items
despite their hydroGOF overlap, because local spot checks showed behavior
that does not yet support an equivalence claim.

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
- The repository does not yet have a broader explicit comparison matrix for
  the full hydroGOF-overlap surface.
- Probabilistic metrics have formula and contract tests, but external
  reference-package validation remains largely absent and should be treated as
  the next major empirical-validation gap in Workstream B.
