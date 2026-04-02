# 0.4.x Release Evidence Record

This record captures the validated post-Batch-7 baseline for the current
`0.4.x` line.

It supersedes the earlier baseline-establishment evidence framing by recording
the current stabilized state after Batch 5, Batch 6, Batch 7, and the
post-Batch-7 live backlog triage.

It is a release-positioning and baseline-closure artifact. It is not, by
itself, a CRAN submission approval.

## Release Candidate Summary

- Intended version: `0.4.0` on the current `0.4.x` line
- Release type:
  - post-stabilization baseline closure / release-positioning record
- Branch: `dev`
- Branch position at review time:
  - `dev`, `origin/dev`, and `origin/main` all point to commit
    `440359b1104617a73f2b453164edc55a254ae899`
- Commit SHA:
  - current reviewed `HEAD`: `440359b1104617a73f2b453164edc55a254ae899`
- Review date:
  - `2026-04-02`
- Reviewer:
  - maintainer final-mile completion pass

## Release Framing

- Intended public framing:
  - The current `0.4.x` line is a stabilized, post-Batch-7 baseline on the
    active `dev` branch.
- What this record explicitly claims:
  - Batch 5 closure work is complete.
  - Batch 6 wrapper / compatibility / deprecated / discovery contract
    consolidation is complete.
  - Batch 7 vignette contract alignment is complete.
  - A live post-Batch-7 backlog triage was performed against the current repo
    state.
  - That triage found no meaningful immediate cleanup batch remaining.
  - Remaining items are explicitly treated as deferred rather than active
    stabilization backlog.
- What this record explicitly does **not** claim:
  - CRAN submission readiness
  - pkgdown/site readiness
  - reverse-dependency review completion
  - that all future wrapper or compatibility strategy decisions are complete
  - that broader post-closure roadmap work has already been executed

## Stabilization Baseline Objective

The stabilization objective pursued on the current `0.4.x` line was to move the
package from a post-Phase-4 baseline-establishment state into a cleaner,
explicitly governed, contract-aligned, and validated working baseline.

This stabilization lane focused on public-surface correctness and consistency,
not on formula redesign or broad architectural change.

The target outcome was:

- removal of stale or duplicate alias residue
- synchronization of docs, governance language, discovery exposure, and tests
- alignment of package-facing vignettes to the current canonical /
  compatibility / deprecated contract
- explicit live reassessment of whether any meaningful cleanup backlog remained

## Batch Completion Summary

### Batch 5

Batch 5 closed the stale internal alias residue and discovery-contract cleanup
lane.

Completed in Batch 5:

- stale internal `rpearson` residue removed
- compatibility / governance docs synchronized afterward
- getting-started vignette version drift fixed
- metric-reference vignette aligned to public discovery APIs
- `metric_search` / `metric_preset` tests re-baselined to the actual package
  contract
- validated package state restored on the then-current baseline

### Batch 6

Batch 6 closed the wrapper / compatibility / deprecated / discovery contract
alignment lane.

Completed in Batch 6:

- `README.md` updated to reflect the actual wrapper and lifecycle surface
- `GOVERNANCE.md` updated to reflect current lifecycle classification
- `COMPATIBILITY_TRACKER.md` tightened as a compatibility ledger rather than a
  canonical discovery source
- explicit distinction recorded between:
  - stable exports
  - compatibility exports
  - deprecated exported forwarding wrappers
  - orchestration-only aliases
  - discovery-canonical metric ids
- `test-metric_search.R` updated to lock canonical-vs-compatibility-vs-
  deprecated discovery behavior

### Batch 7

Batch 7 closed the remaining vignette contract-alignment lane.

Completed in Batch 7:

- `vignettes/calibration-guide.Rmd` aligned to canonical current metric names
- `vignettes/metric-reference.Rmd` aligned to canonical current metric names
- deprecated forwarding wrappers retained only as transition notes in vignette
  teaching material
- package-facing vignette language now matches the Batch 6 public contract

## Post-Batch-7 Live Backlog Triage

A fresh repo-wide reassessment was performed after Batch 7 against the live
current package state.

The triage reviewed:

- exported wrappers
- compatibility exports
- deprecated forwarding wrappers
- orchestration-only aliases
- discovery-visible canonical ids
- `README.md`
- `GOVERNANCE.md`
- `COMPATIBILITY_TRACKER.md`
- `DECISIONS.md`
- package-facing vignettes
- man pages
- relevant public-surface and compatibility tests

### Triage conclusion

The post-Batch-7 live reassessment found:

- no meaningful immediate cleanup batch remaining
- no active public-contract mismatch requiring another isolated stabilization
  batch
- remaining items are defer-only rather than active blockers

This means the correct next move is formal baseline closure / release
positioning rather than an invented Batch 8.

## Current Contract Classification

### Stable

The following are treated as stable on the current `0.4.x` line:

- orchestration entry points:
  - `gof()`
  - `ggof()`
  - `preproc()`
  - `valindex()`
- documented exported helpers:
  - `metric_search()`
  - `metric_preset()`
  - `plot_hydrograph()`
  - `plot_fdc()`
  - `hm_result()`
- documented exported metric wrappers other than the explicit compatibility and
  deprecated retained surfaces
- lowercase registry-backed canonical metric ids exposed through discovery

### Compatibility-only

The following remain compatibility-oriented retained exports:

- `HFB()`
- `NSeff()`
- `mNSeff()`
- `rNSeff()`
- `wsNSeff()`
- `mutual_information_score()`

