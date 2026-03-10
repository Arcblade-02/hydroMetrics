# Non-Broken Environment Report

- Generated: `2026-03-10 10:37:51 +05:30`
- Current branch at verification time: `feature/final-cran-evidence-confirmation`
- Baseline branch: `main`
- HEAD commit SHA at verification time: `680476fe92335255d2183fb7965db4ea8a05c7ad`
- Package version: `0.2.0`
- Baseline version: `0.2.0`
- Intended 0.2.x release baseline: `YES`
- Baseline verification result: `PASS`
- Stabilized Phase 2 state present: `YES`
- Environment classification: `non-broken`
- Environment rationale: `The sandboxed Windows workspace had previously reproduced the known processx/callr pipe-permission failure, but the same host executed both devtools::check() and devtools::check(cran = TRUE) successfully outside the sandbox on 2026-03-10. The package evidence therefore supports a sandbox-specific environment issue rather than a package defect.`
- OS: `Windows 11 x64 (build 26200)`
- R version: `R version 4.5.2 (2025-10-31 ucrt)`
- devtools version: `2.4.6`
- callr version: `3.7.6`
- processx version: `3.8.6`
- Installation method: `Local Windows host installation at C:\Program Files\R\R-4.5.2 with preinstalled devtools/callr/processx packages; checks executed from an unrestricted shell outside the Codex sandbox.`

## Baseline inspection

- `DESCRIPTION`: version remains `0.2.0` with the current MIT clean-room release metadata.
- `README.md`: still describes the `0.2.0` release-hardening line and exported surface.
- `NEWS.md`: still records the `0.2.0` release-hardening changes.
- `vignettes/`: contains the stabilized `getting-started.Rmd` vignette used for package-level checks.
- `.github/workflows/`: still contains `R-CMD-check.yml` and `coverage.yml`, covering the expected default-branch matrix and coverage workflow.
- Overall baseline decision: the branch was created directly from `main` at commit `680476fe92335255d2183fb7965db4ea8a05c7ad`, and that commit is the intended `0.2.0` release baseline.

## sessionInfo()

```text
devtools=2.4.6
callr=3.7.6
processx=3.8.6
R version 4.5.2 (2025-10-31 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 11 x64 (build 26200)

Matrix products: default
  LAPACK version 3.12.1

locale:
[1] LC_COLLATE=English_India.utf8  LC_CTYPE=English_India.utf8
[3] LC_MONETARY=English_India.utf8 LC_NUMERIC=C
[5] LC_TIME=English_India.utf8

time zone: Asia/Calcutta
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
[1] devtools_2.4.6 usethis_3.2.1

loaded via a namespace (and not attached):
 [1] R6_2.6.1          fastmap_1.2.0     magrittr_2.0.4    remotes_2.5.0
 [5] cachem_1.1.0      glue_1.8.0        memoise_2.0.1     lifecycle_1.0.5
 [9] cli_3.6.5         sessioninfo_1.2.3 vctrs_0.7.1       pkgload_1.5.0
[13] compiler_4.5.2    tools_4.5.2       purrr_1.2.1       pkgbuild_1.4.8
[17] ellipsis_0.3.2    rlang_1.1.7       fs_1.6.6
Loading required package: usethis
```
