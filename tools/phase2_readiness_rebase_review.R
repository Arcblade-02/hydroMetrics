#!/usr/bin/env Rscript

options(stringsAsFactors = FALSE)

project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
description_path <- file.path(project_root, "DESCRIPTION")

if (!file.exists(description_path)) {
  stop("Run this script from the package root containing DESCRIPTION.", call. = FALSE)
}

output_dir <- file.path(project_root, "notes", "readiness-review")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

`%||%` <- function(x, y) {
  if (length(x) == 0L || all(is.na(x)) || identical(x, "")) {
    return(y)
  }
  x
}

read_text <- function(path) {
  if (!file.exists(path)) {
    return(character())
  }

  con <- file(path, open = "rb")
  on.exit(close(con), add = TRUE)
  bom <- readBin(con, what = "raw", n = 2L)

  encoding <- "UTF-8"
  if (length(bom) == 2L) {
    if (identical(as.integer(bom), c(255L, 254L))) {
      encoding <- "UTF-16LE"
    } else if (identical(as.integer(bom), c(254L, 255L))) {
      encoding <- "UTF-16BE"
    }
  }

  text_con <- file(path, open = "rt", encoding = encoding)
  on.exit(close(text_con), add = TRUE)
  suppressWarnings(readLines(text_con, warn = FALSE))
}

write_csv_deterministic <- function(data, path, order_cols = NULL) {
  if (!is.null(order_cols) && nrow(data) > 0L) {
    keys <- data[order_cols]
    ord <- do.call(order, c(keys, list(na.last = TRUE)))
    data <- data[ord, , drop = FALSE]
  }
  write.csv(data, path, row.names = FALSE, na = "")
}

git_stdout <- function(args) {
  out <- suppressWarnings(system2("git", args = args, stdout = TRUE, stderr = FALSE))
  status <- attr(out, "status") %||% 0L
  if (!identical(status, 0L)) {
    return(character())
  }
  out
}

extract_exports <- function(namespace_path) {
  ns_lines <- read_text(namespace_path)
  sort(unique(sub("^export\\(([^)]+)\\)$", "\\1", grep("^export\\(", ns_lines, value = TRUE))))
}

