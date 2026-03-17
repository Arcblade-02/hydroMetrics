# 0.4.x Release Evidence Template

Use this template after completing [RELEASE_REVIEW.md](RELEASE_REVIEW.md) for a
specific `0.4.x` release candidate, milestone cut, or tag candidate.

This is a maintainer-facing record template. It is not an automation layer and
it does not imply CRAN submission readiness by itself.

## Release Candidate Summary

- Intended version:
- Release type:
  - patch / minor line maintenance / milestone framing / other
- Branch:
- Commit SHA:
- Review date:
- Reviewer:

## Release Framing

- Intended public framing:
- What this cut explicitly claims:
- What this cut explicitly does **not** claim:

## Version and NEWS Sanity

- `DESCRIPTION` version checked: yes / no
- `NEWS.md` top entry checked: yes / no
- Versioned README/package-facing references checked if touched: yes / no
- Notes:

## Public API and Behavior Summary

- Public API changed: yes / no
- Behavior changed: yes / no
- If yes, summarize exactly:
- If no, confirm the cut is docs/process-only or non-boundary-safe:

## Validation Record

Record the exact commands actually used for the candidate state.

- `devtools::document()`:
- `devtools::load_all('.')`:
- Focused `devtools::test(filter = ...)`:
- Full `devtools::check(document = FALSE, error_on = "warning")`:
- Any separate `--as-cran` or CRAN-style preflight:

## Cross-Environment / Preflight Notes

Record only what was actually checked.

| Environment | Check path | Result | Notes |
|---|---|---|---|
| Local Windows |  |  |  |
| Local Linux / WSL |  |  |  |
| Local macOS |  |  |  |
| CI release |  |  |  |
| CI oldrel |  |  |  |
| CI devel |  |  |  |

If an environment was not checked, leave it blank rather than inferring a
result.

## Validation / Benchmark Artifact Review

- `inst/validation/` reviewed for current-state truthfulness: yes / no
- `inst/benchmarks/` reviewed for current baseline vs historical labeling:
  yes / no
- Notes:

## Discovery / Plotting / Governance Alignment

- Discovery docs align with `metric_search()` / `metric_preset()`: yes / no
- Plotting docs align with `plot_hydrograph()` / `plot_fdc()`: yes / no
- Governance/readiness docs align with current public surface: yes / no
- Notes:

## Optional Dependency Review

- `Suggests` behavior reviewed for examples/vignettes/helpers: yes / no
- Any suggested package now acting like a hard dependency: yes / no
- Notes:

## Source-Package Hygiene Review

- `.Rbuildignore` reviewed for repo-only artifacts: yes / no
- Packaged contents look intentional for the candidate cut: yes / no
- Notes:

## Known Gaps and Accepted Risks

- Remaining non-blocking gaps:
- Any explicitly accepted risk for this cut:
- Any blocker that should stop the cut:

## Final Recommendation

- Recommendation:
  - proceed / proceed with caveats / do not cut yet
- Rationale:

## Minimal Sign-Off Record

- Reviewer sign-off:
- Follow-up task(s), if any:
