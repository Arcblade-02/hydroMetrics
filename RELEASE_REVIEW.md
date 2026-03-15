# 0.4.x Release Review Checklist

This checklist is the lightweight release-review baseline for the current
`0.4.x` line. It operationalizes the current governance and readiness baseline
without claiming release automation or CRAN submission readiness.

Use it before cutting a release commit, release tag, or milestone-framing
snapshot from `dev`.

## Scope

- This is a maintainer review checklist, not an automated pipeline.
- It is intended for the current `0.4.x` line only.
- It does not replace [DECISIONS.md](DECISIONS.md),
  [GOVERNANCE.md](GOVERNANCE.md), or [CRAN_READINESS.md](CRAN_READINESS.md).
- It does not claim that a checked item means CRAN submission is ready.

## 1. Version and Release Framing

- [ ] `DESCRIPTION` version matches the intended release or milestone cut.
- [ ] `NEWS.md` has a truthful top entry for the intended release line.
- [ ] The release framing is honest about what is and is not being claimed.
- [ ] If the cut is still part of the Phase 4 line, the wording does not imply
      that all remaining Phase 4 work is complete unless that is actually true.

## 2. Public API and Documentation Parity

- [ ] `README.md` reflects the current exported public surface.
- [ ] Help pages and vignettes still match the shipped API and current helper
      set.
- [ ] Stable, compatibility, deprecated, and experimental lifecycle language is
      still truthful.
- [ ] No new public helper, alias, or plotting change has bypassed the current
      governance rules in [DECISIONS.md](DECISIONS.md) and
      [GOVERNANCE.md](GOVERNANCE.md).

## 3. Validation and Benchmark Artifact Sanity

- [ ] `inst/validation/` still tells a truthful current-state story for the
      release line.
- [ ] Any validation evidence referenced in package-facing docs still exists
      and still matches current behavior.
- [ ] The benchmark baseline under `inst/benchmarks/` is still correctly
      labeled as current baseline versus historical material.
- [ ] No benchmark or validation artifact is being overstated as a guarantee it
      does not actually support.

## 4. Discovery, Plotting, and Governance Alignment

- [ ] Discovery docs remain aligned with `metric_search()` and
      `metric_preset()`.
- [ ] Plotting docs remain aligned with `plot_hydrograph()` and `plot_fdc()`.
- [ ] `ggof()` is still described as tabular and non-plotting.
- [ ] Contributor/governance docs remain aligned with the current stable helper
      surface and public-boundary policy.

## 5. Check and Preflight Expectations

- [ ] `devtools::document()` completes cleanly.
- [ ] `devtools::load_all('.')` completes cleanly.
- [ ] The smallest relevant focused `devtools::test(filter = ...)` set has been
      run for the scoped release changes.
- [ ] `devtools::check(document = FALSE, error_on = "warning")` completes
      cleanly for the release candidate state.
- [ ] If a deliberate CRAN-style preflight is part of the cut, record whether
      the result came from `devtools::check()` with `--as-cran`, another
      CRAN-like path, or both.

## 6. Source-Package Hygiene

- [ ] Repo-only governance/process documents remain excluded from the source
      tarball through `.Rbuildignore`.
- [ ] Repo-only tooling and historical notes are not being pulled into the
      package unintentionally.
- [ ] Packaged vignettes, validation artifacts, and other installed material
      still look intentional for the current release line.

## 7. Optional Dependency Review

- [ ] `Suggests` entries still match real optional behavior in examples,
      vignettes, validation paths, and plotting helpers.
- [ ] Optional dependency failure paths remain clear and non-silent.
- [ ] No recent change has effectively turned a suggested package into an
      undeclared hard runtime dependency.

## 8. Release Honesty Check

- [ ] The release notes do not overstate validation maturity, plotting scope,
      or readiness state.
- [ ] The package is not being described as CRAN-ready or submission-ready
      unless a separate submission-oriented review explicitly supports that
      claim.
- [ ] Any remaining known gaps are recorded as gaps rather than hidden behind
      milestone language.

## 9. Minimal Release Record

Before cutting the release or milestone tag, record at least:

- intended version
- branch and commit SHA
- validations run
- whether public API changed
- whether behavior changed
- any explicitly accepted remaining gaps

This record can live in the pull request, release notes, or a short maintainer
note. Use [RELEASE_EVIDENCE_TEMPLATE.md](RELEASE_EVIDENCE_TEMPLATE.md) if you
want a consistent repo-level record. It does not require a new automation
layer.
