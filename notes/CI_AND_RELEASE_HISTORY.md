# CI And Release History

This archival note consolidates the smaller CI, release-readiness, and
pre-Phase-3 evidence fragments that were previously spread across:

- `notes/ci-repair/ci_repair_log.md`
- `notes/ci-repair/final_ci_repair_summary.md`
- `notes/release-readiness/baseline_verification.md`
- `notes/release-readiness/ci_consistency_review.md`
- `notes/release-readiness/clean_install_report.md`
- `notes/release-readiness/coverage_review.md`
- `notes/release-readiness/cran_preflight_report.md`
- `notes/release-readiness/documentation_review.md`
- `notes/release-readiness/math_contract_report.md`
- `notes/release-readiness/public_api_runtime_results.md`
- `notes/final-cran-evidence/final_cran_evidence_summary.md`
- `notes/final-cran-evidence/live_ci_status_report.md`
- `notes/final-cran-evidence/nonbroken_environment_report.md`
- `notes/pre-phase3-cran-readiness/cran_preflight_report.md`

The associated raw `.txt` and `.csv` artifacts remain in place in their
original directories.

## Early release-readiness stop condition

- One historical `release-readiness` pass inspected `main` at commit
  `a45aec62923e6bfccadaff5f6fbd47b60eb03cec` and found `Version: 0.1.0`,
  not the intended Phase 2 stabilized `0.2.x` baseline.
- That pass therefore recorded a `FAIL` baseline verification and explicitly
  stopped short of rerunning the full readiness pipeline on the wrong source
  state.

## Phase 2 CI repair lane

- The CI repair batch recorded two concrete fixes:
  `markdown` was added to `Suggests` for vignette builds, and
  `.github/workflows/R-CMD-check.yml` switched from unsupported `check_args`
  to supported `args` for `r-lib/actions/check-r-package@v2`.
- Historical validation for that lane recorded local `PASS 600`,
  clean build/check status, and readiness for CI rerun.

## Release-readiness review of the 0.2.0 snapshot

- The clean-install report showed a fresh-session install/load succeeding after
  a Windows `processx` pipe-permission failure in `devtools::install()`,
  using `R CMD INSTALL` as the documented fallback.
- The documentation review found exported function help coverage present and
  noted that hydroGOF differences were not yet surfaced clearly enough in
  package-level user documentation on that examined branch.
- The mathematical contract report pinned the expected runtime behavior for
  `R2`, `NRMSE`, `NSE`, `KGE`, and `PBIAS`, and observed that `br2` was present
  in the internal registry.
- The public API runtime probe captured a historically important mismatch:
  on that snapshot, only `gof`, `ggof`, and `hm_result` were observed as clean
  session exports, which drove the initial `NO-GO` recommendation in the
  corresponding preflight report.

## Final pre-Phase-3 evidence closure on the corrected baseline

- The later non-broken environment report documented an unrestricted Windows
  shell outside the Codex sandbox on the `0.2.0` baseline at commit
  `680476fe92335255d2183fb7965db4ea8a05c7ad`.
- In that environment, both `devtools::check()` and
  `devtools::check(cran = TRUE)` were recorded as passing with
  `0 errors, 0 warnings, 0 notes`, closing the earlier processx/callr
  uncertainty as an environment-specific issue rather than a package defect.
- The live CI status report verified `6/6` required default-branch nodes green
  on the same commit: Linux release, oldrel-1, and devel; Windows release;
  macOS release; and coverage.
- The final synthesis note therefore moved the historical recommendation from a
  conditional state to a plain `GO`.

## Historical conclusions preserved here

- The smaller release-readiness fragments collectively show a progression from
  baseline mismatch, to partial readiness with environment caveats, to direct
  evidence closure on the intended branch state.
- They also document the project's repeated use of conservative staging:
  failing fast on the wrong baseline, separating environment defects from
  package defects, and not promoting a `GO` recommendation until clean local
  and CI evidence aligned.
