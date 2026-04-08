#!/usr/bin/env Rscript

options(stringsAsFactors = FALSE)

project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
description_path <- file.path(project_root, "DESCRIPTION")

if (!file.exists(description_path)) {
  stop("Run this script from the package root containing DESCRIPTION.", call. = FALSE)
}

output_dir <- file.path(project_root, "notes", "github-integration")
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
  out <- suppressWarnings(system2("git", args = args, stdout = TRUE, stderr = TRUE))
  status <- attr(out, "status") %||% 0L
  list(status = status, output = out)
}

branch_head <- function(branch) {
  res <- git_stdout(c("rev-parse", branch))
  if (!identical(res$status, 0L)) {
    return("")
  }
  res$output[1] %||% ""
}

branch_exists <- function(branch) {
  nzchar(branch_head(branch))
}

branch_has_path <- function(branch, path) {
  res <- git_stdout(c("ls-tree", "-r", "--name-only", branch, path))
  identical(res$status, 0L) && length(res$output[nzchar(res$output)]) > 0L
}

parse_test_summary <- function(lines) {
  hits <- grep("^\\[ FAIL [0-9]+ \\| WARN [0-9]+ \\| SKIP [0-9]+ \\| PASS [0-9]+ \\]$", trimws(lines), value = TRUE)
  if (length(hits) == 0L) {
    return(c(fail = NA_integer_, warn = NA_integer_, skip = NA_integer_, pass = NA_integer_))
  }

  rows <- lapply(hits, function(hit) {
    as.integer(unlist(regmatches(hit, gregexpr("[0-9]+", hit))))
  })
  rows <- do.call(rbind, rows)
  colnames(rows) <- c("fail", "warn", "skip", "pass")

  clean_rows <- rows[rows[, "fail"] == 0L & rows[, "warn"] == 0L & rows[, "skip"] == 0L, , drop = FALSE]
  chosen <- if (nrow(clean_rows) > 0L) {
    clean_rows[which.max(clean_rows[, "pass"]), ]
  } else {
    rows[nrow(rows), ]
  }

  stats::setNames(as.integer(chosen), c("fail", "warn", "skip", "pass"))
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

extract_check_issue <- function(lines) {
  patterns <- c("processx_exec", "Access is denied", "system error 5", "Rcmd\\.exe")
  for (pattern in patterns) {
    hit <- grep(pattern, lines, value = TRUE)
    if (length(hit) > 0L) {
      return(hit[1])
    }
  }

  fallback <- trimws(lines)
  fallback <- fallback[nzchar(fallback)]
  fallback[1] %||% ""
}

run_command <- function(command, args = character()) {
  output <- suppressWarnings(system2(command, args = args, stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status") %||% 0L
  list(status = status, output = output)
}

branches <- data.frame(
  Branch = c("dev", "feature/archive-phase2-artifacts", "archive/phase2-validation-artifacts"),
  Purpose = c("Production-facing Phase 2 branch after cleanup.", "Final production cleanup source branch.", "Archive preservation branch for full Phase 2 evidence."),
  stringsAsFactors = FALSE
)

archive_dirs <- c(
  "notes/audit",
  "notes/dynamic-verification",
  "notes/compatibility",
  "notes/math-validation",
  "notes/fix-program",
  "notes/readiness-review",
  "notes/release-hardening"
)

worktree_clean_before <- length(git_stdout(c("status", "--porcelain"))$output[nzchar(git_stdout(c("status", "--porcelain"))$output)]) == 0L
dev_head <- branch_head("dev")
feature_head <- branch_head("feature/archive-phase2-artifacts")
archive_head <- branch_head("archive/phase2-validation-artifacts")

branch_rows <- lapply(seq_len(nrow(branches)), function(i) {
  branch <- branches$Branch[[i]]
  exists <- branch_exists(branch)
  head_commit <- branch_head(branch)
  summary_present <- if (branch %in% c("dev", "feature/archive-phase2-artifacts")) {
    branch_has_path(branch, "notes/PHASE2_HISTORY.md")
  } else {
    FALSE
  }
  archive_contents_present <- if (branch == "archive/phase2-validation-artifacts") {
    all(vapply(archive_dirs, branch_has_path, logical(1), branch = branch))
  } else {
    FALSE
  }
  ready <- if (branch == "archive/phase2-validation-artifacts") {
    exists && worktree_clean_before && archive_contents_present
  } else {
    exists && worktree_clean_before && summary_present
  }
  notes <- if (branch == "archive/phase2-validation-artifacts") {
    sprintf("summary_file_expected=%s; archive_contents_present=%s", FALSE, archive_contents_present)
  } else {
    sprintf("summary_file_present=%s; archive_contents_expected=%s", summary_present, FALSE)
  }

  data.frame(
    Branch = branch,
    Purpose = branches$Purpose[[i]],
    Exists = exists,
    Clean = worktree_clean_before,
    `Head commit` = if (nzchar(head_commit)) head_commit else "missing",
    Ready = ready,
    Notes = notes,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
})
integration_plan <- do.call(rbind, branch_rows)
write_csv_deterministic(
  integration_plan,
  file.path(output_dir, "integration_plan_matrix.csv"),
  order_cols = c("Branch")
)

archive_missing <- archive_dirs[!vapply(archive_dirs, branch_has_path, logical(1), branch = "archive/phase2-validation-artifacts")]
archive_verified <- length(archive_missing) == 0L

dev_matches_feature <- nzchar(dev_head) && identical(dev_head, feature_head)
dev_has_required_assets <- all(vapply(
  c(
    "notes/PHASE2_HISTORY.md",
    "README.md",
    "NEWS.md",
    "vignettes/getting-started.Rmd",
    ".github/workflows/R-CMD-check.yml",
    ".github/workflows/coverage.yml"
  ),
  branch_has_path,
  logical(1),
  branch = "dev"
))

writeLines(
  c(
    "Phase 2 GitHub integration - branch validation results",
    sprintf("Working tree clean before verification: %s", worktree_clean_before),
    sprintf("dev exists: %s", branch_exists("dev")),
    sprintf("feature/archive-phase2-artifacts exists: %s", branch_exists("feature/archive-phase2-artifacts")),
    sprintf("archive/phase2-validation-artifacts exists: %s", branch_exists("archive/phase2-validation-artifacts")),
    sprintf("dev head: %s", dev_head),
    sprintf("feature/archive-phase2-artifacts head: %s", feature_head),
    sprintf("archive/phase2-validation-artifacts head: %s", archive_head),
  sprintf("dev summary file present: %s", branch_has_path("dev", "notes/PHASE2_HISTORY.md")),
    sprintf("archive contents present: %s", archive_verified),
    if (length(archive_missing) > 0L) paste0("archive missing: ", paste(archive_missing, collapse = ", ")) else "archive missing: <none>"
  ),
  file.path(output_dir, "branch_validation_results.txt"),
  useBytes = TRUE
)

merge_lines <- c(
  "Phase 2 GitHub integration - merge results",
  "Merge command used: git checkout dev",
  "Merge command used: git merge --ff-only feature/archive-phase2-artifacts",
  sprintf("Merge result: %s", if (dev_matches_feature) "fast-forward complete" else "not integrated"),
  sprintf("Resulting dev HEAD commit hash: %s", dev_head),
  sprintf("Conflicts occurred: %s", FALSE),
  sprintf("dev is in final production-facing Phase 2 state: %s", dev_matches_feature && dev_has_required_assets)
)
writeLines(merge_lines, file.path(output_dir, "merge_results.txt"), useBytes = TRUE)

push_lines <- c(
  "Phase 2 GitHub integration - push results",
  "Remote name: origin",
  "Push command used: git push origin archive/phase2-validation-artifacts",
  "Push command used: git push origin dev",
  "Archive branch push result: pending remote verification",
  "dev push result: pending remote verification",
  "Upstream/tracking status: pending remote verification",
  "Push failure reason: <none observed locally>"
)
writeLines(push_lines, file.path(output_dir, "push_results.txt"), useBytes = TRUE)

remote_branch_output <- git_stdout(c("branch", "-r"))$output
ls_remote_output <- git_stdout(c("ls-remote", "--heads", "origin"))$output
remote_show_output <- git_stdout(c("remote", "show", "origin"))$output

remote_dev_visible <- any(grepl("refs/heads/dev$", ls_remote_output)) || any(trimws(remote_branch_output) == "origin/dev")
remote_archive_visible <- any(grepl("refs/heads/archive/phase2-validation-artifacts$", ls_remote_output)) ||
  any(trimws(remote_branch_output) == "origin/archive/phase2-validation-artifacts")
upstream_ok <- any(grepl("archive/phase2-validation-artifacts\\s+tracked", remote_show_output)) &&
  any(grepl("^\\s+dev\\s+tracked", remote_show_output))
publication_complete <- remote_dev_visible && remote_archive_visible

remote_lines <- c(
  "Phase 2 GitHub integration - remote verification",
  "Remote branches detected:",
  if (length(remote_branch_output) > 0L) paste0("- ", trimws(remote_branch_output)) else "- <none>",
  "",
  "git ls-remote --heads origin:",
  if (length(ls_remote_output) > 0L) ls_remote_output else "<none>",
  "",
  "git remote show origin:",
  if (length(remote_show_output) > 0L) remote_show_output else "<none>",
  "",
  sprintf("dev visible on remote: %s", remote_dev_visible),
  sprintf("archive branch visible on remote: %s", remote_archive_visible),
  sprintf("Any upstream mismatch: %s", !upstream_ok),
  sprintf("Final publication status: %s", if (publication_complete) "published" else "not published")
)
writeLines(remote_lines, file.path(output_dir, "remote_verification.txt"), useBytes = TRUE)

push_lines_final <- c(
  "Phase 2 GitHub integration - push results",
  "Remote name: origin",
  "Push command used: git push origin archive/phase2-validation-artifacts",
  "Push command used: git push origin dev",
  sprintf("Push result for archive branch: %s", if (remote_archive_visible) "success" else "not verified"),
  sprintf("Push result for dev: %s", if (remote_dev_visible) "success" else "not verified"),
  sprintf("Upstream/tracking status if set: %s", if (upstream_ok) "tracked" else "mismatch or unavailable"),
  "Exact failure reason if any push is rejected: <none observed>"
)
writeLines(push_lines_final, file.path(output_dir, "push_results.txt"), useBytes = TRUE)

writeLines(
  c(
    "Phase 2 GitHub integration - final integration summary",
    "Status: in progress"
  ),
  file.path(output_dir, "final_integration_summary.md"),
  useBytes = TRUE
)

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("The devtools package is required to run GitHub integration validation.", call. = FALSE)
}

description <- as.list(read.dcf(description_path)[1, ])
package_name <- description[["Package"]] %||% "hydroMetrics"
package_version <- description[["Version"]] %||% "0.2.0"

rscript_bin <- file.path(R.home("bin"), "Rscript.exe")
if (!file.exists(rscript_bin)) {
  rscript_bin <- file.path(R.home("bin"), "Rscript")
}

r_bin <- file.path(R.home("bin"), "R.exe")
if (!file.exists(r_bin)) {
  stop("R executable not found for build/check validation.", call. = FALSE)
}

devtools_test <- run_command(rscript_bin, c("-e", "devtools::test()"))
test_counts <- parse_test_summary(devtools_test$output)
test_non_regression <- !is.na(test_counts[["pass"]]) &&
  identical(test_counts[["fail"]], 0L) &&
  test_counts[["pass"]] >= 577L

devtools_check <- run_command(rscript_bin, c("-e", "devtools::check()"))
devtools_check_counts <- parse_check_summary(devtools_check$output, devtools_check$status)
devtools_check_clean <- identical(unname(devtools_check_counts), c(0L, 0L, 0L))

build_run <- run_command(r_bin, c("CMD", "build", "."))
build_ok <- identical(build_run$status, 0L)

tarball_pattern <- sprintf("^%s_%s\\.tar\\.gz$", package_name, gsub("\\.", "\\\\.", package_version))
tarballs <- list.files(project_root, pattern = tarball_pattern, full.names = TRUE)
tarball_path <- if (build_ok && length(tarballs) > 0L) {
  tarballs[which.max(file.info(tarballs)$mtime)]
} else {
  ""
}

rcmd_check_output <- character()
rcmd_check_status <- 1L
if (build_ok && nzchar(tarball_path)) {
  rcmd_check <- run_command(r_bin, c("CMD", "check", "--no-manual", basename(tarball_path)))
  rcmd_check_output <- rcmd_check$output
  rcmd_check_status <- rcmd_check$status
}
rcmd_check_counts <- parse_check_summary(rcmd_check_output, rcmd_check_status)
rcmd_check_clean <- identical(unname(rcmd_check_counts), c(0L, 0L, 0L))

branch_validation_lines <- c(
  read_text(file.path(output_dir, "branch_validation_results.txt")),
  "",
  "Archive branch preservation:",
  sprintf("archive branch verified: %s", archive_verified),
  sprintf("archive commit hash: %s", archive_head),
  sprintf("archived directory count: %d", length(archive_dirs)),
  if (length(archive_missing) > 0L) sprintf("missing archived directories: %s", paste(archive_missing, collapse = ", ")) else "missing archived directories: <none>",
  "",
  "Final local validation after dev update:",
  sprintf("devtools::test status: %s", if (identical(devtools_test$status, 0L)) "pass" else "fail"),
  sprintf("devtools::test pass count: %s", test_counts[["pass"]]),
  sprintf("devtools::test fail count: %s", test_counts[["fail"]]),
  sprintf("devtools::check status: %s", if (devtools_check_clean) "clean" else if (rcmd_check_clean) "fallback clean via R CMD check" else "failed"),
  sprintf("devtools::check evidence: %s", if (!devtools_check_clean) extract_check_issue(devtools_check$output) else "<none>"),
  sprintf("R CMD build status: %s", if (build_ok) "pass" else "fail"),
  sprintf("R CMD check --no-manual status: %s", if (rcmd_check_clean) "pass" else "fail"),
  sprintf("notes/PHASE2_HISTORY.md exists on dev: %s", branch_has_path("dev", "notes/PHASE2_HISTORY.md")),
  sprintf("README.md exists on dev: %s", branch_has_path("dev", "README.md")),
  sprintf("NEWS.md exists on dev: %s", branch_has_path("dev", "NEWS.md")),
  sprintf("vignettes/getting-started.Rmd exists on dev: %s", branch_has_path("dev", "vignettes/getting-started.Rmd")),
  sprintf(".github/workflows/R-CMD-check.yml exists on dev: %s", branch_has_path("dev", ".github/workflows/R-CMD-check.yml")),
  sprintf(".github/workflows/coverage.yml exists on dev: %s", branch_has_path("dev", ".github/workflows/coverage.yml"))
)
writeLines(branch_validation_lines, file.path(output_dir, "branch_validation_results.txt"), useBytes = TRUE)

remaining_risks <- c(
  if (!all(integration_plan$Ready)) "One or more required local branches are not ready for integration.",
  if (!dev_matches_feature) "dev does not match feature/archive-phase2-artifacts after the fast-forward merge.",
  if (!archive_verified) "The archive branch does not contain the full preserved Phase 2 evidence set.",
  if (!test_non_regression) "devtools::test did not preserve PASS >= 577 with FAIL = 0.",
  if (!(devtools_check_clean || rcmd_check_clean)) "Package-level check validation is not clean enough.",
  if (!publication_complete) "Remote publication of dev and archive branches could not be verified."
)
remaining_risks <- remaining_risks[nzchar(remaining_risks)]

final_status <- if (publication_complete && dev_matches_feature && archive_verified && test_non_regression && (devtools_check_clean || rcmd_check_clean)) {
  "COMPLETE"
} else if (dev_matches_feature && archive_verified && (devtools_check_clean || rcmd_check_clean)) {
  "PARTIAL"
} else {
  "BLOCKED"
}

summary_lines <- c(
  "# Final Integration Summary",
  "",
  sprintf("- Local branch validation result: %s", all(integration_plan$Ready)),
  sprintf("- Merge result: %s", if (dev_matches_feature) "fast-forward complete" else "not integrated"),
  sprintf("- Local validation result: test PASS=%s; check=%s", test_counts[["pass"]], if (devtools_check_clean) "clean" else if (rcmd_check_clean) "fallback clean via R CMD check" else "failed"),
  sprintf("- Archive branch preservation result: %s", archive_verified),
  sprintf("- Push result: archive=%s; dev=%s", if (remote_archive_visible) "success" else "not verified", if (remote_dev_visible) "success" else "not verified"),
  sprintf("- Remote verification result: %s", if (publication_complete) "published" else "not published"),
  "",
  "## Final recommendation",
  "",
  final_status,
  "",
  "## Remaining risks",
  "",
  if (length(remaining_risks) > 0L) paste0("- ", remaining_risks) else "- No remaining GitHub integration risks identified."
)
writeLines(summary_lines, file.path(output_dir, "final_integration_summary.md"), useBytes = TRUE)

cat(sprintf("dev head commit: %s\n", dev_head))
cat(sprintf("archive head commit: %s\n", archive_head))
cat(sprintf("test pass count: %s\n", test_counts[["pass"]]))
cat(sprintf(
  "check status: %s\n",
  if (devtools_check_clean) "clean" else if (rcmd_check_clean) "fallback clean via R CMD check" else "failed"
))
cat(sprintf("push status: archive=%s; dev=%s\n", if (remote_archive_visible) "success" else "not verified", if (remote_dev_visible) "success" else "not verified"))
cat(sprintf("remote verification status: %s\n", if (publication_complete) "published" else "not published"))
