# 0.4.x CRAN / Readiness Baseline and Transition Plan

This document defines the current narrow readiness baseline for the `0.4.x`
line. It is not a submission claim. It records what is already in good shape,
what remains non-blocking, and what still needs deliberate review before any
serious CRAN submission push.

## Current Readiness Level

- The current `0.4.x` line is a stabilized, release-positioned, locally
  validated baseline.
- The confirmed CRAN-facing maintainer record has now been applied in
  `DESCRIPTION`.
- On the current local evidence, the repo is ready to open a true submission
  campaign.

## Recommended Next Milestone

- The next milestone should be the `0.4.x` CRAN-oriented preparation phase.
- This is not a new stabilization batch.
- It is not a wrapper / compatibility strategy phase.
- It is not blind CRAN submission work.
- Within this phase, the next realistic operational milestone is a
  `0.4.x`-specific CRAN preflight campaign rather than an immediate submission
  attempt.

## Evidence Already Available

- `dev` and `main` are synchronized at the promoted finished baseline.
- The current `0.4.x` release evidence record already captures the stabilized
  baseline closure and release positioning.
- Green validated baseline evidence is already recorded for vignettes, tests,
  and package checks on the maintained local path.
- Governance, lifecycle, compatibility, and return-contract policy documents
  are already published and aligned.
- A lightweight `0.4.x` release review checklist already exists.
- Validation and benchmark artifacts for the current public package surface are
  already shipped.
- A current local `0.4.x` CRAN-style preflight has now been executed against
  the frozen baseline and completed cleanly.
- The maintainer metadata gate has now been resolved with the confirmed
  CRAN-facing maintainer record `Pritam <pritamparida432@gmail.com>`.

## Current Strengths

- The package builds and checks cleanly on the current `dev` branch with
  `0 errors`, `0 warnings`, and `0 notes` under the maintained local
  validation path.
- Public API governance is now explicit through [DECISIONS.md](DECISIONS.md),
  [GOVERNANCE.md](GOVERNANCE.md), and [CONTRIBUTING.md](CONTRIBUTING.md).
- Public API documentation, lifecycle policy, alias policy, and return-object
  contract are aligned to the shipped `0.4.0` package surface.
- Scientific reference metadata has been cleaned, placeholder citation text
  has been removed, and targeted reference checks are in place.
- Workstream B validation artifacts are materially stronger than the earlier
  baseline: hydroGOF-overlap classification is closed at the classification
  level, and the remaining validation/reference narrative is exercised and
  documented.
- A reproducible benchmark baseline exists for the current public orchestration
  paths, and it is clearly separated from broader exploratory performance
  tooling.
- Source-package hygiene is in good shape: repo-only material such as
  governance/process docs, tools, notes, and benchmark artifacts is excluded
  from the source tarball through [.Rbuildignore](.Rbuildignore).
- Optional plotting remains lightweight and dependency-conscious, with
  `ggplot2` kept in `Suggests` and no silent change to `ggof()`.

## Current Non-Blocking Gaps

- Workstream B is materially mature, but not all intentional-divergence cases
  have deeper empirical follow-up beyond classification-level closure.
- The current benchmark baseline is intentionally modest and should not be read
  as a full performance program or optimization guarantee.
- Contributor/governance publication is in place, and the `0.4.x`
  release-review/evidence process has now been exercised once, but broader
  submission-oriented operationalization remains outside the current baseline.
- The package has lightweight plotting helpers, but plotting scope remains
  deliberately narrow and does not yet attempt a broader visualization layer.

## Current Preparation-Phase Findings

The current `0.4.x` line remains frozen for CRAN-oriented preparation.

- No formula, runtime, export, or compatibility-policy blocker was identified
  on the current baseline.
- A current local CRAN-style preflight has now been completed cleanly after the
  confirmed maintainer-metadata update.
- No blocker remains on the local submission-campaign gate.

## Current 0.4.x CRAN-Style Preflight Result

- `devtools::build_vignettes()`: passed after the `DESCRIPTION` maintainer
  metadata update
- `devtools::test()`: passed with `1290` passes, `0` failures, `0` warnings,
  and `1` expected skip
- `devtools::check(document = FALSE, error_on = "warning")`: passed with
  `0 errors`, `0 warnings`, `0 notes`
- `devtools::check()` executed `R CMD check` with `--as-cran` on the current
  local Windows baseline
