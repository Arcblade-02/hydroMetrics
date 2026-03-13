# Output Contract Review

## Reviewed claim

- Claimed plan target: default outputs should be tibble-first, with legacy matrix mode available through `output = "matrix"` or equivalent.

## Current behavior

- `gof()` nominal result type: `hydro_metrics`.
- `ggof()` nominal result type: `hydro_metrics_batch`.
- Compatibility wrappers such as `NSE()`, `PBIAS()`, and `NRMSE()` return numeric scalars or numeric vectors rather than tibble objects.
- No current public `output` argument or matrix/tibble switch is implemented on the exported API.

## Review result

- Status: intentionally changed.
- Phase 2 exits with the shipped S3/data.frame output model and a formal downgrade of any earlier tibble-first claim.
- No output-contract redesign is performed in Phase 2 exit work.
