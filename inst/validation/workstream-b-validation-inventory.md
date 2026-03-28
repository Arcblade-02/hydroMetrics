# Workstream B Validation Inventory

This file records the initial empirical-validation baseline for Workstream B.
It is intentionally narrow: the goal is to state what validation evidence is
already present in the repository, what now has an explicit baseline check,
and where further validation work is still needed.

For the hydroGOF-overlap section below, the status column records the current
reconciliation outcome: `equivalent`, `intentionally divergent`,
`not directly comparable`, or `unresolved`.

## Priority HydroGOF-Overlap Metrics

| Metric | Category | Intended validation source | Current evidence | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| `nse` / `NSeff` | compatibility overlap | `hydroGOF::NSE` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Baseline scalar compatibility check present |
| `mnse` / `mNSeff` | compatibility overlap | `hydroGOF::mNSE` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Exported compatibility wrapper covered |
| `rnse` / `rNSeff` | compatibility overlap | `hydroGOF::rNSE` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | `hydroMetrics` uses observation-scaled denominator terms `((obs - mean(obs)) / obs)^2`; `hydroGOF` uses `((obs - mean(obs)) / mean(obs))^2` and warning-based zero handling |
| `wsnse` / `wsNSeff` | compatibility overlap | `hydroGOF::wsNSE` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | `hydroMetrics` fixes weights at `obs^2`; `hydroGOF` uses quantile-based weights with `lambda`, `j`, and threshold parameters |
| `mae` | compatibility overlap | `hydroGOF::mae` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Exported wrapper covered |
| `rmse` | compatibility overlap | `hydroGOF::rmse` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "rmse")` path matches hydroGOF on committed deterministic cases |
| `mse` | compatibility overlap | `hydroGOF::mse` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "mse")` path matches hydroGOF on committed deterministic cases |
| `ve` | compatibility overlap | `hydroGOF::VE` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "ve")` path matches hydroGOF on committed deterministic cases |
| `kge` | compatibility overlap | `hydroGOF::KGE(method = "2009")` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Current package KGE matches the comparable hydroGOF 2009 variant on committed deterministic cases |
| `me` | compatibility overlap | `hydroGOF::me` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "me")` path matches hydroGOF on committed deterministic cases |
| `d` | compatibility overlap | `hydroGOF::d` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "d")` path matches hydroGOF on committed deterministic cases |
| `md` | compatibility overlap | `hydroGOF::md` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "md")` path matches hydroGOF on committed deterministic cases |
| `ubrmse` | compatibility overlap | `hydroGOF::ubRMSE` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "ubrmse")` path matches hydroGOF on committed deterministic cases |
| `rspearman` | compatibility overlap | `hydroGOF::rSpearman` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Public `gof(methods = "rspearman")` path matches hydroGOF on committed deterministic cases |
| `cp` | compatibility overlap | `hydroGOF::cp` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Added in this tranche as a moderate replacement for `rsd`, because `hydroGOF` does not expose a direct `RSD` / `rsd` comparator |
| `wnse` | compatibility overlap | `hydroGOF::wNSE` | explicit comparison test in `test-compat-hydrogof.R`, plus formula inspection | equivalent | Current package weighted NSE matches hydroGOF on intended comparable positive-observation cases |
| `kgekm` | compatibility overlap | `hydroGOF::KGEkm` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` uses `sd`-based coefficient-of-variation ratios inside a fixed 2012-style KGEkm distance; `hydroGOF::KGEkm` uses its own variability estimator (`K2`-based `sigma`) and supports multiple method variants |
| `kgelf` | compatibility overlap | `hydroGOF::KGElf` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` applies KGE to `log1p`-transformed nonnegative flows, while `hydroGOF::KGElf` averages standard KGE with a low-flow reciprocal-transform KGE |
| `kgenp` | compatibility overlap | `hydroGOF::KGEnp` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` uses Spearman correlation, IQR ratio, and median ratio; `hydroGOF::KGEnp` uses Spearman correlation, an FDC-shape alpha term, and mean ratio |
| `pbias` | compatibility overlap | `hydroGOF::pbias` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | Core formula aligns before presentation, but `hydroGOF` rounds to `dec = 1` by default while `hydroMetrics` returns the unrounded scalar |
| `nrmse` | compatibility overlap | `hydroGOF::nrmse` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` uses RMSE / mean(obs); `hydroGOF::nrmse` defaults to rounded `100 * RMSE / sd(obs)` with `norm = "sd"` |
| `r2` | compatibility overlap | `hydroGOF::R2` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` uses Pearson correlation squared; `hydroGOF::R2` computes `1 - SSres / SStot` |
| `rsr` | compatibility overlap | `hydroGOF::rsr` | explicit comparison test in `test-compat-hydrogof.R` | equivalent | Exported wrapper covered |
| `dr` | compatibility overlap | `hydroGOF::dr` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` uses an observation-normalized relative absolute agreement formula; `hydroGOF::dr` uses the Willmott et al. (2012) refined index with piecewise `1 - A/B` or `1 - B/A` scaling |
| `rd` | compatibility overlap | `hydroGOF::rd` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` uses obs-normalized relative terms in both numerator and denominator; `hydroGOF::rd` normalizes the denominator by `mean(obs)` and warns rather than failing on zero observations |
| `skge` | compatibility overlap | `hydroGOF::sKGE` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` computes mean monthly-group KGE when monthly context is available and otherwise falls back to KGE; `hydroGOF::sKGE` requires `zoo` inputs and averages per-year KGE values |
| `pbiasfdc` | compatibility overlap | `hydroGOF::pbiasfdc` | explicit divergence test in `test-compat-hydrogof.R`, plus function-definition inspection | intentionally divergent | `hydroMetrics` computes percent bias over a fixed exceedance-quantile grid, while `hydroGOF::pbiasfdc` compares the log-slope between two selected FDC threshold points |
| `pfactor` | compatibility overlap | `hydroGOF::pfactor` | interface/signature inspection in `test-compat-hydrogof.R` | not directly comparable | `hydroMetrics` defines `pfactor(sim, obs, tol)` as a tolerance-band hit proportion on paired series; `hydroGOF::pfactor(x, lband, uband)` is an uncertainty-band coverage diagnostic with different required inputs |
| `rfactor` | compatibility overlap | `hydroGOF::rfactor` | interface/signature inspection in `test-compat-hydrogof.R` | not directly comparable | `hydroMetrics` defines `rfactor(sim, obs)` as mean absolute error normalized by mean absolute observations; `hydroGOF::rfactor(x, lband, uband)` is an interval-width diagnostic normalized by `sd(x)` |
| `rsd` | compatibility overlap | no direct `hydroGOF` export | namespace inspection in `test-compat-hydrogof.R` | not directly comparable | `hydroMetrics::rsd` is a standard-deviation ratio metric, but `hydroGOF` does not expose a direct `RSD` / `rsd` comparator on the current public surface |
| `hfb` / `HFB` | compatibility overlap | `hydroGOF::HFB` | explicit divergence test in `test-compat-hydrogof.R`, plus formula inspection | intentionally divergent | `hydroMetrics` computes percent bias over observations above a global threshold; `hydroGOF` computes a per-year median absolute relative high-flow bias on `zoo` inputs |

## Additional HydroGOF-Overlap Metrics Still Needing Explicit Comparison Evidence

These metrics overlap materially with `hydroGOF`, but the repository does not
yet carry explicit reference-package comparison tests for them:

- none

Current status for this broader overlap set: the current hydroGOF-overlap
backlog is cleared at the classification level, even where the truthful
outcome is intentional divergence or non-comparability rather than equivalence.

## Probabilistic and Distributional Metrics

| Metric | Category | Intended validation source type | Current evidence | Status | Notes |
| --- | --- | --- | --- | --- | --- |
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
  explicit reconciliation outcomes: `rnse`, `wsnse`, `pbias`, and `hfb` are
  intentionally divergent rather than unresolved.
- The next deterministic overlap tranche now has explicit outcomes as well:
  `rmse`, `mse`, `ve`, and `kge` are evidenced as equivalent on the committed
  comparison cases, while `nrmse` and `r2` are now classified as intentionally
  divergent.
- The current moderate-complexity overlap tranche adds explicit equivalence
  evidence for `me`, `d`, `md`, `ubrmse`, `rspearman`, and `cp`; `rsd`
  remains in the backlog because `hydroGOF` does not expose a direct
  like-for-like `RSD` / `rsd` comparator.
- The small direct-comparator tranche now records `wnse` as equivalent on
  intended comparable cases, while `dr` and `rd` are explicitly classified as
  intentionally divergent based on both comparison tests and formula
  inspection.
- The specialized KGE-family / seasonal tranche now records `kgekm`,
  `kgelf`, `kgenp`, and `skge` as intentionally divergent rather than
  unresolved, based on direct comparison tests plus definition-level
  inspection of how each package constructs the corresponding score.
- The final backlog pass now records `pbiasfdc` as intentionally divergent and
  `pfactor`, `rfactor`, and `rsd` as not directly comparable on the current
  public surfaces, closing the remaining hydroGOF-overlap classification
  backlog.
- Probabilistic and distributional metrics now have an explicit validation map
  that distinguishes literature/example-based evidence from future
  external-package comparison paths.