Uppercase hydroGOF-style names such as `NSE`, `KGE`, `RMSE`, `R2`, `NRMSE`, and
`PBIAS` remain accepted as orchestration method labels through `gof()` /
`ggof()`, not as exported standalone functions.

### Deprecated but retained

The following remain intentionally retained transitional surfaces:

- exported deprecated forwarding wrappers:
  - `tail_dependence_score()`
  - `extended_valindex()`
- orchestration-only deprecated aliases:
  - `rPearson` / `rpearson`

These resolve to canonical current metric ids and are not treated as separate
discovery-canonical metrics.

### Explicitly deferred

The following are explicitly deferred beyond the current stabilization closure:

- any `ggof()` redesign beyond the current tabular contract
- export-surface redesign
- wrapper removal or lifecycle escalation beyond the current documented state
- formula changes
- discovery redesign
- broad test reorganization or renaming
- historical governance-file cleanup beyond active contract clarity
- general repo housekeeping not tied to current public-contract risk

## Version and NEWS Sanity

- `DESCRIPTION` version checked: yes
- `NEWS.md` top entry checked: yes
- Versioned README/package-facing references checked if touched: yes
- Notes:
  - `DESCRIPTION` continues to report version `0.4.0`.
  - `NEWS.md` remains consistent with the current `0.4.x` line framing.
  - README, governance docs, vignettes, and discovery-facing documentation now
    reflect the current public surface more accurately than the earlier
    baseline-establishment state.

## Public API and Behavior Summary

- Public API changed during the stabilization lane: no broad redesign
- Behavior changed during the stabilization lane: no formula redesign or
  exported-surface redesign
- What changed:
  - stale alias residue and contract ambiguity were removed or explicitly
    governed
  - package-facing documentation, governance language, discovery classification,
    and vignette naming were aligned to the current runtime surface
- Boundary statement:
  - the current validated candidate reflects a cleaner expression of the
    existing public contract rather than a new public API phase

## Validation Record

Record the exact commands actually used for the stabilized candidate state.

- `devtools::build_vignettes()`:
  - executed
  - Result: passed
- `devtools::test()`:
  - executed
  - Result: passed with `1290` passes and `1` expected source-tree skip
- `devtools::check(document = FALSE, error_on = "warning")`:
  - executed
  - Result: passed with `0 errors`, `0 warnings`, `0 notes`

## Cross-Environment / Preflight Notes

Record only what was actually checked.

| Environment | Check path | Result | Notes |
|---|---|---|---|
| Local Windows | `devtools::check(document = FALSE, error_on = "warning")` | pass | Executed successfully with `0 errors`, `0 warnings`, `0 notes` on the validated post-Batch-7 state. |
| Local Linux / WSL |  |  |  |
| Local macOS |  |  |  |
| CI release |  |  |  |
| CI oldrel |  |  |  |
| CI devel |  |  |  |

If an environment was not checked, leave it blank rather than inferring a
result.

## Discovery / Plotting / Governance Alignment

- Discovery docs align with `metric_search()` / `metric_preset()`: yes
- Plotting docs align with `plot_hydrograph()` / `plot_fdc()`: yes
- Governance/readiness docs align with current public surface: yes
- Vignette-facing contract aligns with current public surface: yes
- Notes:
  - top-level docs, governance docs, compatibility ledger language, vignettes,
    man pages, and tests now consistently describe the current stable /
    compatibility / deprecated / discovery split
  - `ggof()` remains documented and tested as tabular and non-plotting

## Optional Dependency Review

- `Suggests` behavior reviewed for examples/vignettes/helpers: yes
- Any suggested package now acting like a hard dependency: no
- Notes:
  - suggested packages continue to behave as optional rather than silent hard
    runtime dependencies
  - current validated package-facing behavior remains compatible with the
    documented optional-dependency model

## Source-Package Hygiene Review

- `.Rbuildignore` reviewed for repo-only artifacts: yes
- Packaged contents look intentional for the candidate cut: yes
- Notes:
  - repo-only governance and process documents remain excluded from the source
    tarball where intended
  - packaged vignette contents remain intentional for the current line
  - transient `.Rcheck` build detritus was removed during stabilization work and
    is not treated as part of the source baseline

## Known Gaps and Accepted Risks

- Remaining non-blocking gaps:
  - maintainer identity in `DESCRIPTION` still needs explicit confirmation
    before any serious CRAN-submission push
  - broader multi-environment release or CRAN-oriented preflight is not
    recorded here beyond the validated local path
  - long-term wrapper / compatibility strategy is still a future-phase topic,
    not part of this closure record
- Any explicitly accepted risk for this cut:
  - the current line is treated as baseline-closed and release-positioned
    without claiming CRAN submission readiness
- Any blocker that should stop this baseline closure:
  - none for the current stabilization-closure and release-positioning purpose

## Final Recommendation

- Recommendation:
  - proceed with baseline closure / release positioning
- Rationale:
  - Batch 5, Batch 6, and Batch 7 closed the meaningful low-risk stabilization
    lane
  - the live post-Batch-7 backlog triage found no actionable immediate cleanup
    batch remaining
  - `dev`, `origin/dev`, and `origin/main` are aligned at the reviewed commit,
    so no additional branch-sync work remains for promotion readiness
  - remaining items are explicitly defer-only rather than blockers

## Minimal Sign-Off Record

- Reviewer sign-off:
  - post-Batch-7 stabilization baseline closed from the current validated `dev`
    branch state
- Follow-up task(s), if any:
  - if release packaging is opened next, use this record as the stabilized
    baseline reference
  - if CRAN submission work is opened later, supplement this record with a
    submission-oriented preflight that includes confirmed maintainer identity
    metadata and broader environment evidence
