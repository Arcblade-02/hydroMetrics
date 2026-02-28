# hydroGOF Compatibility Tracker

Generated on: 2026-02-28

## Target hydroGOF exports (checklist)
- [ ] APFB
- [ ] br2
- [ ] cp
- [ ] d
- [ ] dr
- [ ] ggof
- [ ] gof
- [ ] HFB
- [x] KGE
- [ ] KGEkm
- [ ] KGElf
- [ ] KGEnp
- [x] mae
- [ ] md
- [ ] me
- [ ] mNSE
- [ ] mNSeff
- [x] mse
- [x] nrmse
- [x] NSE
- [ ] NSeff
- [x] pbias
- [ ] pbiasfdc
- [ ] pfactor
- [ ] plot2
- [ ] plotbands
- [ ] plotbandsonly
- [ ] preproc
- [x] R2
- [ ] rd
- [ ] rfactor
- [x] rmse
- [ ] rNSE
- [ ] rNSeff
- [ ] rPearson
- [ ] rSD
- [ ] rSpearman
- [x] rsr
- [ ] sKGE
- [ ] ssq
- [ ] ubRMSE
- [ ] valindex
- [x] VE
- [ ] wNSE
- [ ] wsNSE
- [ ] wsNSeff

## Implemented metrics table (auto)
| id | name | category | version_added | references |
| --- | --- | --- | --- | --- |
| kge | Kling-Gupta Efficiency | efficiency | 0.1.0 | Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. |
| mae | Mean Absolute Error | error | 0.1.0 | Standard MAE definition in statistical error analysis literature. |
| mape | Mean Absolute Percentage Error | error | 0.1.0 | Standard mean absolute percentage error definition in forecasting and error-analysis literature. |
| mpe | Mean Percentage Error | bias | 0.1.0 | Standard mean percentage error definition in forecasting and error-analysis literature. |
| mse | Mean Squared Error | error | 0.1.0 | Standard MSE definition in statistical error analysis literature. |
| nrmse | Normalized Root Mean Squared Error | error | 0.1.0 | Common NRMSE normalization by mean(obs) in model-evaluation practice. |
| nrmse_sd | NRMSE by SD | error | 0.1.0 | Project-defined NRMSE variant normalized by sd(obs). |
| nse | Nash-Sutcliffe Efficiency | efficiency | 0.1.0 | Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles. |
| pbias | Percent Bias | bias | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| r | Pearson Correlation | correlation | 0.1.0 | Pearson correlation coefficient (standard definition). |
| r2 | Squared Pearson Correlation | correlation | 0.1.0 | R-squared defined as squared Pearson correlation. |
| rmse | Root Mean Squared Error | error | 0.1.0 | Standard RMSE definition in statistical error analysis texts. |
| rsr | RSR | error | 0.1.0 | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. |
| ve | Volumetric Efficiency | efficiency | 0.1.0 | Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts. |

## Missing items summary (auto)
- APFB
- br2
- cp
- d
- dr
- ggof
- gof
- HFB
- KGEkm
- KGElf
- KGEnp
- md
- me
- mNSE
- mNSeff
- NSeff
- pbiasfdc
- pfactor
- plot2
- plotbands
- plotbandsonly
- preproc
- rd
- rfactor
- rNSE
- rNSeff
- rPearson
- rSD
- rSpearman
- sKGE
- ssq
- ubRMSE
- valindex
- wNSE
- wsNSE
- wsNSeff
