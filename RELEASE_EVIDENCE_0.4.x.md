# 0.4.x Release Evidence Record

This record completes the current `0.4.x` release-evidence baseline using the
maintainer-facing template in [RELEASE_EVIDENCE_TEMPLATE.md](RELEASE_EVIDENCE_TEMPLATE.md).

It records the evaluated candidate branch state. It is not, by itself, a CRAN
submission approval.

## Release Candidate Summary

- Intended version: `0.4.0` on the current `0.4.x` line
- Release type:
  - milestone framing / line-baseline evidence record
- Branch: `dev`
- Commit SHA: `62869838de3b516f82bacd47b0b95601b9e57912`
- Review date: `2026-03-15`
- Reviewer: `Codex-assisted maintainer review record`

## Release Framing

- Intended public framing:
  - The current `0.4.x` line is a Phase 4 baseline-establishment and
    disciplined post-baseline maintenance line.
- What this cut explicitly claims:
  - Workstream A is closed.
  - Workstream B is materially mature for the phase.
  - Workstreams C and D have materially mature lightweight baselines.
  - Workstream E now has an operational review/evidence posture rather than
    only baseline governance notes.
- What this cut explicitly does **not** claim:
  - CRAN submission readiness
  - pkgdown/site readiness
  - reverse-dependency review completion
  - that every possible post-Phase-4 refinement is complete

## Version and NEWS Sanity

- `DESCRIPTION` version checked: yes
- `NEWS.md` top entry checked: yes
- Versioned README/package-facing references checked if touched: yes
- Notes:
  - `DESCRIPTION` reports version `0.4.0`.
  - `NEWS.md` frames `0.4.0` as a Phase 4 baseline-establishment milestone,
    not as Phase 4 completion.
  - Current README install examples and helper references are aligned to the
    `0.4.0` line and current helper surface.

## Public API and Behavior Summary

- Public API changed: no
- Behavior changed: no
- If yes, summarize exactly:
  - Not applicable.
- If no, confirm the cut is docs/process-only or non-boundary-safe:
  - The evaluated candidate state reflects the current documented public API
    and behavior without a new API or runtime change in this evidence step.

## Validation Record

Record the exact commands actually used for the candidate state.

- `devtools::document()`:
  - `Rscript -e "options(repos=c(CRAN='https://cloud.r-project.org')); devtools::document()"`
  - Result: passed
- `devtools::load_all('.')`:
  - `Rscript -e "options(repos=c(CRAN='https://cloud.r-project.org')); devtools::load_all('.'); cat('load_all_ok\n')"`
  - Result: passed
- Focused `devtools::test(filter = ...)`:
  - `Rscript -e "options(repos=c(CRAN='https://cloud.r-project.org')); devtools::test(filter='api|validation|benchmark|metric_search|preset|plot|governance|gof|preproc|structural')"`
  - Result: passed with `698` passes and `1` expected source-tree skip
- Full `devtools::check(document = FALSE, error_on = "warning")`:
  - `Rscript -e "options(repos=c(CRAN='https://cloud.r-project.org')); devtools::check(document = FALSE, error_on='warning')"`
  - Result: passed with `0 errors`, `0 warnings`, `0 notes`
- Any separate `--as-cran` or CRAN-style preflight:
  - No separate additional path in this evidence record.
  - The recorded `devtools::check()` run executed with `--no-manual --as-cran`
    in the validated environment.

## Cross-Environment / Preflight Notes

Record only what was actually checked.

| Environment | Check path | Result | Notes |
|---|---|---|---|
| Local Windows | `devtools::check(document = FALSE, error_on = "warning")` | pass | Executed with `--as-cran`; initial in-sandbox wrapper attempt hit the known Windows pipe restriction, then passed outside the sandbox. |
| Local Linux / WSL |  |  |  |
| Local macOS |  |  |  |
| CI release |  |  |  |
| CI oldrel |  |  |  |
| CI devel |  |  |  |

If an environment was not checked, leave it blank rather than inferring a
result.

## Validation / Benchmark Artifact Review

- `inst/validation/` reviewed for current-state truthfulness: yes
- `inst/benchmarks/` reviewed for current baseline vs historical labeling:
  yes
- Notes:
  - Validation inventory and summary are coherent with the current hydroGOF
    overlap classifications and the exercised CRPS reference path.
  - The benchmark area distinguishes the active Workstream B baseline from the
    older historical Phase 2 material.

## Discovery / Plotting / Governance Alignment

- Discovery docs align with `metric_search()` / `metric_preset()`: yes
- Plotting docs align with `plot_hydrograph()` / `plot_fdc()`: yes
- Governance/readiness docs align with current public surface: yes
- Notes:
  - `README.md`, `DECISIONS.md`, and `GOVERNANCE.md` reflect the current stable
    helper surface on the `0.4.x` line.
  - `ggof()` remains documented as tabular and non-plotting.

## Optional Dependency Review

- `Suggests` behavior reviewed for examples/vignettes/helpers: yes
- Any suggested package now acting like a hard dependency: no
- Notes:
  - `ggplot2`, `hydroGOF`, `scoringRules`, `xts`, and `zoo` remain optional.
  - Current helper and validation paths document graceful optional-dependency
    behavior rather than treating suggested packages as silent hard runtime
    requirements.

## Source-Package Hygiene Review

- `.Rbuildignore` reviewed for repo-only artifacts: yes
- Packaged contents look intentional for the candidate cut: yes
- Notes:
  - Repo-only governance, readiness, agent, and release-process documents
    remain excluded from the source tarball.
  - Packaged vignettes and `inst/validation/` contents remain intentional for
    the current line.

## Known Gaps and Accepted Risks

- Remaining non-blocking gaps:
  - Maintainer identity in `DESCRIPTION` still uses a handle-style display
    name and would need explicit confirmation before serious CRAN submission
    work.
  - No broader multi-environment `0.4.x` submission-oriented preflight is
    recorded in this evidence file beyond the local Windows `--as-cran` path.
  - Workstream B intentional-divergence cases are classified and documented,
    but not all have deeper empirical follow-up beyond classification-level
    closure.
- Any explicitly accepted risk for this cut:
  - The line is treated as operationally reviewable and phase-closeable
    without claiming CRAN submission readiness.
- Any blocker that should stop the cut:
  - None for a `0.4.x` line evidence baseline or milestone-maintenance cut.
  - Maintainer identity remains a blocker only for a serious CRAN submission
    attempt, not for this evidence record.

## Final Recommendation

- Recommendation:
  - proceed with caveats
- Rationale:
  - The current `0.4.x` branch state is strong enough to support a committed
    release-evidence baseline and Phase 4 closure review.
  - The remaining gaps are submission-oriented or optional follow-up items
    rather than blockers to the current phase-close baseline.

## Minimal Sign-Off Record

- Reviewer sign-off:
  - `0.4.x` release evidence baseline recorded from current validated `dev`
    branch state.
- Follow-up task(s), if any:
  - If CRAN submission work is opened later, replace or supplement this record
    with a submission-oriented preflight record that includes confirmed
    maintainer identity metadata and broader environment evidence.
