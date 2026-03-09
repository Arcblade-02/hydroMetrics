# Naming Policy Freeze

Phase 2 freezes the current public naming policy at the package boundary.

## Policy

- Legacy hydroGOF-style compatibility exports remain unchanged: `NSE`, `KGE`, `MAE`, `RMSE`, `PBIAS`, `R2`, `NRMSE`, and the legacy NSE-family aliases.
- Phase 3 additions must use lowercase or underscored names only.
- Existing Phase 2 lowercase exports are preserved for backward compatibility and recorded as deviations rather than renamed in-place.

## Current Export Classification

- `alpha`: deviation
- `APFB`: mixed / ambiguous
- `beta`: deviation
- `ggof`: new-name style
- `gof`: new-name style
- `HFB`: mixed / ambiguous
- `hm_result`: mixed / ambiguous
- `KGE`: legacy compatibility name
- `mae`: deviation
- `MAE`: legacy compatibility name
- `mNSeff`: legacy compatibility name
- `NRMSE`: legacy compatibility name
- `NSE`: legacy compatibility name
- `NSeff`: legacy compatibility name
- `pbias`: deviation
- `PBIAS`: legacy compatibility name
- `preproc`: new-name style
- `r`: deviation
- `R2`: legacy compatibility name
- `RMSE`: legacy compatibility name
- `rNSeff`: legacy compatibility name
- `rsr`: deviation
- `valindex`: new-name style
- `wsNSeff`: legacy compatibility name

## Freeze Decision

- No public renames are made in Phase 2 exit work.
- The uppercase compatibility wrappers added in Phase 2 exit become the frozen compatibility surface for release `0.2.0`.
