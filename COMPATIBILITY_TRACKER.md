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
- [x] dr
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
- [x] rd
- [x] rfactor
- [x] rmse
- [x] rNSE
- [x] rPearson
- [x] rSD
- [x] rSpearman
- [x] sKGE
- [x] ssq
- [x] ubRMSE
- [x] VE
- [x] wNSE
- [x] wsNSE

## Not implemented
- [ ] plot2
- [ ] plotbands
- [ ] plotbandsonly

## Implemented metrics table (auto)
| id | name | category | version_added | references |
| --- | --- | --- | --- | --- |
| alpha | Variability Ratio | scale | 0.1.0 | KGE component definition in hydrology literature using variability ratio sd(sim)/sd(obs). |
| beta | Bias Ratio | bias | 0.1.0 | KGE component definition in hydrology literature using bias ratio mean(sim)/mean(obs). |
| br2 | Bias-Corrected R-squared | correlation | 0.1.0 | Krause, P., Boyle, D. P., & Baese, F. (2005). Comparison of different efficiency criteria for hydrological model assessment; the package follows the selected `bR2` interpretation recorded in Architecture Decision D-029. |
| cp | Coefficient of Persistence | efficiency | 0.1.0 | Persistence skill-score definition from hydrology model-evaluation literature. |
| d | Willmott Index of Agreement | agreement | 0.1.0 | Willmott, C.J. (1981). On the validation of models. |
| dr | Relative Absolute Index of Agreement | agreement | 0.1.0 | Willmott agreement-index family with relative absolute-error normalization. |
| hfb | High Flow Bias | bias | 0.1.0 | Clean-room HFB compatibility implementation using deterministic quantile thresholding. |
| kge | Kling-Gupta Efficiency | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| kgekm | KGE Modified Variability | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2012). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| kgelf | KGE Low-Flow | efficiency | 0.1.0 | Based on Gupta et al. (2009) KGE, with low-flow log-transformed objective-function context from Krause et al. (2005). |
| kgenp | KGE Nonparametric | efficiency | 0.1.0 | Pool, S., Vis, M., & Seibert, J. (2018). Evaluating model performance: towards a non-parametric variant of the Kling-Gupta efficiency. |
| mae | Mean Absolute Error | error | 0.1.0 | Standard MAE definition in statistical error analysis literature. |
| mape | Mean Absolute Percentage Error | error | 0.1.0 | Standard mean absolute percentage error definition in forecasting and error-analysis literature. |
| md | Modified Index of Agreement | agreement | 0.1.0 | Willmott, C.J., Robeson, S.M., & Matsuura, K. (2012). A refined index of model performance. |
| me | Mean Error | bias | 0.1.0 | Standard mean error definition in forecast error analysis. |
| mnse | Modified NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using absolute-error numerator and denominator terms. |
| mpe | Mean Percentage Error | bias | 0.1.0 | Standard mean percentage error definition in forecasting and error-analysis literature. |
| mse | Mean Squared Error | error | 0.1.0 | Standard MSE definition in statistical error analysis literature. |
| nrmse | Normalized Root Mean Squared Error | error | 0.1.0 | Common NRMSE normalization by mean(obs) in model-evaluation practice. |
| nrmse_sd | NRMSE by SD | error | 0.1.0 | Project-defined NRMSE variant normalized by sd(obs). |
| nse | Nash-Sutcliffe Efficiency | efficiency | 0.1.0 | Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles. |
| pbias | Percent Bias | bias | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| pfactor | P-factor | efficiency | 0.1.0 | Project-defined compatibility pfactor using tolerance-band hit proportion. |
| r | Pearson Correlation | correlation | 0.1.0 | Pearson correlation coefficient (standard definition). |
| r2 | Squared Pearson Correlation | correlation | 0.1.0 | R-squared defined as squared Pearson correlation. |
| rd | Relative Index of Agreement | agreement | 0.1.0 | Willmott agreement-index family with relative normalization by observations. |
| rfactor | R-factor | error | 0.1.0 | Project-defined compatibility rfactor: mean(abs(sim - obs)) / mean(abs(obs)). |
| rmse | Root Mean Squared Error | error | 0.1.0 | Standard RMSE definition in statistical error analysis texts. |
| rnse | Relative NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using observation-scaled relative errors. |
| rpearson | Pearson Correlation | correlation | 0.1.0 | Pearson correlation coefficient (standard statistical definition). |
| rsd | Standard Deviation Ratio | scale | 0.1.0 | Project definition for hydrology compatibility: ratio of simulated to observed standard deviation. |
| rspearman | Spearman Correlation | correlation | 0.1.0 | Spearman rank correlation (standard statistical definition). |
| rsr | RSR | error | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| skge | Seasonal KGE | efficiency | 0.1.0 | Based on Gupta et al. (2009) KGE with monthly streamflow seasonality context from Gnann et al. (2020) and Berghuijs et al. (2025). |
| ssq | Sum of Squared Errors | error | 0.1.0 | Standard least-squares objective definition. |
| ubrmse | Unbiased RMSE | error | 0.1.0 | Standard unbiased RMSE definition in model-evaluation literature. |
| ve | Volumetric Efficiency | efficiency | 0.1.0 | Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts. |
| wnse | Weighted NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using observation weights w = obs in the numerator and denominator. |
| wsnse | Weighted Squared NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using squared observation weights w = obs^2 in the numerator and denominator. |

## Missing items summary (auto)
- plot2
- plotbands
- plotbandsonly
