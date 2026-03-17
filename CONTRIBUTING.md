# Contributing to hydroMetrics

`hydroMetrics` has completed its intended Phase 4 baseline-establishment work.
Contributions should preserve package-boundary discipline, scientific
traceability, and small-scope reviewability.

## Working Branch and Change Scope

- Work on the current development branch unless a maintainer asks for a
  different branch workflow.
- Keep diffs narrow. Avoid mixing feature work, documentation cleanup, and
  unrelated refactors in one change.
- Do not change metric formulas, exports, or public return behavior unless the
  task is explicitly scoped to that work.
- Prefer updating documentation to match the shipped package state rather than
  changing code to satisfy stale documentation.

## Package-Boundary Discipline

- Treat documented exported functions and documented public contracts as the
  public package boundary.
- Do not expose internal helpers, registry internals, or implementation
  locations as public API by accident.
- Do not silently change `ggof()` semantics; its current contract is tabular
  and non-plotting.
- Keep optional plotting and similar convenience work lightweight and
  dependency-conscious.

## Decision-Log Discipline

- Check [DECISIONS.md](DECISIONS.md) before changing public behavior, adding
  helpers, or revising package-facing policy.
- Add a new decision record only when the project is making a real governance
  commitment that is not already covered by an accepted decision.
- Do not reuse historical or superseded decision IDs.
- If earlier governance text is stale, mark it historical or superseded rather
  than deleting traceability.

## Metrics, References, and Validation

- New metrics or materially new metric variants need literature grounding in
  [inst/REFERENCES.md](inst/REFERENCES.md) before they are treated as
  release-ready.
- Compatibility behavior that is intentionally package-defined must be stated
  explicitly and validated accordingly.
- Do not add placeholder citation text.
- Metric additions or behavior changes should come with focused validation
  evidence and appropriately scoped regression tests.

## Testing and Checks

Run the smallest relevant validation set for the change, and use the full
package check when the scope touches public behavior, exports, documentation,
or packaged artifacts.

Typical expectations:

- `devtools::document()`
- `devtools::load_all('.')`
- focused `devtools::test(filter = ...)`
- `devtools::check(document = FALSE, error_on = "warning")` for public-facing
  changes

If a validation command fails for a clearly unrelated pre-existing reason,
report it explicitly rather than broadening scope.

## Documentation and Metadata

- Keep README, NEWS, vignettes, help pages, and validation artifacts truthful
  to the current exported package state.
- Keep version references current when a file is touched for release-facing
  reasons.
- Repo-only evidence and process files should not be treated as package runtime
  tests unless they are intentionally packaged as validation artifacts.

## Pull Request Expectations

- State the exact scope of the change.
- Summarize whether public API changed, whether behavior changed, and which
  validations were run.
- Call out unresolved questions instead of hiding them in opportunistic
  cleanup.
