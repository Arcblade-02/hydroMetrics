# hydroGOF Compatibility Tracker

Generated on: 2026-03-04

This tracker is retained as a Phase 2 compatibility ledger for the legacy
hydroGOF-style wrapper surface. It is not the full post-Phase-3 metric
catalog; use the metric-reference and calibration-guide vignettes for the
broader current package surface.

Note: this file tracks the retained hydroGOF-style compatibility surface only.
The entries `plot2`, `plotbands`, and `plotbandsonly` remain unimplemented as
compatibility functions. That compatibility status does not mean
`hydroMetrics` lacks plotting altogether: the package now provides lightweight
plotting helpers such as `plot_hydrograph()` and `plot_fdc()` outside this
legacy compatibility ledger.

Canonical discovery ids for the current package are the lowercase
registry-backed metric ids returned by `metric_search()` and `metric_preset()`.
Exported compatibility wrappers, deprecated forwarding wrappers, and
orchestration-only aliases may route to those canonical ids, but they are not
independent discovery-canonical metric ids.

Reference wording in the implemented metrics table distinguishes literature
backing from exact package-defined compatibility formulas. Names such as
`pfactor`, `rfactor`, `hfb`, `low_flow_bias`, and retained
`mutual_information_score()` should not be read as claims of literature-exact
equivalence unless the row says so explicitly.

## Current surface interpretation for compatibility review

- exported compatibility wrappers retained at the current baseline:
  `HFB()`, `NSeff()`, `mNSeff()`, `rNSeff()`, `wsNSeff()`, and
  `mutual_information_score()`
- `mutual_information_score()` remains callable for continuity but is
  intentionally omitted from the canonical implemented-metrics table because
  canonical discovery and canonical metric identity belong to
  `mutual_information`
- exported deprecated forwarding wrappers retained temporarily:
  `tail_dependence_score()` and `extended_valindex()`
- uppercase hydroGOF-style names such as `NSE`, `KGE`, `RMSE`, `R2`,
  `NRMSE`, and `PBIAS` are accepted through `gof()` / `ggof()` orchestration
  handling; they are not exported standalone functions
- deprecated orchestration aliases such as `rPearson` / `rpearson` resolve to
  canonical `r` and are not listed as separate canonical metric ids below

## Phase 2 exported wrappers and core entry points tracked here
- [x] alpha
- [x] beta
- [x] ggof
- [x] gof
- [x] HFB
- [x] mae
- [x] mNSeff
- [x] NSeff
- [x] pbias
- [x] preproc
- [x] rNSeff
- [x] rsr
- [x] valindex
- [x] wsNSeff

Uppercase hydroGOF names such as `NSE`, `KGE`, `RMSE`, `R2`, `NRMSE`, and
`PBIAS` are accepted metric labels through `gof()` / `ggof()` compatibility
handling; they are not exported standalone functions.

## Implemented metric ids / accepted `gof()` labels (not standalone exports)
- [x] br2
- [x] cp
- [x] d
- [x] KGE
- [x] KGEkm
- [x] KGElf
- [x] KGEnp
- [x] md
- [x] me
- [x] mNSE
- [x] mse
- [x] nrmse
- [x] NSE
- [x] pfactor
- [x] R2
- [x] r
- [x] rd
- [x] rfactor
- [x] rmse
- [x] rNSE
- [x] rSD
- [x] rSpearman
- [x] sKGE
- [x] ssq
- [x] ubRMSE
- [x] VE
- [x] wNSE
- [x] wsNSE

Deprecated compatibility aliases may still be accepted during orchestration or
engine-level resolution, but they are not listed as separate canonical metric
ids in the implemented metrics table below. In particular, deprecated
`rPearson` / `rpearson` requests resolve to canonical `r` rather than
persisting as an independent metric entry. Deprecated exported forwarding
wrappers such as `tail_dependence_score()` and `extended_valindex()` likewise
route to canonical ids rather than creating additional canonical entries.

## Not implemented
- [ ] plot2
- [ ] plotbands
- [ ] plotbandsonly

