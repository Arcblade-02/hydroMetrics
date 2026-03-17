# 0.4.x CRAN / Readiness Baseline

This document defines the current narrow readiness baseline for the `0.4.x`
line. It is not a submission claim. It records what is already in good shape,
what remains non-blocking, and what still needs deliberate review before any
serious CRAN submission push.

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
  level, and the CRPS external reference path is exercised and documented.
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
  optional through `Suggests` (`ggplot2`, `hydroGOF`, `scoringRules`, `xts`,
  `zoo`).
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

- This document does not claim current CRAN submission readiness.
- It does not claim that the current `0.4.x` line has completed a broader
  submission-oriented multi-environment CRAN campaign beyond the recorded local
  preflight evidence.
- It does not claim pkgdown/site readiness, reverse-dependency assessment, or
  release-process automation completeness.
- It does not itself constitute publication approval or CRAN submission
  readiness for the `0.4.x` line.

## Next Logical Readiness Step

The next narrow readiness step should be a `0.4.x`-specific CRAN preflight
pass: rerun a deliberate CRAN-style check workflow against the current branch,
review submission-facing metadata and prose, use
[RELEASE_REVIEW.md](RELEASE_REVIEW.md) as the maintainer checklist, and record
any remaining submission blockers explicitly.
