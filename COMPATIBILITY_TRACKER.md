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

Deprecated alias paths still accepted at runtime are `rPearson`,
`nrmse_sd`, `mutual_information_score`, `rfactor`, `pfactor`, `br2`,
`rd`, `hfb`, `tail_dependence_score`, and `extended_valindex`.
Deprecated exported forwarding wrappers retained at runtime are
`mutual_information_score()`, `HFB()`, `tail_dependence_score()`, and
`extended_valindex()`.
Silent compatibility metric-id aliases still accepted at runtime are
`kgelf` and `skge`.

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
- [x] slope_scaled_r2
- [x] cp
- [x] d
- [x] KGE
- [x] KGEkm
- [x] Log-Transformed KGE
- [x] KGEnp
- [x] md
- [x] me
- [x] mNSE
- [x] mse
- [x] nrmse
- [x] NSE
- [x] within_tolerance_rate
- [x] R2
- [x] obs_normalized_agreement_index
- [x] mean_absolute_error_ratio
- [x] rmse
- [x] rNSE
- [x] rPearson
- [x] rSD
- [x] rSpearman
- [x] Monthly Grouped KGE
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
| mean_absolute_error_ratio | Mean Absolute Error Ratio | error | 0.1.0 | Package-defined canonical mean absolute error ratio: mean(abs(sim - obs)) / mean(abs(obs)). |
| cdf_rmse | Empirical CDF RMSE | error | 0.2.2 | Package-defined empirical-distribution diagnostic that summarizes paired empirical CDF disagreement through an RMSE-style score. |
| cp | Coefficient of Persistence | efficiency | 0.1.0 | Persistence skill-score definition from hydrology model-evaluation literature. |
| d | Willmott Index of Agreement | agreement | 0.1.0 | Willmott, C.J. (1981). On the validation of models. |
| high_flow_percent_bias | High Flow Percent Bias | bias | 0.1.0 | Clean-room HFB-derived canonical metric using deterministic quantile thresholding. |
| kge | Kling-Gupta Efficiency | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| kgekm | KGE Modified Variability | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2012). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| log_transformed_kge | Log-Transformed KGE | efficiency | 0.1.0 | Based on Gupta et al. (2009) KGE, with log-transformed low-flow context from Krause et al. (2005). |
| kgenp | KGE Nonparametric | efficiency | 0.1.0 | Pool, S., Vis, M., & Seibert, J. (2018). Evaluating model performance: towards a non-parametric variant of the Kling-Gupta efficiency. |
| mae | Mean Absolute Error | error | 0.1.0 | Standard MAE definition in statistical error analysis literature. |
| mape | Mean Absolute Percentage Error | error | 0.1.0 | Standard mean absolute percentage error definition in forecasting and error-analysis literature. |
| md | Modified Index of Agreement | agreement | 0.1.0 | Willmott, C.J., Robeson, S.M., & Matsuura, K. (2012). A refined index of model performance. |
| me | Mean Error | bias | 0.1.0 | Standard mean error definition in forecast error analysis. |
| mutual_information | Mutual Information | agreement | 0.2.2 | Canonical raw pooled-grid mutual information in nats using pooled-support Sturges histogram bins and natural logs. |
| mnse | Modified NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using absolute-error numerator and denominator terms. |
| mpe | Mean Percentage Error | bias | 0.1.0 | Standard mean percentage error definition in forecasting and error-analysis literature. |
| mse | Mean Squared Error | error | 0.1.0 | Standard MSE definition in statistical error analysis literature. |
| nrmse | Normalized Root Mean Squared Error | error | 0.1.0 | Common NRMSE normalization by mean(obs) in model-evaluation practice. |
| nse | Nash-Sutcliffe Efficiency | efficiency | 0.1.0 | Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles. |
| pbias | Percent Bias | bias | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| slope_scaled_r2 | Slope-Scaled R-squared | correlation | 0.1.0 | Krause, P., Boyle, D. P., & Baese, F. (2005). Comparison of different efficiency criteria for hydrological model assessment; the package follows the selected `bR2` interpretation recorded in Architecture Decision D-029. |
| r | Pearson Correlation | correlation | 0.1.0 | Pearson correlation coefficient (standard definition). |
| r2 | Squared Pearson Correlation | correlation | 0.1.0 | R-squared defined as squared Pearson correlation. |
| obs_normalized_agreement_index | Observation-Normalized Agreement Index | agreement | 0.1.0 | Willmott agreement-index family with observation-normalized relative terms. |
| within_tolerance_rate | Within Tolerance Rate | efficiency | 0.1.0 | Package-defined canonical within_tolerance_rate using tolerance-band hit proportion. |
| rmse | Root Mean Squared Error | error | 0.1.0 | Standard RMSE definition in statistical error analysis texts. |
| rnse | Relative NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using observation-scaled relative errors. |
| rpearson | Pearson Correlation | correlation | 0.1.0 | Pearson correlation coefficient (standard statistical definition). |
| rsd | Standard Deviation Ratio | scale | 0.1.0 | Package-defined hydrology compatibility metric using the ratio of simulated to observed standard deviation. |
| rspearman | Spearman Correlation | correlation | 0.1.0 | Spearman rank correlation (standard statistical definition). |
| rsr | RSR | error | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| monthly_grouped_kge | Monthly Grouped KGE | efficiency | 0.1.0 | Based on Gupta et al. (2009) KGE with monthly streamflow grouping context from Gnann et al. (2020) and Berghuijs et al. (2025). |
| upper_tail_conditional_exceedance | Upper Tail Conditional Exceedance | agreement | 0.4.0 | Package-defined upper-tail exceedance agreement diagnostic grounded in Coles et al. (1999) using the observed type-7 0.9 quantile threshold. |
| composite_performance_index | Composite Performance Index | agreement | 0.4.0 | Package-defined equal-weight composite of stable deterministic metrics extending the package valindex decision context. |
| ssq | Sum of Squared Errors | error | 0.1.0 | Standard least-squares objective definition. |
| ubrmse | Unbiased RMSE | error | 0.1.0 | Standard unbiased RMSE definition in model-evaluation literature. |
| ve | Volumetric Efficiency | efficiency | 0.1.0 | Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts. |
| wnse | Weighted NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using observation weights w = obs in the numerator and denominator. |
| wsnse | Weighted Squared NSE | efficiency | 0.1.0 | Based on Nash & Sutcliffe (1970) NSE, using squared observation weights w = obs^2 in the numerator and denominator. |

## Missing items summary (auto)
- plot2
- plotbands
- plotbandsonly
