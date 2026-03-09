# Phase 2 CI Repair Log

## DESCRIPTION

- Added `markdown` to `Suggests` to satisfy vignette build dependencies in CI.
- Verified `Suggests` retains `knitr` and `rmarkdown`.
- Verified `VignetteBuilder`: `knitr`.

## Workflow

- Updated `.github/workflows/R-CMD-check.yml`.
- Replaced unsupported `check_args` with supported `args` for `r-lib/actions/check-r-package@v2`.
- Preserved the Linux, Windows, and macOS matrix entries already present in the workflow.

