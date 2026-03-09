# CI Consistency Review

- Generated: 2026-03-10 00:15:04 IST
- Workflow files discovered: `R-CMD-check.yml`
- Linux in matrix: `TRUE`
- Windows in matrix: `TRUE`
- macOS in matrix: `FALSE`
- Coverage workflow present: `FALSE`
- Vignettes intentionally skipped in CI: `TRUE`
- Current default-branch CI status: `unverified`

## Consistency findings

- Repository CI intentionally skips vignette build/check paths, so local vignette evidence is broader than CI coverage.
- No macOS runner was found in the checked-in workflow matrix.
- No dedicated coverage workflow is present on this branch.
- Remote workflow status note: DESCRIPTION has no URL field.
