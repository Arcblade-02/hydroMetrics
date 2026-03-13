# CRAN Preflight Report

- Generated: `2026-03-10 10:37:51 +05:30`
- Source package version: `0.2.0`
- Final recommendation: `GO`

## Stage summary

- `clean install/load`: `PASS` - Fresh-session load succeeded from a clean temporary library after a documented devtools::install fallback.
- `public API wrapper verification`: `PASS` - All promised wrappers are exported and callable from a clean installed session.
- `tests`: `PASS` - `devtools::test()` is the authoritative harness here; `testthat::test_dir()` fails outside that harness because tests expect package-loading context.
- `coverage`: `PASS` - Overall coverage is 95.17% with strong exercised paths through wrappers and preprocessing.
- `vignette build`: `PASS` - Vignettes build cleanly and demonstrate exported package usage.
- `documentation regeneration`: `PASS` - Documentation is present, regenerated cleanly, and covers exported functions.
- `behavioral correctness matrix`: `PASS` - Exported wrappers and preprocessing behave deterministically across the required edge-case matrix.
- `mathematical contract verification`: `PASS` - Core metric behavior is numerically pinned to explicit Phase 2 contracts.
- `checks`: `PASS` - `devtools::check()` and `devtools::check(cran = TRUE)` both completed on a non-broken environment with 0 ERRORs, 0 WARNINGs, and 0 NOTEs.
- `CI cross-check`: `PASS` - The latest default-branch `R-CMD-check` matrix and `Coverage` workflow are green on commit `680476fe92335255d2183fb7965db4ea8a05c7ad`.

## Final evidence closure

- Non-broken environment evidence: `notes/final-cran-evidence/nonbroken_environment_report.md`
- `devtools::check()` evidence: `notes/final-cran-evidence/devtools_check_results.txt`
- `devtools::check(cran = TRUE)` evidence: `notes/final-cran-evidence/devtools_check_cran_results.txt`
- Live CI evidence: `notes/final-cran-evidence/live_ci_status_report.md`
- Final synthesis: `notes/final-cran-evidence/final_cran_evidence_summary.md`
