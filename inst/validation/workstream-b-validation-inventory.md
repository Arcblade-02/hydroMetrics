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

## Probabilistic and Distributional Metrics

| Metric | Category | Intended validation source type | Current evidence | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `crps` | probabilistic / ensemble scoring | external reference package plus literature/example-based validation | independent empirical-CRPS formula test in `test-metrics-layer-a.R`; conditional `scoringRules::crps_sample(..., method = "edf")` comparison in `test-probabilistic-validation.R`; literature references in `inst/REFERENCES.md` | partially validated | External comparison path is now committed conditionally through `Suggests`, but local validation remains conditional on `scoringRules` availability |
| `picp` | probabilistic / interval coverage | literature/example-based validation | explicit inclusive-coverage formula test in `test-metrics-layer-a.R`; literature references in `inst/REFERENCES.md` | validated | Straightforward deterministic coverage proportion with direct independent test |
| `mwpi` | probabilistic / interval width | literature/example-based validation | explicit interval-width formula test in `test-metrics-layer-a.R`; literature references in `inst/REFERENCES.md` | validated | Straightforward deterministic width diagnostic with direct independent test |
| `skill_score` | probabilistic / verification | literature/example-based validation | explicit normalization-formula test in `test-metrics-layer-a.R`; literature references in `inst/REFERENCES.md` | validated | Current package variant is directly tested against the lower-is-better skill-score normalization |
| `quantile_loss` | probabilistic / quantile scoring | literature/example-based validation | explicit pinball-loss formula test in `test-metrics-layer-a.R`; additional identity check in `test-probabilistic-validation.R`; literature references in `inst/REFERENCES.md` | validated | Grounded in Koenker & Bassett (1978) |
| `cdf_rmse` | distributional / empirical CDF | literature/example-based validation | explicit pooled-support ECDF RMSE test in `test-metrics-layer-b.R`; reference note in `inst/REFERENCES.md` | validated | Strongest practical path is independent base-`stats` ECDF calculation rather than external package comparison |
| `quantile_deviation` | distributional / quantile summary | literature/example-based validation | explicit type-7 fixed-grid quantile RMSE test in `test-metrics-layer-b.R`; literature references in `inst/REFERENCES.md` | validated | Grounded in Hyndman & Fan (1996) quantile conventions |
| `quantile_kge` | probabilistic / quantile summary efficiency | literature/example-based validation | explicit KGE-on-fixed-quantile-grid test in `test-metrics-layer-b.R`; literature references in `inst/REFERENCES.md` | validated | Package-defined KGE variant, but tested against an independent quantile-summary reconstruction |
| `quantile_shift_index` | distributional / quantile shift | literature/example-based validation | explicit fixed-grid type-7 quantile-shift scaling test in `test-metrics-layer-c.R`; literature references in `inst/REFERENCES.md` | validated | Package-defined diagnostic grounded in Hyndman & Fan (1996) fixed-grid quantiles and IQR scaling |
| `distribution_overlap` | distributional / histogram overlap | literature/example-based validation | explicit pooled-support overlap-coefficient test in `test-metrics-layer-c.R`; literature references in `inst/REFERENCES.md` | validated | Package-defined overlap diagnostic grounded in deterministic Sturges histogram conventions |
| `ks_statistic` | distributional / EDF distance | literature/example-based validation | explicit ECDF-gap test plus `stats::ks.test()` comparison in `test-metrics-layer-b.R` | validated | External base-R comparison already present |
| `anderson_darling_stat` | distributional / EDF distance | literature/example-based validation | explicit pooled-grid AD-style distance reconstruction in `test-metrics-layer-b.R`; literature references in `inst/REFERENCES.md` | validated | Current package metric is the documented EDF-distance form, not a p-value wrapper |
| `wasserstein_distance` | distributional / transport distance | literature/example-based validation | explicit equal-weight quantile-coupling test in `test-metrics-layer-b.R` | validated | Current implementation is directly validated on the one-dimensional equal-weight sample coupling |

## Current Baseline Reading

- The repository now has a truthful initial validation baseline for a narrow
  set of exported hydroGOF-overlap wrappers whose behavior matches committed
  `hydroGOF` comparison examples.
- The previously unresolved overlap metrics targeted in this pass now have
  explicit reconciliation outcomes: `rnse`, `wsnse`, `pbias`, `apfb`, and
  `hfb` are intentionally divergent rather than unresolved.
- The repository does not yet have a broader explicit comparison matrix for
  the full hydroGOF-overlap surface.
- Probabilistic and distributional metrics now have an explicit validation map
  that distinguishes literature/example-based evidence from future
  external-package comparison paths.
- `crps` now has a committed conditional external reference-package path via
  `scoringRules`, but local evidence remains conditional until that package is
  present in the test environment.
- No comparable external-package baseline is yet wired for the broader
  probabilistic surface.
