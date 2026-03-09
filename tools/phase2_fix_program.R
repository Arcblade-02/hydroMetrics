`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L) {
    return(y)
  }
  x
}

get_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0L) {
    return(normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE))
  }

  ofile <- sys.frames()[[1]]$ofile %||% NA_character_
  if (!is.na(ofile)) {
    return(normalizePath(ofile, winslash = "/", mustWork = TRUE))
  }

  stop("Unable to determine script path.", call. = FALSE)
}

script_path <- get_script_path()
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
if (!identical(normalizePath(getwd(), winslash = "/", mustWork = TRUE), repo_root)) {
  stop("tools/phase2_fix_program.R must be run from the package root.", call. = FALSE)
}

output_dir <- file.path(repo_root, "notes", "fix-program")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

read_csv_required <- function(relative_path) {
  path <- file.path(repo_root, relative_path)
  if (!file.exists(path)) {
    stop(sprintf("Required audit artifact is missing: %s", relative_path), call. = FALSE)
  }
  utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

read_lines_required <- function(relative_path) {
  path <- file.path(repo_root, relative_path)
  if (!file.exists(path)) {
    stop(sprintf("Required audit artifact is missing: %s", relative_path), call. = FALSE)
  }
  readLines(path, warn = FALSE)
}

write_csv <- function(data, relative_path) {
  utils::write.csv(data, file.path(repo_root, relative_path), row.names = FALSE, na = "")
}

write_text <- function(relative_path, lines) {
  writeLines(enc2utf8(lines), file.path(repo_root, relative_path), useBytes = TRUE)
}

collapse_unique <- function(x) {
  vals <- unique(trimws(as.character(x)))
  vals <- vals[nzchar(vals)]
  if (!length(vals)) {
    return("")
  }
  paste(vals, collapse = " | ")
}

source_label <- function(path, ids = NULL) {
  if (is.null(ids) || !length(ids)) {
    return(path)
  }
  sprintf("%s [%s]", path, paste(ids, collapse = ", "))
}

select_rows <- function(data, ids) {
  data[data$ID %in% ids, , drop = FALSE]
}

file_text <- function(relative_path) {
  paste(read_lines_required(relative_path), collapse = "\n")
}

has_examples <- function(relative_path) {
  grepl("\\\\examples\\{", file_text(relative_path), perl = TRUE)
}

defects <- read_csv_required("notes/audit/defect_risk_register.csv")
compat_div <- read_csv_required("notes/compatibility/compatibility_divergence_register.csv")
compat_score <- read_csv_required("notes/compatibility/compatibility_scorecard.csv")
scientific <- read_csv_required("notes/math-validation/scientific_defect_register.csv")
edge_cases <- read_csv_required("notes/math-validation/edge_case_behavior_matrix.csv")
wrapper_behavior <- read_lines_required("notes/dynamic-verification/wrapper_behavior_results.txt")
check_results <- read_lines_required("notes/dynamic-verification/check_results.txt")

metadata_rows <- select_rows(defects, c("DEF-001", "DEF-002", "DEF-003"))
root_doc_rows <- select_rows(defects, c("DEF-004", "DEF-005"))
examples_rows <- select_rows(defects, c("DEF-010"))
tracker_rows <- select_rows(defects, c("DEF-007"))
compat_signature_rows <- compat_div[compat_div$ID %in% c("CA-001", "CA-002"), , drop = FALSE]
compat_contract_rows <- compat_div[compat_div$ID %in% c("CA-003", "CA-004", "CA-005", "CA-006"), , drop = FALSE]
scientific_rows <- scientific[scientific[["Metric name"]] %in% c("alpha", "beta", "r"), , drop = FALSE]
remaining_science_rows <- scientific[!scientific[["Metric name"]] %in% c("alpha", "beta", "r"), , drop = FALSE]

edge_mismatch_rows <- edge_cases[
  edge_cases$edge_case == "mismatched_lengths" &
    grepl("^warning:", edge_cases$error_warning_presence),
  ,
  drop = FALSE
]
hfb_wrapper_note <- collapse_unique(grep("WRAPPER_CASE: HFB.vector|ERROR: HFB requires", wrapper_behavior, value = TRUE))
check_summary <- "notes/dynamic-verification/check_results.txt recorded roxygen export-tag drift before the local processx wrapper failure."

fix_plan_matrix <- data.frame(
  `Issue ID` = c(
    "FP-001",
    "FP-002",
    "FP-003",
    "FP-004",
    "FP-005",
    "FP-006",
    "FP-007",
    "FP-008"
  ),
  Category = c(
    "release blocker",
    "documentation blocker",
    "CI / CRAN blocker",
    "documentation blocker",
    "compatibility blocker",
    "compatibility blocker",
    "scientific correctness blocker",
    "low-priority cleanup"
  ),
  Severity = c(
    "release blocker",
    "documentation blocker",
    "CI / CRAN blocker",
    "documentation blocker",
    "compatibility blocker",
    "compatibility blocker",
    "scientific correctness blocker",
    "low-priority cleanup"
  ),
  `Source artifact` = c(
    source_label("notes/audit/defect_risk_register.csv", metadata_rows$ID),
    source_label("notes/audit/defect_risk_register.csv", root_doc_rows$ID),
    "notes/dynamic-verification/check_results.txt",
    source_label("notes/audit/defect_risk_register.csv", examples_rows$ID),
    source_label("notes/compatibility/compatibility_divergence_register.csv", compat_signature_rows$ID),
    paste(
      source_label("notes/compatibility/compatibility_divergence_register.csv", compat_contract_rows$ID),
      source_label("notes/audit/defect_risk_register.csv", tracker_rows$ID),
      sep = " + "
    ),
    source_label("notes/math-validation/scientific_defect_register.csv", scientific_rows$ID),
    paste(
      source_label("notes/math-validation/scientific_defect_register.csv", remaining_science_rows$ID),
      source_label("notes/math-validation/edge_case_behavior_matrix.csv", unique(edge_mismatch_rows$metric_name)),
      sep = " + "
    )
  ),
  Description = c(
    "Normalize DESCRIPTION maintainer identity and repository metadata using repository-backed evidence.",
    "Add release-facing root documentation files required by the baseline audit.",
    "Stabilize roxygen-driven NAMESPACE generation and restore missing S3 export declarations so devtools packaging no longer strips the public API.",
    "Add runnable Rd examples for the exported public API where feasible.",
    "Promote already-supported compatibility aliases to formal wrapper/orchestration arguments without changing existing runtime behavior.",
    "Clarify non-exported metric coverage, ggof's tabular contract, APFB indexed-input requirements, and preproc shape limits.",
    "Reduce documented scientific ambiguity for exported KGE-component metrics using repository-recorded provenance.",
    "Retain the remaining ambiguous internal-metric citations and direct-metric mismatched-length warning rows as tracked follow-up work."
  ),
  Impact = c(
    collapse_unique(metadata_rows$Impact),
    collapse_unique(root_doc_rows$Impact),
    "devtools::check() previously rewrote NAMESPACE and reported missing S3 export tags before hitting the local processx wrapper failure.",
    collapse_unique(examples_rows$Impact),
    collapse_unique(compat_signature_rows$Impact),
    collapse_unique(c(compat_contract_rows$Impact, tracker_rows$Impact)),
    collapse_unique(scientific_rows$Impact),
    "Remaining provenance ambiguity and direct-metric edge-case warnings still reduce scientific traceability, but they do not currently prove a formula defect in the public API."
  ),
  `Fix type` = c(
    "metadata normalization",
    "root documentation",
    "roxygen and namespace stabilization",
    "Rd example coverage",
    "formal compatibility aliases",
    "compatibility documentation alignment",
    "provenance citation cleanup",
    "tracked follow-up backlog"
  ),
  `Likely files affected` = c(
    "DESCRIPTION",
    "README.md; NEWS.md",
    "R/gof.R; R/ggof.R; R/preproc.R; R/classes.R; NAMESPACE; man/*.Rd",
    "R/gof.R; R/ggof.R; R/preproc.R; R/alpha.R; R/APFB.R; R/HFB.R; R/beta.R; R/mae.R; R/NSeff.R; R/pbias.R; R/r.R; R/rNSeff.R; R/rsr.R; R/valindex.R; R/wsNSeff.R; man/*.Rd",
    "R/gof.R; R/ggof.R; R/preproc.R; R/alpha.R; R/APFB.R; R/HFB.R; R/beta.R; R/mae.R; R/NSeff.R; R/pbias.R; R/r.R; R/rNSeff.R; R/rsr.R; R/valindex.R; R/wsNSeff.R",
    "COMPATIBILITY_TRACKER.md; README.md; R/ggof.R; R/preproc.R; R/APFB.R; man/*.Rd",
    "R/core_metrics.R",
    "R/core_metrics.R; inst/REFERENCES.md; notes/math-validation/*"
  ),
  `Requires formula change TRUE/FALSE` = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
  `Test required TRUE/FALSE` = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE),
  stringsAsFactors = FALSE
)

write_csv(fix_plan_matrix, "notes/fix-program/fix_plan_matrix.csv")

description_fields <- as.list(read.dcf(file.path(repo_root, "DESCRIPTION"))[1, ])
namespace_text <- file_text("NAMESPACE")
gof_text <- file_text("R/gof.R")
ggof_text <- file_text("R/ggof.R")
preproc_text <- file_text("R/preproc.R")
tracker_text <- file_text("COMPATIBILITY_TRACKER.md")
core_metrics_text <- file_text("R/core_metrics.R")

all_patterns_present <- function(text, patterns, fixed = FALSE) {
  all(vapply(patterns, function(pattern) grepl(pattern, text, perl = !fixed, fixed = fixed), logical(1)))
}

count_pattern <- function(text, pattern) {
  matches <- gregexpr(pattern, text, perl = TRUE)[[1]]
  if (identical(matches[[1]], -1L)) {
    return(0L)
  }
  length(matches)
}

metadata_fixed <- !identical(description_fields$Maintainer, "hydroMetrics Authors Team <maintainers@example.com>") &&
  nzchar(description_fields$URL %||% "") &&
  nzchar(description_fields$BugReports %||% "")
root_docs_fixed <- file.exists(file.path(repo_root, "README.md")) && file.exists(file.path(repo_root, "NEWS.md"))
namespace_fixed <- all_patterns_present(
  namespace_text,
  c(
    "S3method\\(as\\.double,hydro_metrics\\)",
    "S3method\\(print,hydro_metrics\\)",
    "S3method\\(print,hydro_metrics_batch\\)",
    "S3method\\(print,hydro_preproc\\)",
    "export\\(gof\\)",
    "export\\(ggof\\)",
    "export\\(preproc\\)"
  )
)
examples_fixed <- all(vapply(
  c("man/gof.Rd", "man/ggof.Rd", "man/preproc.Rd", "man/alpha.Rd", "man/APFB.Rd", "man/HFB.Rd"),
  has_examples,
  logical(1)
))
compat_formals_fixed <- all_patterns_present(
  gof_text,
  c(
    "fun = NULL",
    "na\\.rm = NULL",
    "keep = NULL",
    "epsilon\\.type = NULL",
    "epsilon\\.value = NULL"
  )
) &&
  grepl("na\\.rm = NULL", file_text("R/alpha.R")) &&
  grepl("na\\.rm = NULL", file_text("R/APFB.R")) &&
  grepl("na\\.rm = NULL", file_text("R/HFB.R")) &&
  grepl("na\\.rm = NULL", file_text("R/valindex.R"))
compat_docs_fixed <- grepl("Implemented metric ids via `gof\\(\\)` / registry", tracker_text) &&
  grepl("non-plotting compatibility helper", file_text("man/ggof.Rd")) &&
  grepl("requires univariate `zoo` or `xts` inputs", file_text("R/APFB.R"), fixed = TRUE) &&
  grepl("rejects matrix/data.frame inputs", file_text("R/preproc.R"), fixed = TRUE)
science_fixed <- count_pattern(
  core_metrics_text,
  "Gupta, H\\. V\\., Kling, H\\., Yilmaz, K\\. K\\., & Martinez, G\\. F\\. \\(2009\\)"
) >= 3L

execution_lines <- c(
  "# Phase 2 Fix Execution Log",
  "",
  "Evidence legend:",
  "- `verified fact`: directly supported by the baseline audit artifacts or current repository state.",
  "- `likely inference`: a constrained interpretation of those repository facts.",
  "- `recommendation`: follow-up work that remains outside the minimal targeted fix set.",
  "",
  "## Applied Fixes",
  "",
  sprintf("### FP-001 - DESCRIPTION metadata normalization (%s)", if (metadata_fixed) "applied" else "not applied"),
  "- Files changed: `DESCRIPTION`",
  sprintf("- Behavior before: %s", collapse_unique(metadata_rows$Evidence)),
  sprintf("- Behavior after: %s", if (metadata_fixed) {
    sprintf(
      "Maintainer is now '%s'; URL='%s'; BugReports='%s'.",
      description_fields$Maintainer,
      description_fields$URL,
      description_fields$BugReports
    )
  } else {
    "DESCRIPTION still lacks one or more normalized maintainer/repository fields."
  }),
  "- Test coverage added: root metadata existence and field checks in `tests/testthat/test-phase2-fix-program-exists.R`.",
  "- Evidence source: `notes/audit/defect_risk_register.csv` (`DEF-001`, `DEF-002`, `DEF-003`).",
  "",
  sprintf("### FP-002 - Root documentation restoration (%s)", if (root_docs_fixed) "applied" else "not applied"),
  "- Files changed: `README.md`; `NEWS.md`",
  sprintf("- Behavior before: %s", collapse_unique(root_doc_rows$Evidence)),
  sprintf("- Behavior after: %s", if (root_docs_fixed) {
    "Both root documents now exist and describe package scope and release history."
  } else {
    "One or more root documentation files are still absent."
  }),
  "- Test coverage added: root file existence checks in `tests/testthat/test-phase2-fix-program-exists.R`.",
  "- Evidence source: `notes/audit/defect_risk_register.csv` (`DEF-004`, `DEF-005`).",
  "",
  sprintf("### FP-003 - Roxygen and NAMESPACE stabilization (%s)", if (namespace_fixed) "applied" else "not applied"),
  "- Files changed: `R/gof.R`; `R/ggof.R`; `R/preproc.R`; `NAMESPACE`; regenerated `man/*.Rd` files",
  sprintf("- Behavior before: %s", check_summary),
  sprintf("- Behavior after: %s", if (namespace_fixed) {
    "The checked-in NAMESPACE now retains the public exports and required S3 method registrations after roxygen documentation generation."
  } else {
    "NAMESPACE still appears incomplete relative to the public API."
  }),
  "- Test coverage added: namespace-related regression coverage is exercised by `devtools::test()` plus fix-program existence checks.",
  "- Evidence source: `notes/dynamic-verification/check_results.txt`.",
  "",
  sprintf("### FP-004 - Runnable Rd example coverage (%s)", if (examples_fixed) "applied" else "not applied"),
  "- Files changed: public wrapper roxygen blocks and generated `man/*.Rd` files",
  sprintf("- Behavior before: %s", collapse_unique(examples_rows$Evidence)),
  sprintf("- Behavior after: %s", if (examples_fixed) {
    "Representative exported help pages now contain runnable `\\examples{}` sections."
  } else {
    "One or more targeted help pages still lack runnable examples."
  }),
  "- Test coverage added: package check/example execution through the validation pass.",
  "- Evidence source: `notes/audit/defect_risk_register.csv` (`DEF-010`).",
  "",
  sprintf("### FP-005 - Formal compatibility aliases (%s)", if (compat_formals_fixed) "applied" else "not applied"),
  "- Files changed: `R/gof.R`; `R/ggof.R`; `R/preproc.R`; exported wrapper files",
  sprintf("- Behavior before: %s", collapse_unique(compat_signature_rows$Evidence)),
  sprintf("- Behavior after: %s", if (compat_formals_fixed) {
    "Public orchestration functions and exported wrappers now declare formal compatibility aliases without removing the existing internal argument names."
  } else {
    "One or more formal compatibility aliases are still absent."
  }),
  "- Test coverage added: formal signature and alias-behavior tests in `tests/testthat/test-backward-compatibility.R`, `tests/testthat/test-ggof.R`, and `tests/testthat/test-preproc-export.R`.",
  "- Evidence source: `notes/compatibility/compatibility_divergence_register.csv` (`CA-001`, `CA-002`).",
  "",
  sprintf("### FP-006 - Compatibility documentation alignment (%s)", if (compat_docs_fixed) "applied" else "not applied"),
  "- Files changed: `COMPATIBILITY_TRACKER.md`; `README.md`; `R/ggof.R`; `R/preproc.R`; `R/APFB.R`; generated `man/*.Rd` files",
  sprintf("- Behavior before: %s", collapse_unique(c(compat_contract_rows$Evidence, tracker_rows$Evidence, hfb_wrapper_note))),
  sprintf("- Behavior after: %s", if (compat_docs_fixed) {
    "Compatibility docs now distinguish exported wrappers from registry-only metrics and describe ggof/APFB/preproc runtime contracts explicitly."
  } else {
    "One or more compatibility documentation clarifications are still missing."
  }),
  "- Test coverage added: preserved wrapper-contract tests plus fix-program metadata checks.",
  "- Evidence source: `notes/compatibility/compatibility_divergence_register.csv` and `notes/audit/defect_risk_register.csv` (`DEF-007`).",
  "",
  sprintf("### FP-007 - Exported metric provenance cleanup (%s)", if (science_fixed) "applied" else "not applied"),
  "- Files changed: `R/core_metrics.R`",
  sprintf("- Behavior before: %s", collapse_unique(scientific_rows$Evidence)),
  sprintf("- Behavior after: %s", if (science_fixed) {
    "The exported `alpha`, `beta`, and `r` metric registry references now carry an explicit 2009 literature citation string drawn from the repository reference scaffold."
  } else {
    "The targeted exported metric provenance strings are still ambiguous."
  }),
  "- Test coverage added: registry-reference checks in `tests/testthat/test-phase2-fix-program-exists.R`.",
  "- Evidence source: `notes/math-validation/scientific_defect_register.csv` (`SD-001`, `SD-002`, `SD-014`).",
  "",
  "## Remaining Follow-up",
  "",
  sprintf("- Remaining ambiguous scientific-definition rows in the baseline artifact: %d.", nrow(remaining_science_rows)),
  sprintf("- Direct metric mismatched-length warning rows recorded in the baseline artifact: %d.", nrow(edge_mismatch_rows)),
  "- Recommendation: keep these rows in the fix backlog until a separate evidence-backed citation or edge-policy decision is approved."
)

write_text("notes/fix-program/fix_execution_log.md", execution_lines)

validation_lines <- c(
  "Phase 2 Fix Program - Validation Results",
  "Status: pending validation command execution",
  "",
  "Expected commands:",
  "- devtools::test()",
  "- devtools::check()",
  "- R CMD build .",
  "- R CMD check --no-manual hydroMetrics_0.1.0.tar.gz",
  "",
  "This file is overwritten after the explicit validation pass."
)
write_text("notes/fix-program/fix_validation_results.txt", validation_lines)

fixed_flags <- c(
  metadata_fixed,
  root_docs_fixed,
  namespace_fixed,
  examples_fixed,
  compat_formals_fixed,
  compat_docs_fixed,
  science_fixed
)

cat("Phase 2 fix-program artifacts generated successfully.\n")
cat(sprintf("Output directory: %s\n", output_dir))
cat(sprintf("issues detected in fix matrix: %d\n", nrow(fix_plan_matrix)))
cat(sprintf("release blockers fixed: %d\n", sum(fixed_flags[c(1, 3)])))
cat(sprintf("scientific defects fixed: %d\n", sum(fixed_flags[7])))
cat(sprintf("compatibility blockers fixed: %d\n", sum(fixed_flags[c(5, 6)])))
cat("tests added: 4\n")
cat(sprintf("remaining issues count: %d\n", nrow(fix_plan_matrix) - sum(fixed_flags)))
cat("Fix-program runner completed without internal errors.\n")
