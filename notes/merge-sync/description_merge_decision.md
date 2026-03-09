# DESCRIPTION Merge Decision

- Generated: 2026-03-10 00:36:00 IST
- Current branch: `feature/resolve-description-merge-and-baseline-sync`
- Merge source: `origin/main`
- Conflicted file: `DESCRIPTION`

| Field | Local value | Incoming value | Planned retained value | Rationale |
| --- | --- | --- | --- | --- |
| `Title` | `Hydrological Model Evaluation Metrics` | `Clean-Room Hydrological Evaluation Metrics` | `Hydrological Model Evaluation Metrics` | The local title better reflects the stabilized Phase 2 release framing. |
| `Version` | `0.2.0` | `0.2.0` | `0.2.0` | Non-negotiable release baseline. |
| `Authors@R` | placeholder team maintainer | `Arcblade-02` concrete maintainer | incoming maintainer identity | The incoming side provides concrete, release-usable maintainer metadata. |
| `Author` / `Maintainer` | absent | present | keep incoming values | These are valid additions and align with the chosen `Authors@R`. |
| `Description` | Phase 2 release description with compatibility wrappers and framework wording | scaffold-style clean-room description | local Phase 2 description | The local description better matches the intended stabilized Phase 2 state. |
| `LazyData` | `true` | absent | `true` | Preserve local release metadata. |
| `URL` | absent | GitHub repository URL | keep incoming value | Valid release metadata addition. |
| `BugReports` | absent | GitHub issues URL | keep incoming value | Valid release metadata addition. |
| `Imports` | `stats`, `graphics` | `R6 (>= 2.5.1)` | union of both sides | Preserve actual runtime support and required `R6`. |
| `Suggests` | includes `microbenchmark`, `rmarkdown`, `xts`, `zoo` | adds `markdown`, retains tests/coverage/vignettes packages | union of both sides | Preserve compatible metadata additions needed for docs, tests, vignettes, and benchmarking. |
| `VignetteBuilder` | `knitr` | `knitr` | `knitr` | Consistent across both sides. |
| `Config/testthat/edition` | `3` | `3` | `3` | Consistent across both sides. |
| `Roxygen` / `RoxygenNote` | `list(markdown = TRUE)` / `7.3.3` | same | keep as-is | Identical and valid. |

## Resolution policy applied

- Kept the Phase 2 release baseline version and release-oriented description.
- Preserved compatible incoming metadata additions: `URL`, `BugReports`,
  maintainer identity, `R6`, and `markdown`.
- Removed all merge markers and kept the file internally consistent.
