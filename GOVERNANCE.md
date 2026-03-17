# Governance Baseline

This document publishes the current contributor-facing governance baseline for
the Phase 4 package line. It summarizes already accepted project decisions
without replacing the authoritative decision log in [DECISIONS.md](DECISIONS.md).

## API Stability Policy

The package is still pre-1.0, but the current documented public surface should
be treated as intentionally stable unless a change is explicitly framed as a
deprecation, compatibility correction, or experimental addition.

Current stable boundary:

- exported orchestration entry points such as `gof()`, `ggof()`, `preproc()`,
  and `valindex()`
- documented exported helpers such as `metric_search()`,
  `metric_preset()`, `plot_hydrograph()`, `plot_fdc()`, and `hm_result()`
- documented exported metric wrappers other than the explicitly marked
  compatibility exports

Contract stability includes more than signatures. It also includes:

- return type and output shape
- documented names, schema, and class structure
- documented warning and error behavior
- documented edge-case handling that determines whether users receive a value,
  `NA`, warning, or error

Internal registries, engine internals, helper functions, and
implementation-location details are not part of the public API unless they are
explicitly promoted later.

## Compatibility Policy

Compatibility interfaces may remain public when they serve continuity,
transition support, or clear usability value, but they must not create
duplicate canonical registry entries.

Current compatibility policy:

- uppercase hydroGOF-style names accepted by `gof()` / `ggof()` are
  orchestration labels, not exported standalone functions
- documented compatibility exports keep a canonical target
- deprecated aliases may continue to resolve, but they should not silently
  become new canonical ids
- intentional divergence from reference packages should be documented as
  intentional, not described as unresolved compatibility

Compatibility work should prefer thin wrappers or resolution aliases over
parallel live implementations.

## Lifecycle Policy

Every documented exported interface should have an understood lifecycle status.
The package currently uses four statuses:

- `stable`
- `compatibility`
- `deprecated`
- `experimental`

Current baseline interpretation:

- `stable`: documented exported functions other than the explicit compatibility
  exports and any future explicitly marked deprecated or experimental surface
- `compatibility`: retained historical or interoperability-oriented exports
  such as `NSeff()`, `mNSeff()`, `rNSeff()`, `wsNSeff()`, `APFB()`, `HFB()`,
  `mutual_information_score()`, and `kl_divergence_flow()`
- `deprecated`: no exported functions are currently published in this status
- `experimental`: no exported functions are currently published in this status

If a new exported function is added, its lifecycle status should be stated
clearly in the package-facing docs rather than left implicit.

## Plotting Scope Policy

Phase 4 plotting follows the accepted lightweight strategy:

- `ggplot2` remains in `Suggests`
- plotting may stay in the main package only while it remains lightweight and
  static
- interactive dashboards, htmlwidgets/Shiny layers, and broad reporting
  frameworks are out of scope for this phase
- `ggof()` keeps its current non-plotting tabular behavior unless a later
  deliberate contract change says otherwise

## Scientific and Package-Integrity Expectations

- New metrics and research-frontier additions require literature support in
  [inst/REFERENCES.md](inst/REFERENCES.md) before they are treated as
  release-ready.
- Placeholder references are not acceptable in public metadata.
- Public API documentation, validation artifacts, and package metadata must
  remain aligned with the actual exported package state.
- Narrow validation and regression evidence should accompany package-boundary
  changes.

## Source of Truth

Use this file as the published summary. Use [DECISIONS.md](DECISIONS.md) as the
authoritative governance record when there is any ambiguity.
