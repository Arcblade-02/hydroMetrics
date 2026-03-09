# R2 and NRMSE Verification

## R2

- Test case: `obs = c(1, 2, 3, 4)`, `sim = c(2, 3, 4, 5)`.
- `R2(obs, sim)` result: `1`.
- `NSE(obs, sim)` result on the same biased predictions: `0.2`.
- Result: `R2` is not an alias of `NSE`; under additive bias they diverge numerically while correlation remains perfect.

## NRMSE

- Public wrapper present: `NRMSE()`.
- Phase 2 frozen normalization contract: `norm = "mean"` only.
- Example `NRMSE(c(1, 2, 4), c(1, 2, 3), norm = "mean")` = `0.2886751`.
- Manual CV-RMSE calculation `sqrt(mean((sim - obs)^2)) / mean(obs)` = `0.2886751`.
- Result: the exported wrapper matches the Phase 2 plan requirement for CV-RMSE-style normalization by `mean(obs)`.
