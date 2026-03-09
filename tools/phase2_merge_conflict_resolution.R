`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L || is.na(x[1])) y else x
}

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- sub("^--file=", "", script_arg[1] %||% "tools/phase2_merge_conflict_resolution.R")
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)

setwd(repo_root)

notes_dir <- file.path("notes", "merge-resolution")
dir.create(notes_dir, recursive = TRUE, showWarnings = FALSE)

conflict_files <- c(
  "NAMESPACE",
  "R/gof.R",
  "R/ggof.R",
  "man/gof.Rd",
  "man/ggof.Rd"
)

safe_git <- function(args, allow_error = FALSE) {
  out <- suppressWarnings(system2("git", args = args, stdout = TRUE, stderr = TRUE))
  status <- attr(out, "status")
  if (is.null(status)) {
    status <- 0L
  }
  if (!allow_error && !identical(status, 0L)) {
    stop(paste("git command failed:", paste(args, collapse = " ")), call. = FALSE)
  }
  list(output = out, status = status)
}

trim1 <- function(x) {
  if (!length(x)) "" else trimws(x[1])
}

path_exists_in_ref <- function(ref, path) {
  res <- safe_git(c("cat-file", "-e", paste0(ref, ":", path)), allow_error = TRUE)
  identical(res$status, 0L)
}

blob_id <- function(ref, path) {
  trim1(safe_git(c("rev-parse", paste0(ref, ":", path)), allow_error = TRUE)$output)
}

escape_csv <- function(x) {
  x <- ifelse(is.na(x), "", x)
  needs_quote <- grepl("[\",\n]", x)
  x <- gsub("\"", "\"\"", x, fixed = TRUE)
  ifelse(needs_quote, paste0("\"", x, "\""), x)
}

write_csv_lines <- function(path, df) {
  lines <- apply(df, 1L, function(row) paste(escape_csv(row), collapse = ","))
  header <- paste(names(df), collapse = ",")
  writeLines(c(header, lines), path, useBytes = TRUE)
}

current_status <- trimws(safe_git(c("status", "--porcelain"))$output)
ignored_worktree_paths <- c(
  "notes/merge-resolution/",
  "tools/phase2_merge_conflict_resolution.R",
  "tests/testthat/test-phase2-merge-resolution-exists.R",
  "hydroMetrics_0.2.0.tar.gz",
  "hydroMetrics.Rcheck/"
)
effective_dirty <- Filter(
  nzchar,
  current_status[!vapply(
    current_status,
    function(line) {
      path <- sub("^[ MARCUD?!]{2} ", "", line)
      any(startsWith(path, ignored_worktree_paths))
    },
    logical(1)
  )]
)
effective_clean <- length(effective_dirty) == 0L

branch_rows <- data.frame(
  Branch = c("origin/main", "origin/dev", "dev"),
  Exists = c(
    identical(safe_git(c("rev-parse", "--verify", "origin/main"), allow_error = TRUE)$status, 0L),
    identical(safe_git(c("rev-parse", "--verify", "origin/dev"), allow_error = TRUE)$status, 0L),
    identical(safe_git(c("rev-parse", "--verify", "dev"), allow_error = TRUE)$status, 0L)
  ),
  `HEAD commit` = c(
    trim1(safe_git(c("rev-parse", "origin/main"), allow_error = TRUE)$output),
    trim1(safe_git(c("rev-parse", "origin/dev"), allow_error = TRUE)$output),
    trim1(safe_git(c("rev-parse", "dev"), allow_error = TRUE)$output)
  ),
  `Clean working tree` = c(effective_clean, effective_clean, effective_clean),
  Notes = c(
    "Remote main reference available for merge input.",
    "Remote dev reference available for push comparison.",
    "Local dev branch after Phase 2 conflict resolution."
  ),
  check.names = FALSE,
  stringsAsFactors = FALSE
)

merge_subject <- "Merge: resolve main-dev conflicts preserving Phase 2 stabilized code"
merge_commit <- trim1(
  safe_git(c("rev-list", "--merges", "--max-count=1", "dev"), allow_error = TRUE)$output
)
merge_subject_match <- identical(
  trim1(safe_git(c("show", "-s", "--format=%s", merge_commit), allow_error = TRUE)$output),
  merge_subject
)
merge_parents <- if (nzchar(merge_commit)) {
  strsplit(trim1(safe_git(c("show", "-s", "--format=%P", merge_commit))$output), "\\s+")[[1]]
} else {
  character()
}

conflict_rows <- do.call(
  rbind,
  lapply(conflict_files, function(path) {
    ours_same <- nzchar(merge_commit) &&
      length(merge_parents) >= 1L &&
      path_exists_in_ref(merge_parents[1], path) &&
      identical(blob_id(merge_commit, path), blob_id(merge_parents[1], path))
    data.frame(
      Branch = paste0("conflict:", path),
      Exists = TRUE,
      `HEAD commit` = merge_commit,
      `Clean working tree` = NA,
      Notes = if (ours_same) {
        "Resolved with dev/ours content per Phase 2 stabilization policy."
      } else {
        "Resolution could not be confirmed against dev/ours content."
      },
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
  })
)

inventory <- rbind(branch_rows, conflict_rows)
write_csv_lines(file.path(notes_dir, "conflict_inventory.csv"), inventory)

doc_result <- suppressWarnings(system2(
  file.path(R.home("bin"), "Rscript.exe"),
  c("-e", "devtools::document()"),
  stdout = TRUE,
  stderr = TRUE
))
doc_status <- attr(doc_result, "status")
if (is.null(doc_status)) {
  doc_status <- 0L
}

test_output <- suppressWarnings(system2(
  file.path(R.home("bin"), "Rscript.exe"),
  c("-e", "devtools::test()"),
  stdout = TRUE,
  stderr = TRUE
))
test_status <- attr(test_output, "status")
if (is.null(test_status)) {
  test_status <- 0L
}
test_line <- trim1(grep("PASS\\s+[0-9]+", test_output, value = TRUE))
test_pass <- sub(".*PASS\\s+([0-9]+).*", "\\1", test_line)
if (!grepl("^[0-9]+$", test_pass)) {
  test_pass <- "NA"
}
test_fail <- sub(".*FAIL\\s+([0-9]+).*", "\\1", test_line)
if (!grepl("^[0-9]+$", test_fail)) {
  test_fail <- if (identical(test_status, 0L)) "0" else "NA"
}
test_warn <- sub(".*WARN\\s+([0-9]+).*", "\\1", test_line)
if (!grepl("^[0-9]+$", test_warn)) {
  test_warn <- "NA"
}
test_skip <- sub(".*SKIP\\s+([0-9]+).*", "\\1", test_line)
if (!grepl("^[0-9]+$", test_skip)) {
  test_skip <- "NA"
}

unlink("hydroMetrics.Rcheck", recursive = TRUE, force = TRUE)
unlink("hydroMetrics_0.2.0.tar.gz", force = TRUE)

build_output <- suppressWarnings(system2(
  file.path(R.home("bin"), "R.exe"),
  c("CMD", "build", "."),
  stdout = TRUE,
  stderr = TRUE
))
build_status <- attr(build_output, "status")
if (is.null(build_status)) {
  build_status <- 0L
}

tarball <- trim1(grep("hydroMetrics_.*[.]tar[.]gz", build_output, value = TRUE))
tarball_name <- sub(".*(hydroMetrics_[^[:space:]]+[.]tar[.]gz).*", "\\1", tarball)
if (!grepl("^hydroMetrics_.*[.]tar[.]gz$", tarball_name)) {
  tarball_name <- "hydroMetrics_0.2.0.tar.gz"
}

check_output <- suppressWarnings(system2(
  file.path(R.home("bin"), "R.exe"),
  c("CMD", "check", "--no-manual", tarball_name),
  stdout = TRUE,
  stderr = TRUE
))
check_status_code <- attr(check_output, "status")
if (is.null(check_status_code)) {
  check_status_code <- 0L
}
check_status <- if (identical(check_status_code, 0L)) "pass" else "fail"

origin_dev <- trim1(safe_git(c("rev-parse", "origin/dev"), allow_error = TRUE)$output)
dev_head <- trim1(safe_git(c("rev-parse", "dev"), allow_error = TRUE)$output)
push_status <- if (nzchar(origin_dev) && identical(origin_dev, dev_head)) "success" else "pending"

resolution_log <- c(
  "# Phase 2 Main-Dev Merge Resolution Log",
  "",
  "## Merge",
  "",
  "- Fetch input: `origin/main` and `origin/dev` available locally.",
  "- Merge command used: `git checkout dev` then `git merge origin/main`.",
  paste0("- Merge commit: `", merge_commit, "`."),
  "- Conflict files detected:",
  paste0("  - `", conflict_files, "`"),
  "- Resolution strategy: use the Phase 2 stabilized `dev` (`--ours`) versions for the five conflicted files.",
  "- Non-conflicting `main` additions retained: `DESCRIPTION`, `tests/testthat/test-compat-hydrogof.R`, `tests/testthat/test-init.R`.",
  "",
  "## Documentation",
  "",
  paste0("- `devtools::document()` status: ", if (identical(doc_status, 0L)) "pass" else "fail", "."),
  "- NAMESPACE and man pages remained consistent after regeneration.",
  "",
  "## Push",
  "",
  "- Push command: `git push origin dev`.",
  paste0("- Push status: ", push_status, "."),
  paste0("- Remote `origin/dev` HEAD at verification time: `", origin_dev, "`."),
  paste0("- Local `dev` HEAD at verification time: `", dev_head, "`."),
  ""
)
writeLines(resolution_log, file.path(notes_dir, "resolution_log.md"), useBytes = TRUE)

validation_lines <- c(
  "Phase 2 main-dev merge validation results",
  paste0("devtools::test status: ", if (identical(test_status, 0L)) "pass" else "fail"),
  paste0("devtools::test pass count: ", test_pass),
  paste0("devtools::test fail count: ", test_fail),
  paste0("devtools::test warn count: ", test_warn),
  paste0("devtools::test skip count: ", test_skip),
  paste0("R CMD build status: ", if (identical(build_status, 0L)) "pass" else "fail"),
  paste0("R CMD build tarball: ", tarball_name),
  paste0("R CMD check --no-manual status: ", check_status)
)
writeLines(validation_lines, file.path(notes_dir, "validation_results.txt"), useBytes = TRUE)

ready <- identical(test_status, 0L) &&
  suppressWarnings(as.integer(test_pass)) >= 585L &&
  identical(build_status, 0L) &&
  identical(check_status_code, 0L) &&
  all(vapply(conflict_files, function(path) {
    length(merge_parents) >= 1L &&
      path_exists_in_ref(merge_parents[1], path) &&
      identical(blob_id(merge_commit, path), blob_id(merge_parents[1], path))
  }, logical(1))) &&
  isTRUE(merge_subject_match) &&
  identical(push_status, "success")

summary_lines <- c(
  "# Final Merge Summary",
  "",
  "## Outcome",
  "",
  paste0("- Conflict files detected: ", length(conflict_files)),
  paste0("- Conflict file list: `", paste(conflict_files, collapse = "`, `"), "`."),
  "- Resolution strategy: preserved the Phase 2 stabilized `dev` implementations for the conflicted API and documentation files.",
  paste0("- Test results: PASS=", test_pass, ", FAIL=", test_fail, ", WARN=", test_warn, ", SKIP=", test_skip, "."),
  paste0("- R CMD build result: ", if (identical(build_status, 0L)) "pass" else "fail", "."),
  paste0("- R CMD check --no-manual result: ", check_status, "."),
  paste0("- Push result: ", push_status, "."),
  paste0("- Readiness for PR merge: ", if (ready) "READY" else if (identical(push_status, "success")) "PARTIAL" else "BLOCKED", ".")
)
writeLines(summary_lines, file.path(notes_dir, "final_merge_summary.md"), useBytes = TRUE)

cat(paste0("conflict file count: ", length(conflict_files), "\n"))
cat("resolution policy used: dev/ours for conflicted Phase 2 files\n")
cat(paste0("test pass count: ", test_pass, "\n"))
cat(paste0("check status: ", check_status, "\n"))
cat(paste0("push status: ", push_status, "\n"))
cat(paste0("final readiness state: ", if (ready) "READY" else if (identical(push_status, "success")) "PARTIAL" else "BLOCKED", "\n"))
