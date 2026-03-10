# Wrapper Export Decisions

- Review date: 2026-03-10
- Source version: `0.2.0`
- Installed namespace baseline observed locally: `hydroMetrics 0.1.0`

## Decision summary

The target hydroGOF-style public wrappers are already present in source,
already marked with roxygen `@export`, already present in `NAMESPACE`, and
already documented in `man/`. The closure work in this branch therefore does
not add new metric formulas or redesign wrapper logic. It closes the remaining
release blocker by adding explicit inventory, naming-policy documentation,
direct wrapper tests, clean-install runtime proof, and release-facing notes.

## Target wrappers

| Wrapper | Old state | New state | Export added | Wrapper layer added | Remaining deviation |
| --- | --- | --- | --- | --- | --- |
| `NSE()` | Present in source, roxygen, `NAMESPACE`, and `man/`; absent from locally installed `0.1.0` namespace | Verified by direct wrapper tests and clean-install runtime check | No | No | None |
| `KGE()` | Present in source, roxygen, `NAMESPACE`, and `man/`; absent from locally installed `0.1.0` namespace | Verified by direct wrapper tests and clean-install runtime check | No | No | None |
| `RMSE()` | Present in source, roxygen, `NAMESPACE`, and `man/`; absent from locally installed `0.1.0` namespace | Verified by direct wrapper tests and clean-install runtime check | No | No | None |
| `R2()` | Present in source, roxygen, `NAMESPACE`, and `man/`; absent from locally installed `0.1.0` namespace | Verified by direct wrapper tests and clean-install runtime check | No | No | `R2()` remains squared Pearson correlation, not `NSE()` |
| `NRMSE()` | Present in source, roxygen, `NAMESPACE`, and `man/`; absent from locally installed `0.1.0` namespace | Verified by direct wrapper tests and clean-install runtime check | No | No | `norm = "mean"` only remains explicit |
| `PBIAS()` | Present in source, roxygen, `NAMESPACE`, and `man/`; absent from locally installed `0.1.0` namespace | Verified by direct wrapper tests and clean-install runtime check | No | No | None |

## Related exports retained

- `gof()`, `ggof()`, `preproc()`, and `valindex()` remain exported orchestration
  entry points.
- Lowercase/internal-style compatibility exports remain public where they were
  already public: `alpha()`, `beta()`, `mae()`, `pbias()`, `r()`, and `rsr()`.
- Indexed wrappers `APFB()` and `HFB()` remain exported as compatibility
  wrappers with their existing documented constraints.

## Documentation regeneration

- `devtools::document()` ran on 2026-03-10 and completed successfully with the
  console output `Updating hydroMetrics documentation` / `Loading
  hydroMetrics`.
- That regeneration produced no additional `NAMESPACE` diff and no additional
  `man/` diff because the current source tree was already aligned with the
  exported wrapper contract.
- `README.md` now describes the uppercase legacy hydroGOF-style wrappers as
  part of the public surface instead of understating the export set.
- `NEWS.md` now records the wrapper/export closure as the planned `0.2.1`
  corrective release item.
- `docs/DEVIATION_REGISTER.md` and `docs/PHASE2_EXIT_MEMO.md` now describe the
  wrapper/export state consistently and keep the `ggof()` deviation explicit.
