# Mathematical Contract Report

- Generated: 2026-03-10 00:14:31 IST
- Source version: 0.1.0

## Probe results

- Biased prediction check: `R2 = 1.000000`, `NSE = 0.500000`.
- `NRMSE(norm = "mean")` runtime/manual comparison: `0.105409` vs `0.105409`.
- `NSE` runtime/manual comparison: `0.950000` vs `0.950000`.
- `PBIAS` runtime/manual comparison: `0.000000` vs `0.000000`.
- `KGE` runtime/manual comparison: `0.924671` vs `0.924671`.
- `br2` included in registry: `TRUE`.

## Interpretation

- `R2()` is demonstrably different from `NSE()` on a biased-but-perfectly-correlated probe.
- `NRMSE` matches `RMSE / mean(obs)` on the probe series.
- `br2` is present in the internal metric registry and should be treated as project-defined until a definitive literature citation is added.

## Metric metadata observed at runtime

```text
r2||R2 defined as squared Pearson correlation cor(sim, obs)^2.||R-squared defined as squared Pearson correlation.
nrmse||NRMSE computed as RMSE divided by mean(obs).||Common NRMSE normalization by mean(obs) in model-evaluation practice.
nse||NSE computed as 1 - SSE/SST using observed values as baseline.||Nash, J.E. & Sutcliffe, J.V. (1970). River flow forecasting through conceptual models part I - A discussion of principles.
kge||KGE (2009) using r, alpha=sd(sim)/sd(obs), and beta=mean(sim)/mean(obs).||Kling, H., Fuchs, M., & Paulin, M. (2009). Runoff conditions in the upper Danube basin under an ensemble of climate change scenarios.
pbias||PBIAS computed as 100 * sum(sim - obs) / sum(obs).||Moriasi, D.N., et al. (2007). Model evaluation guidelines for systematic quantification of accuracy in watershed simulations.
br2||Bias-penalized Pearson r^2 using variability and mean-ratio penalties.||Project-defined bias-corrected R2 variant pending dedicated paper citation.
```