- The in-sandbox `build_vignettes()` attempt hit the known Windows
  `processx` pipe-permission limitation, so the preflight was rerun
  successfully outside the sandbox; this is treated as an environment
  restriction rather than a package defect

## Gap Classification

### Metadata / Prose Only

- Submission-facing prose should still receive one deliberate CRAN-tone review
  during the campaign, even though the current package-facing docs
  are already materially aligned.

### Evidence Generation Only

- Installed/shipped-content review should be recorded explicitly for the
  intended `0.4.x` cut rather than inferred only from prior stabilization
  checks.
- Broader multi-environment evidence should remain optional until a real
  submission campaign is opened, but it is not yet recorded for the current
  baseline.

### Genuine Blockers Before A Real Submission Campaign

- none on the current local baseline

## Likely Pre-Submission Review Areas

- Build on the existing `0.4.x` line-specific release evidence record with any
  future submission-oriented preflight, rather than relying only on older
  historical readiness notes.
- Review `DESCRIPTION`, package title/description wording, maintainer metadata,
  and package-facing prose for CRAN-facing tone and completeness.
- Review examples and vignette runtime/verbosity with CRAN constraints in mind,
  including optional-dependency behavior and any avoidable long-running paths.
- Review the current `Suggests` story for user clarity and submission hygiene,
  especially where optional packages control validation or plotting helpers.
- Reconfirm that shipped package contents remain intentional at `0.4.x`,
  including installed-file footprint and vignette/doc outputs.

## Dependency and Readiness Observations

- Core runtime dependencies remain narrow (`R6`, `stats`).
- Plotting, comparison-package validation, and indexed time-series support stay
  optional through `Suggests` (`ggplot2`, `hydroGOF`, `xts`, `zoo`).
- This is a good fit for the current package scope, but it means any CRAN
  readiness review should check examples, optional failure paths, and
  documentation clarity around suggested packages.

## Source-Package Hygiene Status

- Repo-only docs such as [CONTRIBUTING.md](CONTRIBUTING.md),
  [GOVERNANCE.md](GOVERNANCE.md), and this file are intentionally excluded from
  the source package.
- Development tooling under `tools/`, historical notes under `notes/`, and the
  benchmark working area under `inst/benchmarks/` are also excluded from the
  shipped source bundle.
- Current source-package hygiene should be treated as a strength, but still
  rechecked when the branch moves from milestone framing to real submission
  work.

## Governance and Process Baseline

- Decision-log discipline is established and current canonical decisions are
  separated from historical records.
- Contributor expectations for scope, validation, and policy discipline are now
  published.
- A lightweight maintainer-facing release-review checklist now exists in
  [RELEASE_REVIEW.md](RELEASE_REVIEW.md).
- Compatibility and lifecycle policy are explicit enough to support release
  review discussions without reopening basic API-boundary ambiguity.

## Not Yet Claimed

- This document now supports opening a true submission campaign from the
  current local baseline.
- It does not claim that the current `0.4.x` line has completed a broader
  submission-oriented multi-environment CRAN campaign beyond the recorded local
  preflight evidence.
- It does not claim pkgdown/site readiness, reverse-dependency assessment, or
  release-process automation completeness.
- It does not itself constitute publication approval or CRAN submission
  readiness for the `0.4.x` line.

## Remaining Next-Phase Work

- review `DESCRIPTION`, maintainer metadata, and package-facing prose for
  submission-facing tone and completeness
- review examples, vignettes, and optional-dependency behavior with CRAN
  runtime constraints in mind
- reconfirm shipped package contents and installed-file footprint for the
  intended `0.4.x` cut
- capture broader multi-environment evidence only if real submission work is
  actually opened

## Go / No-Go Conditions For The Next Phase

- `GO`: open the `0.4.x` CRAN-oriented preparation phase only if the current
  baseline remains frozen apart from submission-facing metadata, prose, and
  source-package/readiness hygiene work.
- `NO-GO`: do not treat this phase as the place to reopen stabilization,
  wrapper / compatibility redesign, formula changes, export changes, or broad
  feature development.

## Go / No-Go Conditions For A Real Submission Campaign

- `GO`: the current local baseline is ready to open a real submission campaign,
  with the branch kept otherwise frozen apart from submission-facing
  metadata/prose and packaging-hygiene adjustments.
- `NO-GO`: do not use the submission campaign to reopen finished stabilization
  work, wrapper-policy work, formula changes, export changes, or broad feature
  development.
