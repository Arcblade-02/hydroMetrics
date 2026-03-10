# Naming Policy Verification

- Review date: 2026-03-10
- Source version: `0.2.0`

## Policy result

The current source branch matches the intended Phase 2 compatibility contract:

- legacy hydroGOF-style wrapper names remain directly callable by their legacy
  names
- orchestration/public entry points remain exported separately
- lowercase/internal-style names remain available where they were already
  public and are documented as retained compatibility paths, not silent
  replacements for the legacy names

## Export classification

| Export | Classification | Notes |
| --- | --- | --- |
| `NSE` | legacy compatibility name | Direct public hydroGOF-style wrapper |
| `KGE` | legacy compatibility name | Direct public hydroGOF-style wrapper |
| `MAE` | legacy compatibility name | Direct public hydroGOF-style wrapper |
| `RMSE` | legacy compatibility name | Direct public hydroGOF-style wrapper |
| `PBIAS` | legacy compatibility name | Direct public hydroGOF-style wrapper |
| `R2` | legacy compatibility name | Direct public hydroGOF-style wrapper; semantics remain squared Pearson correlation |
| `NRMSE` | legacy compatibility name | Direct public hydroGOF-style wrapper; `norm = "mean"` only |
| `NSeff` | legacy compatibility name | Preserved Phase 2 legacy NSE-family alias |
| `mNSeff` | legacy compatibility name | Preserved Phase 2 legacy NSE-family alias |
| `rNSeff` | legacy compatibility name | Preserved Phase 2 legacy NSE-family alias |
| `wsNSeff` | legacy compatibility name | Preserved Phase 2 legacy NSE-family alias |
| `gof` | orchestration/public entry point | Main metric orchestration interface |
| `ggof` | deviation | Non-plotting compatibility helper that returns tabular output |
| `preproc` | orchestration/public entry point | Public preprocessing interface |
| `valindex` | orchestration/public entry point | Public compatibility forwarder to `gof()` |
| `APFB` | legacy compatibility name | Indexed compatibility wrapper with time-index requirement |
| `HFB` | legacy compatibility name | Deterministic compatibility wrapper |
| `alpha` | internal/new-style name | Retained lowercase compatibility export |
| `beta` | internal/new-style name | Retained lowercase compatibility export |
| `mae` | internal/new-style name | Retained lowercase compatibility export alongside `MAE()` |
| `pbias` | internal/new-style name | Retained lowercase compatibility export alongside `PBIAS()` |
| `r` | internal/new-style name | Retained lowercase compatibility export |
| `rsr` | internal/new-style name | Retained lowercase compatibility export |
| `hm_result` | orchestration/public entry point | Result constructor/helper exposed by the package |

## Lowercase relationship notes

- `pbias()` remains exported alongside `PBIAS()`; the lowercase name is a
  retained compatibility path and does not replace the legacy uppercase public
  wrapper.
- `mae()` remains exported alongside `MAE()` under the same policy.
- No lowercase compatibility export is removed in this closure.
