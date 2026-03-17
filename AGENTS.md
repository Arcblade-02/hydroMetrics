# AGENTS.md - hydroMetrics repository working rules

This file defines repo-specific working rules for AI/code agents operating in
`hydroMetrics`.

These rules are workflow requirements for this repository.

## 1. Project posture

`hydroMetrics` is a scientific R package intended as a serious, clean-room,
production-grade successor to `hydroGOF`.

Agents must optimize for:
- numerical correctness
- API stability
- conservative scope control
- CRAN-quality package discipline
- evidence-based validation
- maintainable incremental development

Do not treat this repository like a generic code sandbox.

## 2. Scope discipline

Prefer the smallest coherent change that solves the requested task.

Do not broaden scope just because adjacent improvements seem attractive.

If validation fails for a pre-existing unrelated reason:
- report it clearly
- do not expand the task into unrelated fixes

Do not combine multiple architectural, API, validation, or documentation
concerns into one change unless the task explicitly requires it.

## 3. Scientific and numerical rules

Do not change metric formulas unless explicitly asked.

Do not claim equivalence to `hydroGOF` or any external package without
evidence.

Where overlap metrics differ from `hydroGOF`, preserve current documented
policy unless an explicit task asks for reevaluation.

Treat NA/NaN/Inf handling, undefined-domain behavior, and warning/error
behavior as part of the public contract for stable functions.

Do not silently relax domain checks or replace explicit failures with silent
coercion.

## 4. API and compatibility rules

Respect current governance decisions in `DECISIONS.md`, especially:
- D-033 Plotting Dependency Strategy
- D-034 Public API Boundary
- D-035 Return Object Contract

Do not reinterpret uppercase hydroGOF-style names as exported functions unless
they are explicitly exported.

Treat uppercase names such as `NSE`, `KGE`, `RMSE`, `R2`, `PBIAS`, etc. as
orchestration labels unless the package explicitly exports them.

Do not change `ggof()` semantics casually. It is not a generic place to add
plotting behavior.

Do not add new exported helpers unless the task justifies a real public-surface
addition.

Any new exported helper must:
- solve a clear user problem
- have a modest API
- include docs/tests
- fit current package architecture

## 5. Plotting rules

Keep `ggplot2` optional in `Suggests` unless an explicit repo decision changes
that.

Plotting work must remain:
- static
- lightweight
- separate from `ggof()` semantics
- consistent with D-033

Do not add interactive plotting, Shiny/htmlwidgets layers, or heavy plotting
frameworks unless explicitly opened by project direction.

## 6. Dependency rules

Be conservative with dependencies.

Do not add new dependencies unless they are clearly justified by the task.

Prefer existing metadata, helpers, and package structure over introducing
parallel systems.

Optional dependencies must fail gracefully and be documented/tested
accordingly.

Repo-level documents and process artifacts should remain out of the source
package where appropriate.

## 7. Documentation rules

Keep package-facing docs truthful to the current exported surface.

When public behavior changes, update the relevant package-facing docs and tests
together:
- roxygen/man
- README if user-facing behavior is affected
- vignette examples if workflow expectations change
- validation/governance docs if policy or evidence changes

Do not leave aspirational documentation describing APIs that do not exist.

Keep CRAN-facing package metadata professional and conservative.

## 8. Testing and validation rules

Prefer narrow tests that protect behavior, contracts, and evidence claims.

Do not inflate confidence with repo/process-only tests inside the behavioral
runtime test path.

When changing public behavior or public docs, check whether tests should be
updated or added.

For validation tasks:
- classify results honestly as equivalent, intentionally divergent, partially
  validated, or not directly comparable
- do not force false equivalence
- keep validation artifacts coherent with tests

## 9. Release and readiness rules

Treat release framing separately from phase completion.

A release may mark a milestone inside a phase; it does not imply the phase is
complete unless explicitly stated.

Respect current repo-level readiness/process artifacts:
- `CRAN_READINESS.md`
- `RELEASE_REVIEW.md`
- `RELEASE_EVIDENCE_TEMPLATE.md`

Do not claim submission readiness or phase completion unless the evidence
clearly supports it.

## 10. Completion criteria for agent tasks

Before calling a task complete, ensure all of the following that apply are
handled:
- requested scope is completed
- diff stayed within scope
- package-facing docs are updated if needed
- tests are updated/added if needed
- validation commands requested by the task were run
- unresolved issues are reported honestly
- no unsupported claims are made about equivalence, readiness, or completion

When in doubt, prefer:
- smaller change
- clearer report
- more honest limitation
- less architectural churn