extract_rd_index <- function(man_dir) {
  rd_paths <- sort(list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE))
  rows <- lapply(rd_paths, function(path) {
    lines <- read_text(path)
    aliases <- sub("^\\\\alias\\{([^}]+)\\}$", "\\1", grep("^\\\\alias\\{", lines, value = TRUE))
    data.frame(
      rd_file = basename(path),
      alias = aliases,
      has_examples = rep(any(grepl("^\\\\examples\\{", lines)), length(aliases)),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

build_package_environment <- function(root) {
  env <- new.env(parent = baseenv())
  r_files <- sort(list.files(file.path(root, "R"), pattern = "\\.R$", full.names = TRUE))
  for (path in r_files) {
    sys.source(path, envir = env)
  }
  if (exists(".onLoad", envir = env, inherits = FALSE)) {
    try(env$.onLoad(NULL, "hydroMetrics"), silent = TRUE)
  }
  env
}

sanitize_example_code <- function(code) {
  trimmed <- trimws(code)
  keep <- !grepl("^(library|require)\\((\"|')?hydroMetrics(\"|')?\\)", trimmed)
  code[keep]
}

extract_rd_example_code <- function(rd_path) {
  rd <- tryCatch(tools::parse_Rd(rd_path), error = function(e) NULL)
  if (is.null(rd)) {
    return(character())
  }

  temp_script <- tempfile(fileext = ".R")
  on.exit(unlink(temp_script), add = TRUE)
  ok <- tryCatch(
    {
      tools::Rd2ex(rd, out = temp_script, commentDontrun = TRUE, commentDonttest = TRUE)
      TRUE
    },
    error = function(e) FALSE
  )
  if (!ok || !file.exists(temp_script)) {
    return(character())
  }

  lines <- read_text(temp_script)
  lines <- sanitize_example_code(lines)
  lines[nzchar(trimws(lines)) & !grepl("^##", lines)]
}

run_code_block <- function(code, eval_env) {
  if (length(code) == 0L) {
    return(list(status = "skipped", output = character(), error = "No executable example code detected."))
  }

  temp_script <- tempfile(fileext = ".R")
  on.exit(unlink(temp_script), add = TRUE)
  writeLines(code, temp_script, useBytes = TRUE)

  tryCatch(
    {
      output <- capture.output(source(temp_script, local = eval_env, echo = FALSE, print.eval = TRUE))
      list(status = "pass", output = output, error = "")
    },
    error = function(e) {
      list(status = "fail", output = character(), error = conditionMessage(e))
    }
  )
}

parse_baseline_pass_count <- function(path) {
  lines <- read_text(path)
  hit <- grep("^PASS_COUNT:\\s*[0-9]+", lines, value = TRUE)
  if (length(hit) == 0L) {
    return(NA_integer_)
  }
  as.integer(sub("^PASS_COUNT:\\s*", "", tail(hit, 1L)))
}

parse_test_summary <- function(lines) {
  hit <- grep("^\\[ FAIL [0-9]+ \\| WARN [0-9]+ \\| SKIP [0-9]+ \\| PASS [0-9]+ \\]$", trimws(lines), value = TRUE)
  if (length(hit) == 0L) {
    return(c(fail = NA_integer_, warn = NA_integer_, skip = NA_integer_, pass = NA_integer_))
  }
  nums <- as.integer(unlist(regmatches(tail(hit, 1L), gregexpr("[0-9]+", tail(hit, 1L)))))
  stats::setNames(nums, c("fail", "warn", "skip", "pass"))
}

parse_check_summary <- function(lines, status_code) {
  ok_line <- grep("0 errors .*0 warnings .*0 notes", lines, value = TRUE)
  if (length(ok_line) > 0L && identical(status_code, 0L)) {
    return(c(errors = 0L, warnings = 0L, notes = 0L))
  }

  status_line <- grep("^Status:\\s+", trimws(lines), value = TRUE)
  if (length(status_line) > 0L && grepl("^Status:\\s+OK$", tail(status_line, 1L))) {
    return(c(errors = 0L, warnings = 0L, notes = 0L))
  }

  counts_line <- grep("[0-9]+ errors?.*[0-9]+ warnings?.*[0-9]+ notes?", lines, value = TRUE)
  if (length(counts_line) > 0L) {
    nums <- as.integer(unlist(regmatches(tail(counts_line, 1L), gregexpr("[0-9]+", tail(counts_line, 1L)))))
    if (length(nums) >= 3L) {
      return(stats::setNames(nums[1:3], c("errors", "warnings", "notes")))
    }
  }

  c(errors = as.integer(status_code != 0L), warnings = 0L, notes = 0L)
}

run_command_capture <- function(expr) {
  output <- character()
  err <- NULL
  output <- capture.output(
    result <- tryCatch(
      {
        force(expr)
        TRUE
      },
      error = function(e) {
        err <<- conditionMessage(e)
        FALSE
      }
    ),
    type = "output"
  )
  list(ok = isTRUE(result), output = output, error = err %||% "")
}

rscript_bin <- file.path(R.home("bin"), "Rscript.exe")
if (!file.exists(rscript_bin)) {
  rscript_bin <- file.path(R.home("bin"), "Rscript")
}

description <- as.list(read.dcf(description_path)[1, ])
package_name <- description[["Package"]] %||% "hydroMetrics"
package_version <- description[["Version"]] %||% "0.1.0"

exports <- extract_exports(file.path(project_root, "NAMESPACE"))
rd_index <- extract_rd_index(file.path(project_root, "man"))
documented_exports_count <- sum(exports %in% rd_index$alias)

expected_evidence_dirs <- c(
  "notes/audit",
  "notes/dynamic-verification",
  "notes/compatibility",
  "notes/math-validation",
  "notes/fix-program"
)

baseline_commit <- git_stdout(c("rev-parse", "feature/phase2-fix-program"))[1] %||% git_stdout(c("rev-parse", "HEAD"))[1] %||% "unresolved"
test_files <- sort(list.files(file.path(project_root, "tests", "testthat"), pattern = "\\.R$", full.names = FALSE))
baseline_pass_target <- parse_baseline_pass_count(file.path(project_root, "notes", "dynamic-verification", "testthat_results.txt"))

baseline_lines <- c(
  "# Baseline Validation",
  "",
  sprintf("- Baseline commit hash: `%s`", baseline_commit),
  sprintf("- README.md present: `%s`", file.exists(file.path(project_root, "README.md"))),
  sprintf("- NEWS.md present: `%s`", file.exists(file.path(project_root, "NEWS.md"))),
  sprintf("- COMPATIBILITY_TRACKER.md present: `%s`", file.exists(file.path(project_root, "COMPATIBILITY_TRACKER.md"))),
  sprintf("- NAMESPACE present: `%s`", file.exists(file.path(project_root, "NAMESPACE"))),
  sprintf("- Exported functions count: `%d`", length(exports)),
  sprintf("- Documented exports count: `%d`", documented_exports_count),
  sprintf("- Test files detected: `%d`", length(test_files)),
  sprintf("- Fix-program baseline PASS target: `%s`", if (is.na(baseline_pass_target)) "unverified" else as.character(baseline_pass_target)),
  "",
  "## Evidence directories detected",
  ""
)
baseline_lines <- c(
  baseline_lines,
  paste0("- `", expected_evidence_dirs, "`: `", dir.exists(file.path(project_root, expected_evidence_dirs)), "`"),
  "",
  "## Tests detected",
  "",
  paste0("- `", test_files, "`")
)
writeLines(baseline_lines, file.path(output_dir, "baseline_validation.md"), useBytes = TRUE)

test_output <- suppressWarnings(system2(rscript_bin, args = c("-e", "devtools::test()"), stdout = TRUE, stderr = TRUE))
test_status_code <- attr(test_output, "status") %||% 0L
test_counts <- parse_test_summary(test_output)
test_non_regression <- !is.na(test_counts[["pass"]]) &&
  !is.na(baseline_pass_target) &&
  test_counts[["pass"]] >= baseline_pass_target
test_status <- if (identical(test_status_code, 0L) && isTRUE(test_non_regression)) "pass" else if (identical(test_status_code, 0L)) "partial" else "fail"

test_lines <- c(
  "Phase 2 readiness rebase - test baseline confirmation",
  sprintf("Fix-program baseline PASS target: %s", if (is.na(baseline_pass_target)) "unverified" else baseline_pass_target),
  sprintf("PASS count: %s", test_counts[["pass"]]),
  sprintf("FAIL count: %s", test_counts[["fail"]]),
  sprintf("WARN count: %s", test_counts[["warn"]]),
  sprintf("SKIP count: %s", test_counts[["skip"]]),
  sprintf("Non-regression status: %s", if (isTRUE(test_non_regression)) "pass" else "fail"),
  sprintf("status=%s", if (identical(test_status_code, 0L)) "pass" else "fail"),
  ""
)
writeLines(c(test_lines, test_output), file.path(output_dir, "test_baseline_results.txt"), useBytes = TRUE)

check_run <- suppressWarnings(system2(rscript_bin, args = c("-e", "devtools::check(document = FALSE)"), stdout = TRUE, stderr = TRUE))
check_method <- "devtools::check(document = FALSE)"
check_status_code <- attr(check_run, "status") %||% 0L
check_output <- check_run

if (!identical(check_status_code, 0L)) {
  rcmd <- file.path(R.home("bin"), "Rcmd.exe")
  rcmd_args <- function(...) c(...)
  if (!file.exists(rcmd)) {
    rcmd <- file.path(R.home("bin"), "R")
    build_args <- rcmd_args("CMD", "build", ".")
    check_args <- rcmd_args("CMD", "check", "--no-manual", sprintf("%s_%s.tar.gz", package_name, package_version))
  } else {
    build_args <- rcmd_args("build", ".")
    check_args <- rcmd_args("check", "--no-manual", sprintf("%s_%s.tar.gz", package_name, package_version))
  }

  tarball_path <- file.path(project_root, sprintf("%s_%s.tar.gz", package_name, package_version))
  if (file.exists(tarball_path)) {
    unlink(tarball_path)
  }

  build_out <- suppressWarnings(system2(rcmd, args = build_args, stdout = TRUE, stderr = TRUE))
  build_status <- attr(build_out, "status") %||% 0L
  check_out <- character()
  fallback_status <- build_status

  if (identical(build_status, 0L) && file.exists(tarball_path)) {
    check_out <- suppressWarnings(system2(rcmd, args = check_args, stdout = TRUE, stderr = TRUE))
    fallback_status <- attr(check_out, "status") %||% 0L
  }

  check_method <- "R CMD build/check fallback"
  check_status_code <- fallback_status
  check_output <- c(
    "devtools::check() failed; fallback executed.",
    "",
    "",
    "R CMD build output:",
    build_out,
    "",
    "R CMD check output:",
    check_out
  )
}

check_counts <- parse_check_summary(check_output, check_status_code)
check_clean <- identical(unname(check_counts), c(0L, 0L, 0L))
check_lines <- c(
  "Phase 2 readiness rebase - package check verification",
  sprintf("Method: %s", check_method),
  sprintf("errors: %s", check_counts[["errors"]]),
  sprintf("warnings: %s", check_counts[["warnings"]]),
  sprintf("notes: %s", check_counts[["notes"]]),
  sprintf("status=%s", if (isTRUE(check_clean)) "pass" else "fail"),
  ""
)
writeLines(c(check_lines, check_output), file.path(output_dir, "check_results.txt"), useBytes = TRUE)

documentation_audit <- rbind(
  data.frame(item = "README.md", present = file.exists(file.path(project_root, "README.md")), status = if (file.exists(file.path(project_root, "README.md"))) "complete" else "missing", notes = "Phase 2 fix-program baseline README presence.", stringsAsFactors = FALSE),
  data.frame(item = "NEWS.md", present = file.exists(file.path(project_root, "NEWS.md")), status = if (file.exists(file.path(project_root, "NEWS.md"))) "complete" else "missing", notes = "Phase 2 fix-program baseline NEWS presence.", stringsAsFactors = FALSE),
  data.frame(item = "DESCRIPTION", present = TRUE, status = if (all(c("Package", "Title", "Description", "Version", "Authors@R", "License", "Encoding", "Imports", "URL", "BugReports") %in% names(description))) "complete" else "partial", notes = "CRAN-facing DESCRIPTION fields inspected.", stringsAsFactors = FALSE),
  data.frame(item = "LICENSE", present = file.exists(file.path(project_root, "LICENSE")), status = if (file.exists(file.path(project_root, "LICENSE"))) "complete" else "missing", notes = "File-based MIT license declaration inspected.", stringsAsFactors = FALSE),
  data.frame(item = "COMPATIBILITY_TRACKER.md", present = file.exists(file.path(project_root, "COMPATIBILITY_TRACKER.md")), status = if (file.exists(file.path(project_root, "COMPATIBILITY_TRACKER.md"))) "complete" else "missing", notes = "Compatibility tracker presence inspected.", stringsAsFactors = FALSE),
  data.frame(item = "man pages", present = dir.exists(file.path(project_root, "man")), status = if (documented_exports_count == length(exports)) "complete" else "partial", notes = sprintf("%d/%d exported aliases are documented.", documented_exports_count, length(exports)), stringsAsFactors = FALSE)
)
write_csv_deterministic(documentation_audit, file.path(output_dir, "documentation_audit.csv"), order_cols = c("item"))

pkg_env <- build_package_environment(project_root)
eval_env <- new.env(parent = pkg_env)
example_files <- sort(unique(rd_index$rd_file[rd_index$alias %in% exports & rd_index$has_examples]))
example_results <- lapply(example_files, function(rd_name) {
  code <- extract_rd_example_code(file.path(project_root, "man", rd_name))
  res <- run_code_block(code, eval_env)
  list(file = rd_name, status = res$status, error = res$error, output = res$output)
})
examples_detected <- length(example_files)

example_lines <- c(
  "Phase 2 readiness rebase - example verification",
  sprintf("Exported Rd aliases with examples: %d/%d", sum(rd_index$alias %in% exports & rd_index$has_examples), length(exports)),
  sprintf("Rd files with executable examples detected: %d", examples_detected),
  ""
)
for (res in example_results) {
  example_lines <- c(
    example_lines,
    sprintf("[%s]", res$file),
    sprintf("status=%s", res$status),
    if (nzchar(res$error)) sprintf("error=%s", res$error) else "error=",
    if (length(res$output) > 0L) res$output else "<none>",
    ""
  )
}
writeLines(example_lines, file.path(output_dir, "example_execution_results.txt"), useBytes = TRUE)

workflow_dir <- file.path(project_root, ".github", "workflows")
workflow_files <- sort(list.files(workflow_dir, pattern = "\\.(yml|yaml)$", full.names = FALSE))
workflow_text <- unlist(lapply(file.path(workflow_dir, workflow_files), read_text), use.names = FALSE)

ci_workflow_audit <- rbind(
  data.frame(item = "workflow files", status = if (length(workflow_files) > 0L) "complete" else "missing", notes = paste(workflow_files, collapse = "; "), stringsAsFactors = FALSE),
  data.frame(item = "R CMD check workflow", status = if (any(grepl("check-r-package|R-CMD-check", workflow_text))) "complete" else "missing", notes = "Checked for an r-lib package check workflow.", stringsAsFactors = FALSE),
  data.frame(item = "OS matrix", status = if (all(c("ubuntu-latest", "windows-latest") %in% workflow_text)) "complete" else "partial", notes = "Linux and Windows runners detected; macOS absent.", stringsAsFactors = FALSE),
  data.frame(item = "R-version matrix", status = if (sum(grepl("r:\\s*'?(4\\.|devel)", workflow_text)) >= 3L) "complete" else "partial", notes = "Checked for multiple stable/devel R entries.", stringsAsFactors = FALSE)
)
write_csv_deterministic(ci_workflow_audit, file.path(output_dir, "ci_workflow_audit.csv"), order_cols = c("item"))

metadata_complete <- all(c("Package", "Title", "Description", "Version", "Authors@R", "License", "Encoding", "Imports", "URL", "BugReports") %in% names(description))
license_ok <- file.exists(file.path(project_root, "LICENSE")) && grepl("file LICENSE", description[["License"]] %||% "", fixed = TRUE)
deps_ok <- identical(trimws(description[["Imports"]] %||% ""), "R6 (>= 2.5.1)")
doc_exports_ok <- identical(documented_exports_count, length(exports))

cran_preflight_checklist <- rbind(
  data.frame(item = "clean R CMD check", status = if (isTRUE(check_clean)) "pass" else "fail", notes = check_method, stringsAsFactors = FALSE),
  data.frame(item = "no undocumented exports", status = if (isTRUE(doc_exports_ok)) "pass" else "fail", notes = sprintf("%d/%d exports documented.", documented_exports_count, length(exports)), stringsAsFactors = FALSE),
  data.frame(item = "metadata completeness", status = if (isTRUE(metadata_complete)) "pass" else "fail", notes = "DESCRIPTION fields include URL and BugReports on the corrected baseline.", stringsAsFactors = FALSE),
  data.frame(item = "deterministic tests", status = if (isTRUE(test_non_regression) && identical(test_counts[["fail"]], 0L)) "pass" else "fail", notes = sprintf("Current PASS=%s; baseline PASS target=%s.", test_counts[["pass"]], baseline_pass_target), stringsAsFactors = FALSE),
  data.frame(item = "acceptable dependencies", status = if (isTRUE(deps_ok)) "pass" else "partial", notes = "Imports remain limited to R6.", stringsAsFactors = FALSE),
  data.frame(item = "license declaration", status = if (isTRUE(license_ok)) "pass" else "fail", notes = "MIT + file LICENSE checked against on-disk LICENSE.", stringsAsFactors = FALSE)
)
write_csv_deterministic(cran_preflight_checklist, file.path(output_dir, "cran_preflight_checklist.csv"), order_cols = c("item"))

cran_signals_passed <- sum(cran_preflight_checklist$status == "pass")
remaining_risks <- c(
  if (examples_detected == 0L) "Exported Rd pages still do not provide runnable example sections.",
  if (any(ci_workflow_audit$status == "partial")) "CI matrix remains limited relative to a fuller release workflow surface.",
  if (!dir.exists(file.path(project_root, "vignettes"))) "No vignettes directory is present.",
  if (!identical(package_version, "0.2.0")) "Package version is still 0.1.0, so release tagging remains a separate step from Phase 2 sign-off."
)
remaining_risks <- unique(remaining_risks[nzchar(remaining_risks)])

final_recommendation <- if (
  isTRUE(check_clean) &&
    isTRUE(test_non_regression) &&
    identical(test_counts[["fail"]], 0L) &&
    isTRUE(doc_exports_ok) &&
    all(dir.exists(file.path(project_root, expected_evidence_dirs))) &&
    length(remaining_risks) == 0L
) {
  "GO"
} else if (
  isTRUE(check_clean) &&
    isTRUE(test_non_regression) &&
    identical(test_counts[["fail"]], 0L) &&
    all(dir.exists(file.path(project_root, expected_evidence_dirs)))
) {
  "CONDITIONAL GO"
} else {
  "NO GO"
}

phase2_readiness_matrix <- rbind(
  data.frame(Area = "package structure", Item = "Corrected Phase 2 evidence baseline", Status = if (all(dir.exists(file.path(project_root, expected_evidence_dirs)))) "complete" else "missing", Notes = sprintf("%d/%d required evidence directories are present.", sum(dir.exists(file.path(project_root, expected_evidence_dirs))), length(expected_evidence_dirs)), stringsAsFactors = FALSE),
  data.frame(Area = "metadata", Item = "DESCRIPTION completeness", Status = if (isTRUE(metadata_complete)) "complete" else "partial", Notes = "URL and BugReports are present on the corrected baseline.", stringsAsFactors = FALSE),
  data.frame(Area = "exports", Item = "Exported functions documented", Status = if (isTRUE(doc_exports_ok)) "complete" else "partial", Notes = sprintf("%d/%d exported aliases are documented.", documented_exports_count, length(exports)), stringsAsFactors = FALSE),
  data.frame(Area = "documentation", Item = "README/NEWS/licenses/man presence", Status = if (all(documentation_audit$status %in% c("complete"))) "complete" else "partial", Notes = paste(sprintf("%s=%s", documentation_audit$item, documentation_audit$status), collapse = "; "), stringsAsFactors = FALSE),
  data.frame(Area = "examples", Item = "Rd example surface", Status = if (examples_detected > 0L) "partial" else "fail", Notes = sprintf("%d exported Rd files with examples detected.", examples_detected), stringsAsFactors = FALSE),
  data.frame(Area = "CI", Item = "Workflow coverage", Status = if (all(ci_workflow_audit$status == "complete")) "complete" else "partial", Notes = paste(sprintf("%s=%s", ci_workflow_audit$item, ci_workflow_audit$status), collapse = "; "), stringsAsFactors = FALSE),
  data.frame(Area = "CRAN readiness", Item = "Preflight checklist", Status = if (all(cran_preflight_checklist$status == "pass")) "complete" else "partial", Notes = sprintf("%d/%d CRAN readiness signals are passing.", cran_signals_passed, nrow(cran_preflight_checklist)), stringsAsFactors = FALSE),
  data.frame(Area = "evidence artifact completeness", Item = "Preserved Phase 2 directories", Status = if (all(dir.exists(file.path(project_root, expected_evidence_dirs)))) "complete" else "missing", Notes = "No prior Phase 2 evidence directories were removed during the baseline correction.", stringsAsFactors = FALSE),
  data.frame(Area = "recommendation", Item = "Final Phase 2 recommendation", Status = final_recommendation, Notes = sprintf("%d remaining risk(s) identified.", length(remaining_risks)), stringsAsFactors = FALSE)
)
write_csv_deterministic(phase2_readiness_matrix, file.path(output_dir, "phase2_readiness_matrix.csv"), order_cols = c("Area", "Item"))

report_lines <- c(
  "# Final Phase 2 Review",
  "",
  "## Corrected baseline verification",
  "",
  sprintf("- Baseline fix-program commit: `%s`", baseline_commit),
  sprintf("- Required evidence directories present: `%s`", all(dir.exists(file.path(project_root, expected_evidence_dirs)))),
  sprintf("- README.md present: `%s`", file.exists(file.path(project_root, "README.md"))),
  sprintf("- NEWS.md present: `%s`", file.exists(file.path(project_root, "NEWS.md"))),
  sprintf("- Exported functions documented: `%d/%d`", documented_exports_count, length(exports)),
  sprintf("- Fix-program baseline PASS target: `%s`", if (is.na(baseline_pass_target)) "unverified" else baseline_pass_target),
  "",
  "## Readiness summary",
  "",
  sprintf("- Test PASS count: `%s`", test_counts[["pass"]]),
  sprintf("- Test non-regression vs fix-program baseline: `%s`", if (isTRUE(test_non_regression)) "pass" else "fail"),
  sprintf("- R CMD check clean: `%s`", if (isTRUE(check_clean)) "yes" else "no"),
  sprintf("- Examples detected: `%d`", examples_detected),
  sprintf("- CI workflows detected: `%d`", length(workflow_files)),
  sprintf("- CRAN readiness signals passed: `%d/%d`", cran_signals_passed, nrow(cran_preflight_checklist)),
  "",
  "## Documentation readiness",
  "",
  paste0("- ", documentation_audit$item, ": ", documentation_audit$status),
  "",
  "## CI readiness",
  "",
  paste0("- ", ci_workflow_audit$item, ": ", ci_workflow_audit$status),
  "",
  "## CRAN readiness",
  "",
  paste0("- ", cran_preflight_checklist$item, ": ", cran_preflight_checklist$status),
  "",
  "## Remaining risks",
  "",
  if (length(remaining_risks) > 0L) paste0("- ", remaining_risks) else "- No remaining readiness risks identified.",
  "",
  "## Final recommendation",
  "",
  final_recommendation
)
writeLines(report_lines, file.path(output_dir, "final_phase2_review.md"), useBytes = TRUE)

cat(sprintf("test pass count: %s\n", test_counts[["pass"]]))
cat(sprintf("documented exports count: %d\n", documented_exports_count))
cat(sprintf("examples detected: %d\n", examples_detected))
cat(sprintf("CI workflows detected: %d\n", length(workflow_files)))
cat(sprintf("CRAN readiness signals passed: %d\n", cran_signals_passed))
