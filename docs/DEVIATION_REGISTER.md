# Deviation Register

## Phase 2 accepted deviations

| Function or area | Planned / old behavior | Current hydroMetrics behavior | Reason | Migration note |
| --- | --- | --- | --- | --- |
| `gof()` / `ggof()` output contract | Earlier Phase 2 planning language implied tibble-first outputs with a matrix-mode switch. | Public outputs remain S3 objects over base vectors/data.frames; no `output = "matrix"` switch exists. | The shipped API stabilized around the existing S3/data.frame model and Phase 2 scope excluded an output redesign. | Consume `hydro_metrics` / `hydro_metrics_batch` directly; do not assume tibble output. |
| `ggof()` plotting compatibility | A hydroGOF-style plotting helper was implied by name. | `ggof()` is tabular-only and returns a `hydro_metrics_batch` data.frame-like object. | Phase 2 intentionally preserved a deterministic non-graphical helper instead of adding plot-device behavior. | Treat `ggof()` as a summary-table helper; use external plotting if needed. |
| Plot helper surface | `plot2`, `plotbands`, and `plotbandsonly` appear in compatibility tracking history. | These plotting helpers are not implemented in `hydroMetrics` Phase 2. | Phase 2 focused on metric, wrapper, preprocessing, and package hardening rather than visualization parity. | No direct replacement exists in Phase 2. |
| Public naming surface | Legacy hydroGOF-style names were required, while Phase 3 planning prefers lowercase or underscored additions. | Uppercase compatibility wrappers are now frozen, but existing lowercase Phase 2 exports such as `mae`, `pbias`, `alpha`, `beta`, `r`, and `rsr` remain public. | Removing or renaming existing exports would create avoidable compatibility breakage at the Phase 2 boundary. | Prefer the frozen uppercase compatibility wrappers for legacy-facing code; lowercase exports remain supported. |