## Implemented metrics table (auto)
| id | name | category | version_added | references |
| --- | --- | --- | --- | --- |
| alpha | Variability Ratio | scale | 0.1.0 | KGE component definition in hydrology literature using variability ratio sd(sim)/sd(obs). |
| beta | Bias Ratio | bias | 0.1.0 | KGE component definition in hydrology literature using bias ratio mean(sim)/mean(obs). |
| br2 | Bias-Corrected R-squared | correlation | 0.1.0 | Krause et al. (2005) literature-aligned weighted-`r^2` / `bR2`: hydroMetrics now uses the fitted slope `b` with `|b| * r^2` for `b <= 1` and `r^2 / |b|` for `b > 1` under `D-029`. |
| cp | Coefficient of Persistence | efficiency | 0.1.0 | Kitanidis & Bras (1980) hydrologic persistence skill score; hydroMetrics uses the standard coefficient-of-persistence formulation against the one-step observed persistence baseline. |
| d | Willmott Index of Agreement | agreement | 0.1.0 | Willmott, C.J. (1981). On the validation of models. |
| hfb | High Flow Bias | bias | 0.1.0 | Compatibility-stable retained high-flow subset bias using observed values at or above a deterministic quantile threshold; not promoted as a literature-exact or hydroGOF-equivalent high-flow diagnostic. |
| kge | Kling-Gupta Efficiency | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| kgekm | KGE Modified Variability | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2012). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| kgelf | KGE Low-Flow | efficiency | 0.1.0 | Based on Gupta et al. (2009) KGE, with low-flow log-transformed objective-function context from Krause et al. (2005). |
| kgenp | KGE Nonparametric | efficiency | 0.1.0 | Pool, S., Vis, M., & Seibert, J. (2018). Evaluating model performance: towards a non-parametric variant of the Kling-Gupta efficiency. |
| low_flow_bias | Low-Flow Bias | bias | 0.2.2 | Accepted retained package-defined observed lower-30% subset percent-bias diagnostic; Yilmaz et al. (2008) provides low-flow/FDC context, but hydroMetrics does not claim the literature low-flow FDC/log formulation. |
| mae | Mean Absolute Error | error | 0.1.0 | Hyndman & Koehler (2006) forecast-accuracy definition; hydroMetrics uses the standard `mean(abs(sim - obs))` form. |
| mape | Mean Absolute Percentage Error | error | 0.1.0 | Hyndman & Koehler (2006) forecast-accuracy definition; hydroMetrics uses the standard `100 * mean(abs((sim - obs) / obs))` form. |
| md | Modified Index of Agreement | agreement | 0.1.0 | Willmott, C.J., Robeson, S.M., & Matsuura, K. (2012). A refined index of model performance. |
| me | Mean Error | bias | 0.1.0 | Hyndman & Koehler (2006) forecast-accuracy definition; hydroMetrics uses the standard `mean(sim - obs)` form. |
| mnse | Modified NSE | efficiency | 0.1.0 | Legates & McCabe (1999) hydrologic validation context for modified efficiency measures using absolute values; hydroMetrics uses the common absolute-error mNSE form and does not claim a novel definition. |
| mpe | Mean Percentage Error | bias | 0.1.0 | Hyndman & Koehler (2006) forecast-accuracy definition; hydroMetrics uses the standard `100 * mean((sim - obs) / obs)` form. |
| mse | Mean Squared Error | error | 0.1.0 | NIST/SEMATECH and Hyndman & Koehler (2006) squared-error definitions; hydroMetrics uses the standard `mean((sim - obs)^2)` form. |
| nrmse | Normalized Root Mean Squared Error | error | 0.1.0 | Abdelkader et al. (2023) hydrologic example using `NRMSE = RMSE / mean(obs)`; hydroMetrics retains that exact mean-normalized variant and does not imply a universal NRMSE definition. |
| nrmse_sd | NRMSE by SD | error | 0.1.0 | Project-defined NRMSE variant normalized by sd(obs). |
| nse | Nash-Sutcliffe Efficiency | efficiency | 0.1.0 | Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles. |
| pbias | Percent Bias | bias | 0.1.0 | Moriasi et al. (2007) provides opposite-sign percent-bias threshold context, while Abdelkader et al. (2023) uses the same `100 * sum(sim - obs) / sum(obs)` form retained by hydroMetrics; positive values therefore indicate overestimation and Moriasi thresholds are not transferred verbatim. |
| pfactor | P-factor | efficiency | 0.1.0 | Accepted retained package-defined deterministic compatibility metric using the paired-value hit rule `abs(sim - obs) <= tol * abs(obs)` with absolute `tol` fallback at `obs == 0`; not the SWAT/95PPU uncertainty-band P-factor. |
| r | Pearson Correlation | correlation | 0.1.0 | Pearson (1896) product-moment correlation coefficient; this is the canonical Pearson metric id and also the KGE correlation component. |
| r2 | Squared Pearson Correlation | correlation | 0.1.0 | Squared Pearson correlation using the standard `cor(sim, obs)^2` convention. |
| rd | Relative Index of Agreement | agreement | 0.1.0 | Accepted retained package-defined relative Willmott-family compatibility metric with exact observation-normalized formulation fixed by `D-014`, not claimed as a literature-exact index. |
| rfactor | R-factor | error | 0.1.0 | Accepted retained package-defined deterministic compatibility metric `mean(abs(sim - obs)) / mean(abs(obs))`; not the SWAT/95PPU uncertainty-band R-factor. |
| rmse | Root Mean Squared Error | error | 0.1.0 | Hyndman & Koehler (2006) forecast-accuracy definition with NIST/SEMATECH support for squared-error summaries; hydroMetrics uses the standard `sqrt(mean((sim - obs)^2))` form. |
| rnse | Relative NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using observation-scaled relative errors. |
| rsd | Standard Deviation Ratio | scale | 0.1.0 | Project definition for hydrology compatibility: ratio of simulated to observed standard deviation. |
| rspearman | Spearman Correlation | correlation | 0.1.0 | Spearman (1904) rank correlation; hydroMetrics uses the standard Spearman coefficient. |
| rsr | RSR | error | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| skge | Seasonal KGE | efficiency | 0.1.0 | Based on Gupta et al. (2009) KGE with monthly streamflow seasonality context from Gnann et al. (2020) and Berghuijs et al. (2025). |
| ssq | Sum of Squared Errors | error | 0.1.0 | NIST/SEMATECH least-squares summary; hydroMetrics uses the standard `sum((sim - obs)^2)` objective. |
| ubrmse | Unbiased RMSE | error | 0.1.0 | Entekhabi et al. (2010) unbiased-RMSE context; hydroMetrics uses the standard anomaly-series form. |
| ve | Volumetric Efficiency | efficiency | 0.1.0 | Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts. |
| wnse | Weighted NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using observation weights w = obs in the numerator and denominator. |
| wsnse | Weighted Squared NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using squared observation weights w = obs^2 in the numerator and denominator. |

## Missing items summary (auto)
- plot2
- plotbands
- plotbandsonly
