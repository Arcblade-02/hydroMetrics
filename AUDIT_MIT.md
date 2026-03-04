# MIT Clean-Room Audit Trail

| Metric | Formula source | Citation | Notes (clean-room) |
| --- | --- | --- | --- |
| NSE | Equation from published definition | Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles. | Implemented directly from paper-level equation, without copying upstream package code. |
| RMSE | Standard textbook definition | General statistical error analysis references describing RMSE as sqrt(mean((sim-obs)^2)). | Implemented from canonical formula only; no external package code consulted. |
| PBIAS | Hydrology literature definition | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. | Implemented from published percent-bias definition, with explicit clean-room policy `sum(obs) != 0` and deterministic failure message when undefined. |
| MAE | Mathematical definition | Standard MAE definition in statistical error analysis literature. | Implemented from mathematical definition (clean-room), with explicit `n >= 1` policy. |
| MSE | Mathematical definition | Standard MSE definition in statistical error analysis literature. | Implemented from mathematical definition (clean-room). |
| NRMSE | Mathematical definition with explicit project normalization | Common NRMSE normalization by mean(obs) in model-evaluation practice. | Implemented from mathematical definition (clean-room). |
| R | Mathematical definition | Pearson correlation coefficient (standard definition). | Implemented from mathematical definition (clean-room). |
| R2 | Mathematical definition | R-squared defined as squared Pearson correlation. | Implemented from mathematical definition (clean-room). |
| KGE | Mathematical definition from published metric | Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios. | Implemented from mathematical definition (clean-room). |
| RSR | Mathematical definition from model-evaluation guidance | Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations. | Implemented from mathematical definition (clean-room), with explicit policies `n >= 2` and `sd(obs) > 0` plus deterministic failure message. |
| MAPE | Mathematical definition | Standard mean absolute percentage error definition in forecasting and error-analysis literature. | Implemented from mathematical definition (clean-room). |
| MPE | Mathematical definition | Standard mean percentage error definition in forecasting and error-analysis literature. | Implemented from mathematical definition (clean-room). |
| VE | Mathematical definition from hydrology literature | Criss, R.E. & Winston, W.E. (2008). Do Nash values have value? Discussion of hydrologic model performance metrics including volumetric concepts. | Implemented from mathematical definition (clean-room). |
| NRMSE_SD | Project-defined mathematical variant | Project-defined NRMSE variant normalized by sd(obs). | Implemented from mathematical definition (clean-room). |
| ME | Mathematical definition | Standard mean error definition in forecast error analysis. | Implemented from mathematical definition (clean-room). |
| d | Mathematical definition from agreement-index literature | Willmott, C.J. (1981). On the validation of models. | Implemented from published formula definition, no code copied. |
| md | Mathematical definition from modified agreement-index literature | Willmott, C.J., Robeson, S.M., & Matsuura, K. (2012). A refined index of model performance. | Implemented from published formula definition, no code copied. |
| rd | Relative agreement formula variant | Willmott agreement-index family with relative normalization by observations. | Implemented from explicit formula definition selected for compatibility tracking. |
| dr | Relative absolute-agreement formula variant | Willmott agreement-index family with relative absolute-error normalization. | Implemented from explicit formula definition selected for compatibility tracking. |
| br2 | Bias-penalized correlation formulation | Project-defined bias-corrected R2 variant pending dedicated paper citation. | Implemented from mathematical formula definition, no code copied. |
| rNSE | Relative NSE variant | NSE family variant per hydrology literature (relative scaling by observations). | Implemented from explicit formula definition, no code copied. |
| mNSE | Modified NSE variant | NSE family variant using absolute-error formulation in hydrology literature. | Implemented from explicit formula definition, no code copied. |
| wNSE | Weighted NSE variant | NSE family weighted variant using observation-derived weights. | Implemented from explicit formula definition, no code copied. |
| wsNSE | Weighted-squared NSE variant | NSE family weighted variant using squared observation weights. | Implemented from explicit formula definition, no code copied. |
| ubRMSE | Unbiased RMSE | Standard anomaly-based RMSE definition in model evaluation. | Implemented from mathematical definition (clean-room). |
| ssq | Sum of squared errors | Standard least-squares objective definition. | Implemented from mathematical definition (clean-room). |
| KGEkm | KGE variant with CV ratio | KGE-variant practice using gamma = CV(sim)/CV(obs); citation to refine. | Implemented from formula derivation only, no source code copied. |
| KGElf | Low-flow transformed KGE | KGE low-flow variant using log-transformed nonnegative flows; citation to refine. | Implemented from formula derivation only, no source code copied. |
| KGEnp | Nonparametric KGE | Nonparametric KGE variant using Spearman/IQR/median components; citation to refine. | Implemented from formula derivation only, no source code copied. |
| sKGE | Seasonal KGE | Seasonal KGE averaging over monthly groups (project-defined implementation). | Implemented from formula derivation only, no source code copied. |
| pbiasfdc | FDC percent bias | Flow duration curve bias over fixed quantile grid (project-defined deterministic formulation). | Implemented from formula derivation only, no source code copied. |
| rPearson | Statistical correlation definition | Pearson correlation coefficient (standard statistical definition). | Implemented from statistical definition only, no source code copied. |
| rSpearman | Statistical rank-correlation definition | Spearman rank correlation (standard statistical definition). | Implemented from statistical definition only, no source code copied. |
| rSD | Scale-ratio definition | Project-defined ratio `sd(sim)/sd(obs)` for compatibility. | Implemented from explicit formula definition, no source code copied. |
| cp | Persistence skill-score formula | Persistence-skill definition from hydrology model-evaluation literature (citation to refine). | Implemented from explicit mathematical definition, no upstream code copied. |
| preproc | Deterministic preprocessing policy | Project-defined preprocessing helper behavior for aligned NA filtering and coercion. | Implemented from project specification, no upstream code copied. |
| valindex | Project-defined aggregation formula | Project-defined normalized weighted aggregate over selected metrics (`NSE`, `KGE`, `rmse`, `pbias`, `rPearson`). | Implemented from transparent mathematical transforms, no upstream code copied. |
| pfactor | Tolerance-band hit proportion | Project-defined compatibility pfactor with clean-room tolerance policy (`tol * abs(obs)`; absolute `tol` when `obs == 0`). | Implemented from explicit mathematical definition, no upstream code copied. |
| rfactor | Normalized absolute error ratio | Project-defined compatibility rfactor as `mean(abs(sim - obs)) / mean(abs(obs))`. | Implemented from explicit mathematical definition, no upstream code copied. |
