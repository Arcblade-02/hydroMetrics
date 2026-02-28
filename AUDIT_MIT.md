# MIT Clean-Room Audit Trail

| Metric | Formula source | Citation | Notes (clean-room) |
| --- | --- | --- | --- |
| NSE | Equation from published definition | Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles. | Implemented directly from paper-level equation, without copying upstream package code. |
| RMSE | Standard textbook definition | General statistical error analysis references describing RMSE as sqrt(mean((sim-obs)^2)). | Implemented from canonical formula only; no external package code consulted. |
| PBIAS | Hydrology literature definition | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. | Implemented from published percent-bias definition, independent clean-room implementation. |
| MAE | Mathematical definition | Standard MAE definition in statistical error analysis literature. | Implemented from mathematical definition (clean-room). |
| MSE | Mathematical definition | Standard MSE definition in statistical error analysis literature. | Implemented from mathematical definition (clean-room). |
| NRMSE | Mathematical definition with explicit project normalization | Common NRMSE normalization by mean(obs) in model-evaluation practice. | Implemented from mathematical definition (clean-room). |
| R | Mathematical definition | Pearson correlation coefficient (standard definition). | Implemented from mathematical definition (clean-room). |
| R2 | Mathematical definition | R-squared defined as squared Pearson correlation. | Implemented from mathematical definition (clean-room). |
| KGE | Mathematical definition from published metric | Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. | Implemented from mathematical definition (clean-room). |
| RSR | Mathematical definition from model-evaluation guidance | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. | Implemented from mathematical definition (clean-room). |
| MAPE | Mathematical definition | Standard mean absolute percentage error definition in forecasting and error-analysis literature. | Implemented from mathematical definition (clean-room). |
| MPE | Mathematical definition | Standard mean percentage error definition in forecasting and error-analysis literature. | Implemented from mathematical definition (clean-room). |
| VE | Mathematical definition from hydrology literature | Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts. | Implemented from mathematical definition (clean-room). |
| NRMSE_SD | Project-defined mathematical variant | Project-defined NRMSE variant normalized by sd(obs). | Implemented from mathematical definition (clean-room). |
