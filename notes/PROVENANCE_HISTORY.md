# Provenance History

This archival note consolidates the smaller provenance-hardening batch notes
that were previously spread across:

- `notes/provenance-remediation-batch-2026-04-03.md`
- `notes/provenance-hardening-closure-2026-04-04.md`

The current live-audit data file `notes/provenance_audit_current.csv` remains
in place as the raw companion artifact.

## 2026-04-03: bounded provenance remediation batch

- The first batch focused on nine metrics identified in the then-current audit:
  `br2`, `pbias`, `mnse`, `nrmse`, `pfactor`, `rfactor`, `hfb`,
  `low_flow_bias`, and `mutual_information_score`.
- Historical notes record changes across registry metadata, references,
  discovery wording, wrapper/help wording, vignettes, and provenance-sensitive
  regression tests.
- The batch tightened wording so the package no longer overstated literature
  equivalence for the targeted metrics.
- It explicitly preserved the retained `pbias` sign convention,
  `nrmse = RMSE / mean(obs)`, and the package-defined status of `pfactor`,
  `rfactor`, `hfb`, and `low_flow_bias`.
- It also clarified that `mutual_information` is the canonical discovery id and
  that `mutual_information_score` is only a retained compatibility duplicate.

## 2026-04-03: explicit deferrals

- No runtime or formula change to `br2`.
- No runtime or formula change to `pbias`.
- No reinterpretation of `pfactor` or `rfactor` as uncertainty-band metrics.
- No promotion of `hfb` or `low_flow_bias` to literature-exact diagnostics
  without stronger formula support.
- No alias-lifecycle escalation or export removal for
  `mutual_information_score`.

## 2026-04-03: recorded validation

- `devtools::build_vignettes()`: passed
- `devtools::test()`: passed with `1300 PASS`, `0 FAIL`, `0 WARN`, `1 SKIP`
- `devtools::check(document = FALSE, error_on = "warning")`: passed with
  `0 errors`, `0 warnings`, `0 notes`

## 2026-04-04: final low-risk provenance closure

- The follow-on micro-batch resolved the remaining intentionally deferred,
  low-risk provenance wording items for `maxae` and `mdae`.
- Runtime provenance wording for those two metrics was updated to cite
  Hyndman & Koehler (2006) and to state the retained formulas explicitly.
- No runtime behavior changed.

## Program status captured by the closure note

- The closure note records the provenance-hardening program as complete for the
  current live metric surface.
- It preserved the four explicit provenance classes used by the repository:
  `literature-exact`, `standard-statistical`,
  `literature-grounded-variant`, and `package-defined`.
- The note also made clear that program completion did not imply every metric
  was literature-exact; it meant the remaining intentional provenance debt for
  the live registry surface had been closed.
