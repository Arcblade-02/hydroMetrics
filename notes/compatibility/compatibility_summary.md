# Phase 2 Compatibility Audit Summary

Evidence legend:
- `verified fact`: directly supported by generated runtime or repository evidence.
- `likely inference`: a constrained interpretation of the recorded evidence.
- `recommendation`: suggested next action, not a verified compatibility fact.

## Inventory Totals
- Public API objects inventoried: 17
- Wrapper-like objects audited: 16
- Wrappers with verified signatures: 16
- Wrappers with verified return structures: 16

## Compatibility Strengths
- Runtime exports audited: 17
- Vector-shape support cases succeeding: 14/16
- gof() representative deterministic runs: TRUE
- ggof() noninteractive device list unchanged: TRUE
- na.rm evidence recorded for selected wrappers/core entry points: 4

## Compatibility Blockers
- Dispatcher signatures use na_strategy/epsilon_mode naming instead of a fully hydroGOF-style surface.
- ggof() currently returns a hydro_metrics_batch data.frame, which is a plotting-contract divergence candidate.
- APFB remains indexed-input-only from the public surface.

## High-Priority Follow-up Actions
- Preserve the recorded signature and na.rm evidence before any compatibility-surface changes are attempted.
- Use the divergence register to scope wrapper-contract fixes without changing metric formulas or registry behavior.
- Treat ggof return semantics as a public API decision, not as an internal refactor detail.

## Unverified Areas
- No zoo-related unverified areas were created in this environment.

## Package-Level vs Environment-Level Uncertainty
- No environment-level uncertainty blocked the audited zoo/runtime compatibility cases.
