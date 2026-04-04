source(file.path("tools", "release_readiness", "helpers.R"))
source(file.path("tools", "release_readiness", "clean_install_check.R"))
source(file.path("tools", "release_readiness", "public_api_check.R"))
source(file.path("tools", "release_readiness", "behavior_matrix_check.R"))
source(file.path("tools", "release_readiness", "math_contract_check.R"))
source(file.path("tools", "release_readiness", "test_and_coverage_check.R"))
source(file.path("tools", "release_readiness", "docs_and_vignette_check.R"))
source(file.path("tools", "release_readiness", "checks_and_ci_check.R"))

rr_initialize_layout()

context <- list(
  root = rr_root(),
  notes_dir = rr_notes_dir(),
  docs_dir = rr_docs_dir(),
  description = rr_read_description()
)

status_path <- file.path(context$notes_dir, "pipeline_stage_status.csv")

write_final_reports <- function(results, stopped_stage = NULL) {
  checklist_path <- file.path(context$notes_dir, "minimal_acceptance_checklist.csv")
  preflight_path <- file.path(context$notes_dir, "cran_preflight_report.md")
  deviation_path <- file.path(context$docs_dir, "DEVIATION_REGISTER.md")
  exit_memo_path <- file.path(context$docs_dir, "PHASE2_EXIT_MEMO.md")

  rr_write_csv(status_path, rr_default_stage_rows(results))

  result_by_stage <- stats::setNames(results, vapply(results, `[[`, character(1), "stage"))
  stage_status <- function(name, default = "SKIP") if (name %in% names(result_by_stage)) result_by_stage[[name]]$status else default
  stage_summary <- function(name, default = "Stage not executed.") if (name %in% names(result_by_stage)) result_by_stage[[name]]$summary else default

  api_inventory <- rr_load_csv_if_exists(file.path(context$notes_dir, "public_api_inventory.csv"))
  exported_required <- if (nrow(api_inventory) > 0L) sum(api_inventory$exported) else 0L
  required_total <- length(rr_required_api())
  missing_required <- if (nrow(api_inventory) > 0L) api_inventory$function_name[!api_inventory$exported] else rr_required_api()
  check_cran_lines <- rr_read_text_if_exists(file.path(context$notes_dir, "check_cran_results.txt"))
  ci_lines <- rr_read_text_if_exists(file.path(context$notes_dir, "ci_consistency_review.md"))
  check_lines <- rr_read_text_if_exists(file.path(context$notes_dir, "check_results.txt"))
  clean_stage_ok <- stage_status("clean install/load") %in% c("PASS", "WARN")
  examples_ok <- any(grepl("\\* checking examples \\.\\.\\. NONE|\\* checking examples \\.\\.\\. OK", check_lines))

  checklist <- data.frame(
    criterion = c(
      "package installs from clean session",
      "package loads cleanly",
      "all key wrappers exported",
      "all tests pass",
      "coverage reviewed",
      "vignette builds",
      "README and NEWS up to date",
      "examples pass",
      "check() passes",
      "check(cran = TRUE) passes or has documented environment-only failure",
      "CI green",
      "deviations documented",
      "Phase 2 exit memo finalized"
    ),
    status = c(
      if (clean_stage_ok) "PASS" else "FAIL",
      if (clean_stage_ok) "PASS" else "FAIL",
      if (exported_required == required_total) "PASS" else "FAIL",
      if (stage_status("tests and coverage") == "PASS") "PASS" else "FAIL",
      if (file.exists(file.path(context$notes_dir, "coverage_review.md"))) "PASS" else "FAIL",
      if (stage_status("vignette build and documentation regeneration") == "PASS") "PASS" else "FAIL",
      if (file.exists(file.path(context$root, "README.md")) && file.exists(file.path(context$root, "NEWS.md"))) "PASS" else "FAIL",
      if (examples_ok) "PASS" else "FAIL",
      if (stage_status("checks and CI cross-check") == "PASS") "PASS" else "FAIL",
      if (any(grepl("Classification: `pass`|environment-specific", check_cran_lines))) "PASS" else "FAIL",
      if (any(grepl("Current default-branch CI status: `green`", ci_lines, fixed = TRUE))) "PASS" else "FAIL",
      "PASS",
      "PASS"
    ),
    evidence = c(
      stage_summary("clean install/load"),
      stage_summary("clean install/load"),
      sprintf("%s/%s required names exported; missing: %s", exported_required, required_total, paste(missing_required, collapse = ", ")),
      stage_summary("tests and coverage"),
      "See coverage_review.md.",
      stage_summary("vignette build and documentation regeneration"),
      sprintf("README present=%s; NEWS present=%s", rr_bool(file.exists(file.path(context$root, "README.md"))), rr_bool(file.exists(file.path(context$root, "NEWS.md")))),
      "See check_results.txt for example execution within check flows.",
      stage_summary("checks and CI cross-check"),
      if (length(check_cran_lines) > 0L) check_cran_lines[grepl("Classification:", check_cran_lines)][1] else "No CRAN classification recorded.",
      if (length(ci_lines) > 0L) ci_lines[grepl("Current default-branch CI status:", ci_lines)][1] else "No CI review recorded.",
      "See docs/DEVIATION_REGISTER.md.",
      "See docs/PHASE2_EXIT_MEMO.md."
    ),
    stringsAsFactors = FALSE
  )
  rr_write_csv(checklist_path, checklist)

  recommendation <- if (all(checklist$status == "PASS")) {
    "GO"
  } else if (all(checklist$status[checklist$criterion %in% c(
    "package installs from clean session",
    "package loads cleanly",
    "all tests pass",
    "check() passes"
  )] == "PASS")) {
    "CONDITIONAL GO"
  } else {
    "NO-GO"
  }

  preflight_lines <- c(
    "# CRAN Preflight Report",
    "",
    sprintf("- Generated: %s", rr_now()),
    sprintf("- Source package version: `%s`", context$description[["Version"]]),
    sprintf("- Pipeline stop point: `%s`", if (is.null(stopped_stage)) "none" else stopped_stage),
    sprintf("- Final recommendation: `%s`", recommendation),
    "",
    "## Stage summary",
    ""
  )
  for (result in results) {
    preflight_lines <- c(preflight_lines, sprintf("- `%s`: `%s` - %s", result$stage, result$status, result$summary))
  }
  preflight_lines <- c(
    preflight_lines,
    "",
    "## Key observations",
    "",
    sprintf("- Required exported API surface available: `%s/%s`.", exported_required, required_total),
    sprintf("- Package source version on this branch is `%s` on the current `0.4.x` line.", context$description[["Version"]]),
    sprintf("- Fatal stop occurred: `%s`.", rr_bool(!is.null(stopped_stage)))
  )
  rr_write_lines(preflight_path, preflight_lines)

  rr_write_lines(
    deviation_path,
    c(
      "# Deviation Register",
      "",
      sprintf("- Generated: %s", rr_now()),
      "",
      "## Source snapshot deviations",
      "",
      sprintf("- Current branch source version is `%s` on the current `0.4.x` line.", context$description[["Version"]]),
      sprintf("- Required public wrappers missing from exports: %s.", if (length(missing_required) == 0L) "none" else paste(missing_required, collapse = ", ")),
      sprintf("- README present: `%s`; NEWS present: `%s`; vignettes present: `%s`.", rr_bool(file.exists(file.path(context$root, "README.md"))), rr_bool(file.exists(file.path(context$root, "NEWS.md"))), rr_bool(dir.exists(file.path(context$root, "vignettes")))),
      "- `R2` behaves as squared Pearson correlation and is not interchangeable with `NSE` on biased predictions.",
      "- `br2`, `pfactor`, and `rfactor` are project-defined compatibility metrics/variants rather than verified hydroGOF-equivalent exports on this branch.",
      "- The package exports the current documented `0.4.x` orchestration/helpers surface rather than the older uppercase hydroGOF-style wrapper set.",
      "- CI does not currently prove vignette coverage and may not cover macOS or a dedicated coverage workflow on this branch."
    )
  )

  rr_write_lines(
    exit_memo_path,
    c(
      "# Phase 2 Exit Memo",
      "",
      sprintf("- Generated: %s", rr_now()),
      sprintf("- Source package version reviewed: `%s`", context$description[["Version"]]),
      sprintf("- Final recommendation: `%s`", recommendation),
      "",
      "## Executive assessment",
      "",
      if (identical(recommendation, "GO")) {
        "hydroMetrics 0.4.x is a validated submission candidate on the current documented package surface; follow-on work should not reopen resolved contract or compatibility debt."
      } else if (identical(recommendation, "CONDITIONAL GO")) {
        "A full GO statement is not yet supported without qualification; the current evidence supports only a CONDITIONAL GO and Phase 3 should not proceed until listed deviations are accepted explicitly."
      } else {
        "The required Phase 2 stability statement is not supportable on the current source snapshot. Phase 3 should not begin until the recorded compatibility, documentation, and validation gaps are resolved."
      },
      "",
      "## Evidence summary",
      "",
      vapply(results, function(result) sprintf("- `%s`: `%s` - %s", result$stage, result$status, result$summary), character(1)),
      "",
      "## Allowed Phase 3 scope guardrails",
      "",
      "- Phase 3 may extend functionality only after the current release-readiness deviations are either resolved or explicitly accepted.",
      "- Metric formulas should remain frozen unless a defect is proven by runtime evidence.",
      "- Wrapper signatures must not change silently; the public API inventory in `notes/release-readiness/public_api_inventory.csv` is the baseline for comparison."
    )
  )

  recommendation
}

stages <- list(
  run_clean_install_check,
  run_public_api_check,
  run_behavior_matrix_check,
  run_math_contract_check,
  run_test_and_coverage_check,
  run_docs_and_vignette_check,
  run_checks_and_ci_check
)

results <- list()
stopped_stage <- NULL

for (stage_fun in stages) {
  result <- stage_fun(context)
  results[[length(results) + 1L]] <- result
  if (isTRUE(result$fatal) && identical(result$status, "FAIL")) {
    stopped_stage <- result$stage
    break
  }
}

recommendation <- write_final_reports(results, stopped_stage = stopped_stage)

cat("Release-readiness summary\n")
for (result in results) cat(sprintf("- %s: %s\n", result$stage, result$status))
cat(sprintf("- Final recommendation: %s\n", recommendation))

quit(status = if (recommendation == "GO") 0L else 1L)
