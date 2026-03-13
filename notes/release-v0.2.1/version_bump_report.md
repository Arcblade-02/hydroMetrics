# Version Bump Report

- Review date: 2026-03-10
- Old version: `0.2.0`
- New version: `0.2.1`

## Versioned files

- `DESCRIPTION`: bumped `Version:` from `0.2.0` to `0.2.1`
- `NEWS.md`: promoted the `0.2.1` section from planned to released and added
  the corrective patch-release summary
- `README.md`: updated release-facing package version wording and the local
  source tarball example to `hydroMetrics_0.2.1.tar.gz`
- `docs/PHASE2_EXIT_MEMO.md`: updated the memo to refer to `0.2.1` as the
  corrected final Phase 2 stable baseline

## NEWS entry summary

- corrected exported hydroGOF-style wrapper surface
- direct clean-namespace and clean installed-session wrapper verification added
- Phase 2 compatibility/export closure completed
- `v0.2.0` retained as a superseded historical release

## Documentation regeneration notes

- `devtools::document()` ran on 2026-03-10 and completed successfully with the
  console output `Updating hydroMetrics documentation` / `Loading
  hydroMetrics`.
- That regeneration produced no `NAMESPACE` diff and no `man/` diff because the
  wrapper-export surface was already aligned before the version bump.
- No wrapper exports were lost during regeneration.
