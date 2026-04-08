# Phase 2 History

This archival note consolidates the smaller Phase 2 closure fragments that were
previously spread across:

- `docs/phase2_validation_summary.md`
- `notes/phase2-closure/ci_matrix_evidence.md`
- `notes/phase2-closure/coverage_gap_summary.md`
- `notes/phase2-exit/naming_policy_freeze.md`
- `notes/phase2-exit/output_contract_review.md`
- `notes/phase2-exit/r2_nrmse_verification.md`
- `notes/finalize-phase2-baseline/cleanup_report.md`
- `notes/finalize-phase2-baseline/final_baseline_summary.md`
- `notes/finalize-phase2-baseline/final_release_validation.md`
- `notes/finalize-phase2-baseline/final_tag_verification.md`
- `notes/finalize-phase2-baseline/tag_release_report.md`
- `notes/release-v0.2.1/final_release_summary.md`
- `notes/release-v0.2.1/release_merge_report.md`
- `notes/release-v0.2.1/tag_and_push_report.md`
- `notes/release-v0.2.1/version_bump_report.md`
- `notes/performance/validation_record_v0.2.0_pretag.md`

The retained companion documents [docs/DEVIATION_REGISTER.md](../docs/DEVIATION_REGISTER.md),
[docs/PHASE2_EXIT_MEMO.md](../docs/PHASE2_EXIT_MEMO.md), and
[notes/finalize-phase2-baseline/merge_and_validation_report.md](finalize-phase2-baseline/merge_and_validation_report.md)
remain separate because they still serve as useful summary or detailed
historical anchors.

## 2026-03-09 to 2026-03-10: Phase 2 closure state

- Historical Phase 2 hardening was recorded as `GO` for the `0.2.0` release
  state, with the larger engineering evidence preserved on the branch
  `archive/phase2-validation-artifacts`.
- GitHub Actions evidence for the package-validation commit
  `2aa338caadd3306e48f76f1b2f81fe3b8b3615ac` showed a green Phase 2 matrix:
  Linux release, oldrel-1, and devel; Windows release; macOS release; and the
  coverage workflow.
- Coverage at the recorded closure point was `95.17%`, with the largest
  uncovered categories concentrated in NA handling, wrapper lines, and method
  dispatch rather than in core success paths.

## Contract freezes recorded at Phase 2 exit

- Public naming froze around the legacy hydroGOF-style compatibility exports:
  `NSE`, `KGE`, `MAE`, `RMSE`, `PBIAS`, `R2`, `NRMSE`, and the retained
  NSE-family aliases.
- Lowercase names that were already public in Phase 2 stayed public as retained
  compatibility exports: `alpha()`, `beta()`, `mae()`, `pbias()`, `r()`, and
  `rsr()`.
- `gof()` and the wrapper layer exited Phase 2 with the shipped S3/data-frame
  model rather than any earlier tibble-first plan.
- The recorded mathematical checks explicitly pinned two important contracts:
  `R2` is squared Pearson correlation and not interchangeable with `NSE` under
  bias, and `NRMSE` was frozen to the mean-normalized
  `sqrt(mean((sim - obs)^2)) / mean(obs)` form.

## 0.2.0 baseline finalization

- Only transient build artifacts were cleaned from the working tree:
  `*.tar.gz` bundles and `.Rcheck/` directories.
- A stale local `v0.2.0` tag was deleted only after verifying that the tag was
  absent on `origin`, then recreated as an annotated tag on the validated
  Phase 2 finalization commit.
- The recorded final `main` validation for the `0.2.0` baseline used commit
  `ce5cf29cf663f58e14a78c2c40e2e00a75a43a9b`, with `devtools::test()` passing
  at `PASS 915`, `R CMD build .` succeeding, and `R CMD check --no-manual`
  returning `Status: OK`.
- Historical check logs also recorded network index warnings and a `du`
  warning during the Windows run; those were environment-level observations in
  the historical report, not package failures.
- The Phase 2 baseline notes historically treated `0.2.0` as ready for Phase 3
  branching at that point in time.

## 0.2.1 corrective release superseding 0.2.0

- Phase 2's final corrected stable baseline moved to `0.2.1` after a
  fast-forward merge from `feature/complete-wrapper-export-contract`.
- The historical `0.2.1` record states that the corrected wrapper/export
  surface was retained and validated without reopening metric formulas.
- The recorded validation at that point was `PASS 983` for
  `devtools::test()`, plus clean `R CMD build .`,
  `R CMD check --no-manual hydroMetrics_0.2.1.tar.gz`, and
  `devtools::check(document = FALSE, manual = FALSE)` runs.
- The release notes and versioning surfaces were updated to `0.2.1`, and the
  annotated tag `v0.2.1` was created on commit
  `9664808f6d4fe03426b52d182c2f0dbb76087920`.
- The historical conclusion from these notes was that `v0.2.1`, not `v0.2.0`,
  should be treated as the true final Phase 2 stable release.

## Performance note preserved from the pre-tag record

- The archived `v0.2.0` pre-tag performance snapshot was generated with
  `Rscript tools/run_performance_suite.R`.
- Recorded medians were approximately `48.05 ns` for the direct `nse` path,
  `2079.2 ns` for single-series `gof()`, `2714.85 ns` for multi-series
  `gof()`, and `3989.8 ns` for the batch path.
- Large-vector and matrix-scaling checks were recorded as fast and roughly
  linear on that run, with zero reported memory delta and a load time near
  `0.05 s`.
