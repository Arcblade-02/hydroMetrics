# hydroGOF Compatibility Tracker

Generated on: 2026-03-04

## Target hydroGOF exports (checklist)
- [x] APFB
- [x] br2
- [x] cp
- [x] d
- [x] dr
- [x] ggof
- [x] gof
- [x] HFB
- [x] KGE
- [x] KGEkm
- [x] KGElf
- [x] KGEnp
- [x] mae
- [x] md
- [x] me
- [x] mNSE
- [x] mNSeff
- [x] mse
- [x] nrmse
- [x] NSE
- [x] NSeff
- [x] pbias
- [x] pbiasfdc
- [x] pfactor
- [ ] plot2
- [ ] plotbands
- [ ] plotbandsonly
- [x] preproc
- [x] R2
- [x] rd
- [x] rfactor
- [x] rmse
- [x] rNSE
- [x] rNSeff
- [x] rPearson
- [x] rSD
- [x] rSpearman
- [x] rsr
- [x] sKGE
- [x] ssq
- [x] ubRMSE
- [x] valindex
- [x] VE
- [x] wNSE
- [x] wsNSE
- [x] wsNSeff

## Implemented metrics table (auto)
| id | name | category | version_added | references |
| --- | --- | --- | --- | --- |
| alpha | Variability Ratio | scale | 0.1.0 | KGE component definition in hydrology literature using variability ratio sd(sim)/sd(obs). |
| beta | Bias Ratio | bias | 0.1.0 | KGE component definition in hydrology literature using bias ratio mean(sim)/mean(obs). |
| br2 | Bias-Corrected R-squared | correlation | 0.1.0 | Project-defined bias-corrected R2 variant pending dedicated paper citation. |
| cp | Coefficient of Persistence | efficiency | 0.1.0 | Persistence skill-score definition from hydrology model-evaluation literature. |
| d | Willmott Index of Agreement | agreement | 0.1.0 | Willmott, C.J. (1981). On the validation of models. |
| dr | Relative Absolute Index of Agreement | agreement | 0.1.0 | Willmott agreement-index family with relative absolute-error normalization. |
| kge | Kling-Gupta Efficiency | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| kgekm | KGE Modified Variability | efficiency | 0.1.0 | KGE variant definitions in hydrology practice using coefficient-of-variation ratio; citation to be refined. |
| kgelf | KGE Low-Flow | efficiency | 0.1.0 | KGE low-flow emphasis variants in hydrology practice; exact citation to be refined. |
| kgenp | KGE Nonparametric | efficiency | 0.1.0 | Nonparametric KGE formulations in hydrology practice; exact citation to be refined. |
| mae | Mean Absolute Error | error | 0.1.0 | Standard MAE definition in statistical error analysis literature. |
| mape | Mean Absolute Percentage Error | error | 0.1.0 | Standard mean absolute percentage error definition in forecasting and error-analysis literature. |
| md | Modified Index of Agreement | agreement | 0.1.0 | Willmott, C.J., Robeson, S.M., & Matsuura, K. (2012). A refined index of model performance. |
| me | Mean Error | bias | 0.1.0 | Standard mean error definition in forecast error analysis. |
| mnse | Modified NSE | efficiency | 0.1.0 | NSE modified variants in hydrology literature; exact citation to be refined. |
| mpe | Mean Percentage Error | bias | 0.1.0 | Standard mean percentage error definition in forecasting and error-analysis literature. |
| mse | Mean Squared Error | error | 0.1.0 | Standard MSE definition in statistical error analysis literature. |
| nrmse | Normalized Root Mean Squared Error | error | 0.1.0 | Common NRMSE normalization by mean(obs) in model-evaluation practice. |
| nrmse_sd | NRMSE by SD | error | 0.1.0 | Project-defined NRMSE variant normalized by sd(obs). |
| nse | Nash-Sutcliffe Efficiency | efficiency | 0.1.0 | Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles. |
| pbias | Percent Bias | bias | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| pbiasfdc | Percent Bias of Flow Duration Curve | bias | 0.1.0 | Flow duration curve bias formulation implemented per project decision pending definitive citation. |
| pfactor | P-factor | efficiency | 0.1.0 | Project-defined compatibility pfactor using tolerance-band hit proportion. |
| r | Pearson Correlation | correlation | 0.1.0 | Pearson correlation coefficient (standard definition). |
| r2 | Squared Pearson Correlation | correlation | 0.1.0 | R-squared defined as squared Pearson correlation. |
| rd | Relative Index of Agreement | agreement | 0.1.0 | Willmott agreement-index family with relative normalization by observations. |
| rfactor | R-factor | error | 0.1.0 | Project-defined compatibility rfactor: mean(abs(sim - obs)) / mean(abs(obs)). |
| rmse | Root Mean Squared Error | error | 0.1.0 | Standard RMSE definition in statistical error analysis texts. |
| rnse | Relative NSE | efficiency | 0.1.0 | NSE relative variants in hydrology literature; exact citation to be refined. |
| rpearson | Pearson Correlation | correlation | 0.1.0 | Pearson correlation coefficient (standard statistical definition). |
| rsd | Standard Deviation Ratio | scale | 0.1.0 | Project definition for hydrology compatibility: ratio of simulated to observed standard deviation. |
| rspearman | Spearman Correlation | correlation | 0.1.0 | Spearman rank correlation (standard statistical definition). |
| rsr | RSR | error | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| skge | Seasonal KGE | efficiency | 0.1.0 | Seasonal KGE variant definition implemented per project decision pending definitive citation. |
| ssq | Sum of Squared Errors | error | 0.1.0 | Standard least-squares objective definition. |
| ubrmse | Unbiased RMSE | error | 0.1.0 | Standard unbiased RMSE definition in model-evaluation literature. |
| ve | Volumetric Efficiency | efficiency | 0.1.0 | Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts. |
| wnse | Weighted NSE | efficiency | 0.1.0 | NSE weighted variants in hydrology literature; exact citation to be refined. |
| wsnse | Weighted Squared NSE | efficiency | 0.1.0 | NSE weighted variants in hydrology literature; exact citation to be refined. |

## Missing items summary (auto)
- plot2
- plotbands
- plotbandsonly
