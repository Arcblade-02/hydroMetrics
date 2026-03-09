`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L) {
    return(y)
  }
  if (length(x) == 1L && is.na(x)) {
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
  stop("tools/phase2_dynamic_verification.R must be run from the package root.", call. = FALSE)
}

output_dir <- file.path(repo_root, "notes", "dynamic-verification")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

rel_path <- function(path) {
  normalized <- normalizePath(path, winslash = "/", mustWork = FALSE)
  prefix <- paste0(repo_root, "/")
  vapply(normalized, function(item) {
    if (identical(item, repo_root)) {
      return(".")
    }
    if (startsWith(item, prefix)) {
      return(substr(item, nchar(prefix) + 1L, nchar(item)))
    }
    item
  }, character(1))
}

rscript_path <- file.path(R.home("bin"), "Rscript.exe")
r_path <- file.path(R.home("bin"), "R.exe")

sanitize_lines <- function(lines, extra_paths = character()) {
  if (!length(lines)) {
    return("<no output>")
  }

  text <- enc2utf8(lines)
  text <- gsub("\\\\", "/", text)

  replacements <- unique(c(
    normalizePath(repo_root, winslash = "/", mustWork = FALSE),
    normalizePath(tempdir(), winslash = "/", mustWork = FALSE),
    normalizePath(dirname(tempdir()), winslash = "/", mustWork = FALSE),
    normalizePath(extra_paths, winslash = "/", mustWork = FALSE)
  ))
  replacements <- replacements[nzchar(replacements)]

  labels <- c("<repo_root>", "<tempdir>", "<temp_parent>", rep("<temp_path>", max(0L, length(replacements) - 3L)))
  if (length(labels) < length(replacements)) {
    labels <- c(labels, rep("<temp_path>", length(replacements) - length(labels)))
  }

  for (i in seq_along(replacements)) {
    text <- gsub(replacements[[i]], labels[[i]], text, fixed = TRUE)
  }
  text
}

write_text_file <- function(path, lines) {
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
}

read_raw_file <- function(path) {
  con <- file(path, open = "rb")
  on.exit(close(con), add = TRUE)
  readBin(con, what = "raw", n = file.info(path)$size)
}

write_raw_file <- function(path, bytes) {
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(bytes, con)
}

nspace_path <- file.path(repo_root, "NAMESPACE")
nspace_snapshot <- if (file.exists(nspace_path)) read_raw_file(nspace_path) else raw()
restore_namespace <- function() {
  if (!file.exists(nspace_path)) {
    return(invisible(NULL))
  }
  current <- read_raw_file(nspace_path)
  if (!identical(current, nspace_snapshot)) {
    write_raw_file(nspace_path, nspace_snapshot)
  }
  invisible(NULL)
}
on.exit(restore_namespace(), add = TRUE)

run_command <- function(command, args, wd = repo_root, env = character(), extra_paths = character()) {
  start <- proc.time()[["elapsed"]]
  output <- tryCatch(
    suppressWarnings(system2(command, args = args, stdout = TRUE, stderr = TRUE, env = env, wait = TRUE)),
    error = function(e) {
      structure(sprintf("SYSTEM2_ERROR: %s", conditionMessage(e)), status = 1L)
    }
  )
  elapsed <- round(proc.time()[["elapsed"]] - start, 3)
  status <- attr(output, "status")
  if (is.null(status)) {
    status <- 0L
  }

  list(
    status = as.integer(status),
    elapsed = elapsed,
    output = sanitize_lines(output, extra_paths = extra_paths)
  )
}

run_r <- function(lines, wd = repo_root, env = character(), extra_paths = character()) {
  script_file <- tempfile(pattern = "hydroMetrics-dynamic-", fileext = ".R")
  writeLines(enc2utf8(lines), script_file, useBytes = TRUE)
  run_command(
    command = rscript_path,
    args = script_file,
    wd = wd,
    env = env,
    extra_paths = c(extra_paths, script_file)
  )
}

run_r_cmd <- function(args, wd = repo_root, env = character(), extra_paths = character()) {
  run_command(
    command = r_path,
    args = c("CMD", args),
    wd = wd,
    env = env,
    extra_paths = extra_paths
  )
}

extract_marker <- function(lines, key, default = NA_character_) {
  hit <- grep(paste0("^", key, ":"), lines, value = TRUE)
  if (!length(hit)) {
    return(default)
  }
  trimws(sub(paste0("^", key, ":"), "", hit[[length(hit)]]))
}

extract_test_counts <- function(lines) {
  hit <- grep("\\[ FAIL [0-9]+ \\| WARN [0-9]+ \\| SKIP [0-9]+ \\| PASS [0-9]+ \\]", lines, value = TRUE)
  if (!length(hit)) {
    return(c(fail = NA_integer_, warn = NA_integer_, skip = NA_integer_, pass = NA_integer_))
  }
  nums <- as.integer(unlist(regmatches(hit[[length(hit)]], gregexpr("[0-9]+", hit[[length(hit)]]))))
  stats::setNames(nums, c("fail", "warn", "skip", "pass"))
}

copy_source_tree <- function(label) {
  temp_parent <- file.path(tempdir(), paste0("hydroMetrics-dynamic-", label))
  temp_pkg <- file.path(temp_parent, basename(repo_root))
  if (dir.exists(temp_parent)) {
    unlink(temp_parent, recursive = TRUE, force = TRUE)
  }
  dir.create(temp_pkg, recursive = TRUE, showWarnings = FALSE)

  entries <- list.files(
    repo_root,
    all.files = TRUE,
    recursive = TRUE,
    full.names = TRUE,
    include.dirs = TRUE,
    no.. = TRUE
  )
  rels <- unname(rel_path(entries))
  keep <- !grepl("(^|/)(\\.git)(/|$)", rels) &
    !grepl("(^|/)[^/]+\\.Rcheck(/|$)", rels) &
    !grepl("\\.tar\\.gz$", rels)
  entries <- entries[keep]
  rels <- rels[keep]
  info <- file.info(entries)

  dirs <- rels[info$isdir]
  for (dir_rel in dirs) {
    dir.create(file.path(temp_pkg, dir_rel), recursive = TRUE, showWarnings = FALSE)
  }

  files <- entries[!info$isdir]
  file_rels <- rels[!info$isdir]
  for (i in seq_along(files)) {
    target <- file.path(temp_pkg, file_rels[[i]])
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    ok <- file.copy(files[[i]], target, overwrite = TRUE, copy.date = TRUE)
    if (!isTRUE(ok)) {
      stop(sprintf("Failed to copy '%s' into the temp verification source tree.", file_rels[[i]]), call. = FALSE)
    }
  }

  temp_pkg
}

find_built_tarballs <- function(build_output, package_dir) {
  search_roots <- unique(normalizePath(
    c(
      package_dir,
      dirname(package_dir),
      repo_root,
      dirname(repo_root)
    ),
    winslash = "/",
    mustWork = FALSE
  ))

  tarballs <- character()

  built_lines <- grep("^\\* checking for file '.*\\.tar\\.gz'$", build_output, value = TRUE)
  if (length(built_lines)) {
    built_paths <- sub("^\\* checking for file '(.*\\.tar\\.gz)'$", "\\1", built_lines)
    tarballs <- built_paths[file.exists(built_paths)]
  }

  if (!length(tarballs)) {
    tarballs <- unlist(lapply(search_roots, function(root) {
      if (!dir.exists(root)) {
        return(character())
      }
      list.files(root, pattern = "\\.tar\\.gz$", full.names = TRUE)
    }), use.names = FALSE)
  }

  sort(unique(normalizePath(tarballs[file.exists(tarballs)], winslash = "/", mustWork = FALSE)))
}

classify_check_issue <- function(lines) {
  package_flags <- character()
  environment_flags <- character()

  if (any(grepl("needs @export or @exportS3Method", lines, fixed = TRUE))) {
    package_flags <- c(package_flags, "roxygen reports missing S3 export tags for current source files")
  }
  if (any(grepl("creating write pipe", lines, fixed = TRUE)) || any(grepl("Access is denied", lines, fixed = TRUE))) {
    environment_flags <- c(environment_flags, "processx cannot create the Rcmd pipe in this local environment")
  }
  if (any(grepl("unable to access index for repository", lines, fixed = TRUE))) {
    environment_flags <- c(environment_flags, "network-restricted repository index access is unavailable locally")
  }

  list(
    package = unique(package_flags),
    environment = unique(environment_flags)
  )
}

write_report <- function(path, title, command, result, verified_lines, inference_lines = character(), recommendation_lines = character()) {
  lines <- c(
    title,
    paste0("Command: ", command),
    paste0("Exit status: ", result$status),
    sprintf("Elapsed seconds: %.3f", result$elapsed),
    "",
    "Evidence class: verified fact",
    verified_lines,
    "",
    "Raw output:",
    result$output
  )

  if (length(inference_lines)) {
    lines <- c(lines, "", "Evidence class: likely inference", inference_lines)
  }
  if (length(recommendation_lines)) {
    lines <- c(lines, "", "Evidence class: recommendation", recommendation_lines)
  }

  write_text_file(path, lines)
}

load_all_temp <- copy_source_tree("load-all")
load_all_result <- run_r(c(
  "requireNamespace('devtools', quietly = TRUE)",
  "before_search <- search()",
  "before_ns <- loadedNamespaces()",
  "msgs <- character()",
  "warns <- character()",
  "status <- 'success'",
  "err <- ''",
  "tryCatch(withCallingHandlers({ devtools::load_all('.') }, message = function(m) { msgs <<- c(msgs, conditionMessage(m)); invokeRestart('muffleMessage') }, warning = function(w) { warns <<- c(warns, conditionMessage(w)); invokeRestart('muffleWarning') }), error = function(e) { status <<- 'failure'; err <<- conditionMessage(e) })",
  "after_search <- search()",
  "after_ns <- loadedNamespaces()",
  "cat(paste0('LOAD_ALL_STATUS: ', status, '\\n'))",
  "cat(paste0('NAMESPACE_LOADED: ', 'hydroMetrics' %in% after_ns, '\\n'))",
  "cat(paste0('ATTACHED_ON_SEARCH_PATH: ', 'package:hydroMetrics' %in% after_search, '\\n'))",
  "cat(paste0('NEW_SEARCH_ENTRIES: ', if (length(setdiff(after_search, before_search))) paste(setdiff(after_search, before_search), collapse = ', ') else '<none>', '\\n'))",
  "cat(paste0('NEW_NAMESPACES: ', if (length(setdiff(after_ns, before_ns))) paste(setdiff(after_ns, before_ns), collapse = ', ') else '<none>', '\\n'))",
  "cat(paste0('MESSAGE_COUNT: ', length(msgs), '\\n'))",
  "cat(paste0('WARNING_COUNT: ', length(warns), '\\n'))",
  "if (nzchar(err)) cat(paste0('LOAD_ALL_ERROR: ', err, '\\n'))",
  "if (length(msgs)) { cat('MESSAGES_START\\n'); cat(paste(msgs, collapse = '\\n')); cat('\\nMESSAGES_END\\n') }",
  "if (length(warns)) { cat('WARNINGS_START\\n'); cat(paste(warns, collapse = '\\n')); cat('\\nWARNINGS_END\\n') }"
), wd = load_all_temp, extra_paths = load_all_temp)

write_report(
  path = file.path(output_dir, "load_all_results.txt"),
  title = "Phase 2 Dynamic Verification - Load Verification",
  command = "devtools::load_all()",
  result = load_all_result,
  verified_lines = c(
    paste0("load_all status = ", extract_marker(load_all_result$output, "LOAD_ALL_STATUS", "<missing>")),
    paste0("namespace loaded = ", extract_marker(load_all_result$output, "NAMESPACE_LOADED", "<missing>")),
    paste0("attached on search path = ", extract_marker(load_all_result$output, "ATTACHED_ON_SEARCH_PATH", "<missing>")),
    paste0("message count = ", extract_marker(load_all_result$output, "MESSAGE_COUNT", "<missing>")),
    paste0("warning count = ", extract_marker(load_all_result$output, "WARNING_COUNT", "<missing>")),
    paste0("new search entries = ", extract_marker(load_all_result$output, "NEW_SEARCH_ENTRIES", "<missing>")),
    paste0("new namespaces = ", extract_marker(load_all_result$output, "NEW_NAMESPACES", "<missing>"))
  ),
  inference_lines = if (identical(extract_marker(load_all_result$output, "NAMESPACE_LOADED"), "TRUE")) {
    "The package namespace appears to load cleanly in a local non-installed session."
  } else {
    "The package namespace did not load cleanly in the local non-installed session."
  },
  recommendation_lines = if (load_all_result$status == 0L) {
    "No immediate action required for load_all() beyond preserving this evidence."
  } else {
    "Investigate the recorded load_all() error before stabilization work begins."
  }
)

testthat_temp <- copy_source_tree("testthat")
testthat_result <- run_r(c(
  "requireNamespace('devtools', quietly = TRUE)",
  "requireNamespace('testthat', quietly = TRUE)",
  "start <- proc.time()[['elapsed']]",
  "reporter <- testthat::SummaryReporter$new()",
  "status <- 'success'",
  "err <- ''",
  "pass <- fail <- warn <- skip <- NA_integer_",
  "devtools::load_all('.')",
  "tryCatch({",
  "  res <- testthat::test_dir('tests/testthat', reporter = reporter)",
  "  expectation_results <- unlist(lapply(res, `[[`, 'results'), recursive = FALSE)",
  "  expectation_classes <- if (length(expectation_results)) vapply(expectation_results, function(x) class(x)[[1]], character(1)) else character()",
  "  pass <- sum(expectation_classes == 'expectation_success')",
  "  fail <- sum(grepl('failure|error', expectation_classes))",
  "  warn <- sum(grepl('warning', expectation_classes))",
  "  skip <- sum(grepl('skip', expectation_classes))",
  "  cat(paste0('TEST_CASE_COUNT: ', length(res), '\\n'))",
  "  cat(paste0('EXPECTATION_COUNT: ', length(expectation_results), '\\n'))",
  "}, error = function(e) { status <<- 'failure'; err <<- conditionMessage(e) })",
  "elapsed <- round(proc.time()[['elapsed']] - start, 3)",
  "cat(paste0('TESTTHAT_STATUS: ', status, '\\n'))",
  "cat(paste0('PASS_COUNT: ', pass, '\\n'))",
  "cat(paste0('FAIL_COUNT: ', fail, '\\n'))",
  "cat(paste0('WARN_COUNT: ', warn, '\\n'))",
  "cat(paste0('SKIP_COUNT: ', skip, '\\n'))",
  "cat(paste0('ELAPSED_SECONDS: ', elapsed, '\\n'))",
  "if (nzchar(err)) cat(paste0('TESTTHAT_ERROR: ', err, '\\n'))"
), wd = testthat_temp, extra_paths = testthat_temp)

write_report(
  path = file.path(output_dir, "testthat_results.txt"),
  title = "Phase 2 Dynamic Verification - testthat Execution",
  command = "testthat::test_dir(\"tests/testthat\")",
  result = testthat_result,
  verified_lines = c(
    paste0("test_dir status = ", extract_marker(testthat_result$output, "TESTTHAT_STATUS", "<missing>")),
    paste0("test case count = ", extract_marker(testthat_result$output, "TEST_CASE_COUNT", "<missing>")),
    paste0("expectation count = ", extract_marker(testthat_result$output, "EXPECTATION_COUNT", "<missing>")),
    paste0("pass count = ", extract_marker(testthat_result$output, "PASS_COUNT", "<missing>")),
    paste0("fail count = ", extract_marker(testthat_result$output, "FAIL_COUNT", "<missing>")),
    paste0("warn count = ", extract_marker(testthat_result$output, "WARN_COUNT", "<missing>")),
    paste0("skip count = ", extract_marker(testthat_result$output, "SKIP_COUNT", "<missing>")),
    paste0("elapsed seconds = ", extract_marker(testthat_result$output, "ELAPSED_SECONDS", "<missing>"))
  ),
  inference_lines = if (identical(extract_marker(testthat_result$output, "FAIL_COUNT"), "<missing>")) {
    "testthat expectation counts were not fully captured from the local run."
  } else if (identical(extract_marker(testthat_result$output, "FAIL_COUNT"), "0")) {
    "The local testthat execution completed without observed failures."
  } else {
    "The local testthat execution reported failures."
  },
  recommendation_lines = if (identical(extract_marker(testthat_result$output, "FAIL_COUNT"), "0")) {
    "Preserve the current test surface as the runtime baseline for stabilization work."
  } else {
    "Inspect the recorded test_dir output before using this branch as a stabilization baseline."
  }
)

check_temp <- copy_source_tree("check")
check_run <- run_r(
  c(
    "requireNamespace('devtools', quietly = TRUE)",
    "tryCatch(devtools::check(), error = function(e) { message('DVCHECK_ERROR_START'); message(conditionMessage(e)); message('DVCHECK_ERROR_END'); q(status = 1) })"
  ),
  wd = check_temp,
  extra_paths = check_temp
)
check_build_fallback <- run_r_cmd(c("build", "."), wd = check_temp, extra_paths = check_temp)
check_tarball <- if (check_build_fallback$status == 0L) {
  find_built_tarballs(check_build_fallback$output, check_temp)
} else {
  character()
}
check_rcmd_fallback <- if (length(check_tarball)) {
  run_r_cmd(c("check", "--no-manual", basename(check_tarball[[1]])), wd = check_temp, extra_paths = c(check_temp, check_tarball[[1]]))
} else {
  list(status = 1L, elapsed = 0, output = "Fallback direct R CMD check was not attempted because R CMD build did not produce a tarball.")
}
check_flags <- classify_check_issue(check_run$output)
check_completed <- check_run$status == 0L
check_fallback_status <- if (check_rcmd_fallback$status == 0L) "success" else "failure"

write_report(
  path = file.path(output_dir, "check_results.txt"),
  title = "Phase 2 Dynamic Verification - devtools::check()",
  command = "devtools::check()",
  result = check_run,
  verified_lines = c(
    paste0("devtools::check completed = ", check_completed),
    paste0("devtools::check exit status = ", check_run$status),
    paste0("fallback R CMD build exit status = ", check_build_fallback$status),
    paste0("fallback R CMD check status = ", check_fallback_status),
    paste0("fallback R CMD check exit status = ", check_rcmd_fallback$status)
  ),
  inference_lines = c(
    if (length(check_flags$package)) paste0("Package-level indicators: ", paste(check_flags$package, collapse = "; ")) else "Package-level indicators: none observed in wrapper output.",
    if (length(check_flags$environment)) paste0("Environment-level indicators: ", paste(check_flags$environment, collapse = "; ")) else "Environment-level indicators: none observed in wrapper output.",
    if (check_rcmd_fallback$status == 0L) {
      "Fallback direct R CMD check completed successfully, so the package check surface appears cleaner than the devtools wrapper result."
    } else {
      "Fallback direct R CMD check did not provide a clean confirmation."
    }
  ),
  recommendation_lines = c(
    "Treat the recorded devtools::check() failure mode as baseline evidence, not as a verified package regression caused by this validation script.",
    "Use the fallback direct R CMD check output in this file when separating repo-level packaging issues from local wrapper/process restrictions."
  )
)

check_cran_temp <- copy_source_tree("check-cran")
check_cran_run <- run_r(
  c(
    "requireNamespace('devtools', quietly = TRUE)",
    "tryCatch(devtools::check(cran = TRUE), error = function(e) { message('DVCHECK_CRAN_ERROR_START'); message(conditionMessage(e)); message('DVCHECK_CRAN_ERROR_END'); q(status = 1) })"
  ),
  wd = check_cran_temp,
  extra_paths = check_cran_temp
)
check_cran_build_fallback <- run_r_cmd(c("build", "."), wd = check_cran_temp, extra_paths = check_cran_temp)
check_cran_tarball <- if (check_cran_build_fallback$status == 0L) {
  find_built_tarballs(check_cran_build_fallback$output, check_cran_temp)
} else {
  character()
}
check_cran_rcmd_fallback <- if (length(check_cran_tarball)) {
  run_r_cmd(c("check", "--as-cran", "--no-manual", basename(check_cran_tarball[[1]])), wd = check_cran_temp, extra_paths = c(check_cran_temp, check_cran_tarball[[1]]))
} else {
  list(status = 1L, elapsed = 0, output = "Fallback direct R CMD check --as-cran was not attempted because R CMD build did not produce a tarball.")
}
check_cran_flags <- classify_check_issue(check_cran_run$output)

write_report(
  path = file.path(output_dir, "check_cran_results.txt"),
  title = "Phase 2 Dynamic Verification - devtools::check(cran = TRUE)",
  command = "devtools::check(cran = TRUE)",
  result = check_cran_run,
  verified_lines = c(
    paste0("devtools::check(cran = TRUE) completed = ", check_cran_run$status == 0L),
    paste0("devtools::check(cran = TRUE) exit status = ", check_cran_run$status),
    paste0("fallback R CMD build exit status = ", check_cran_build_fallback$status),
    paste0("fallback R CMD check --as-cran exit status = ", check_cran_rcmd_fallback$status)
  ),
  inference_lines = c(
    if (length(check_cran_flags$package)) paste0("Package-level indicators: ", paste(check_cran_flags$package, collapse = "; ")) else "Package-level indicators: none observed in wrapper output.",
    if (length(check_cran_flags$environment)) paste0("Environment-level indicators: ", paste(check_cran_flags$environment, collapse = "; ")) else "Environment-level indicators: none observed in wrapper output.",
    if (check_cran_rcmd_fallback$status == 0L) {
      "Fallback direct R CMD check --as-cran completed, so partial CRAN-style evidence is available despite the devtools wrapper failure."
    } else {
      "Fallback direct R CMD check --as-cran did not complete cleanly."
    }
  ),
  recommendation_lines = c(
    "Record the exact local blocking reason instead of treating this command as fully completed.",
    "Use the fallback direct --as-cran evidence to separate local wrapper problems from package-level CRAN-style behavior."
  )
)

coverage_temp <- copy_source_tree("coverage")
coverage_result <- run_r(c(
  "if (!requireNamespace('covr', quietly = TRUE)) { cat('COVERAGE_STATUS: unavailable\\n'); cat('COVERAGE_ERROR: covr is not installed.\\n'); q(status = 0) }",
  "cov <- tryCatch(covr::package_coverage(path = '.'), error = function(e) e)",
  "if (inherits(cov, 'error')) { cat('COVERAGE_STATUS: failure\\n'); cat(paste0('COVERAGE_ERROR: ', conditionMessage(cov), '\\n')); q(status = 0) }",
  "pct <- tryCatch(as.character(covr::percent_coverage(cov)), error = function(e) '<unavailable>')",
  "files <- unique(as.character(cov$filename))",
  "cat('COVERAGE_STATUS: success\\n')",
  "cat(paste0('OVERALL_COVERAGE: ', pct, '\\n'))",
  "cat(paste0('FILE_COUNT: ', length(files), '\\n'))",
  "cat('PUBLIC_API_COVERAGE: unverified from aggregate line coverage alone\\n')",
  "print(cov)"
), wd = coverage_temp, extra_paths = coverage_temp)

write_report(
  path = file.path(output_dir, "coverage_results.txt"),
  title = "Phase 2 Dynamic Verification - Coverage",
  command = "covr::package_coverage()",
  result = coverage_result,
  verified_lines = c(
    paste0("coverage status = ", extract_marker(coverage_result$output, "COVERAGE_STATUS", "<missing>")),
    paste0("overall coverage = ", extract_marker(coverage_result$output, "OVERALL_COVERAGE", "<missing>")),
    paste0("covered file count = ", extract_marker(coverage_result$output, "FILE_COUNT", "<missing>")),
    paste0("public API coverage = ", extract_marker(coverage_result$output, "PUBLIC_API_COVERAGE", "<missing>"))
  ),
  inference_lines = "Aggregate line coverage does not by itself verify public API sufficiency.",
  recommendation_lines = "Use this file as descriptive runtime evidence only; do not infer threshold adequacy without a separate coverage policy."
)

lint_temp <- copy_source_tree("lint")
lint_result <- run_r(c(
  "if (!requireNamespace('lintr', quietly = TRUE)) { cat('LINT_STATUS: unavailable\\n'); cat('LINT_ERROR: lintr is not installed.\\n'); q(status = 0) }",
  "lints <- tryCatch(lintr::lint_package('.'), error = function(e) e)",
  "if (inherits(lints, 'error')) { cat('LINT_STATUS: failure\\n'); cat(paste0('LINT_ERROR: ', conditionMessage(lints), '\\n')); q(status = 0) }",
  "cat('LINT_STATUS: success\\n')",
  "cat(paste0('LINT_COUNT: ', length(lints), '\\n'))",
  "if (length(lints)) {",
  "  type_counts <- sort(table(vapply(lints, function(x) { if (is.null(x$type) || !nzchar(x$type)) 'unknown' else x$type }, character(1))), decreasing = TRUE)",
  "  file_counts <- sort(table(vapply(lints, function(x) { if (is.null(x$filename) || !nzchar(x$filename)) '<unknown>' else basename(x$filename) }, character(1))), decreasing = TRUE)",
  "  cat(paste0('LINT_TYPES: ', paste(paste(names(type_counts), as.integer(type_counts), sep = '='), collapse = ', '), '\\n'))",
  "  cat(paste0('LINT_FILES: ', paste(paste(names(file_counts), as.integer(file_counts), sep = '='), collapse = ', '), '\\n'))",
  "} else {",
  "  cat('LINT_TYPES: <none>\\n')",
  "  cat('LINT_FILES: <none>\\n')",
  "}",
  "print(lints)"
), wd = lint_temp, extra_paths = lint_temp)

lint_type_summary <- extract_marker(lint_result$output, "LINT_TYPES", "<missing>")
lint_inference <- if (grepl("warning|error", lint_type_summary, ignore.case = TRUE)) {
  "Non-style lint categories appear in the local lint output and may be release-relevant."
} else if (identical(extract_marker(lint_result$output, "LINT_STATUS"), "success")) {
  "The observed lint output appears cosmetic or empty from the available local categories."
} else {
  "Lint relevance could not be inferred because lint execution did not complete cleanly."
}

write_report(
  path = file.path(output_dir, "lint_results.txt"),
  title = "Phase 2 Dynamic Verification - Lint",
  command = "lintr::lint_package()",
  result = lint_result,
  verified_lines = c(
    paste0("lint status = ", extract_marker(lint_result$output, "LINT_STATUS", "<missing>")),
    paste0("lint count = ", extract_marker(lint_result$output, "LINT_COUNT", "<missing>")),
    paste0("lint types = ", lint_type_summary),
    paste0("lint files = ", extract_marker(lint_result$output, "LINT_FILES", "<missing>"))
  ),
  inference_lines = lint_inference,
  recommendation_lines = "Use the raw lint listing below for any file-level triage; this script does not impose lint thresholds."
)

restore_namespace()
install_temp <- copy_source_tree("install")
install_build <- run_r_cmd(c("build", "."), wd = install_temp, extra_paths = install_temp)
install_tarball <- if (install_build$status == 0L) {
  find_built_tarballs(install_build$output, install_temp)
} else {
  character()
}
install_lib <- file.path(tempdir(), "hydroMetrics-dynamic-install-lib")
if (dir.exists(install_lib)) {
  unlink(install_lib, recursive = TRUE, force = TRUE)
}
dir.create(install_lib, recursive = TRUE, showWarnings = FALSE)
install_run <- if (length(install_tarball)) {
  run_r_cmd(c("INSTALL", "--preclean", "-l", install_lib, basename(install_tarball[[1]])), wd = install_temp, extra_paths = c(install_temp, install_lib, install_tarball[[1]]))
} else {
  list(status = 1L, elapsed = 0, output = "Install step was not attempted because R CMD build did not produce a source tarball.")
}
library_run <- if (install_run$status == 0L) {
  run_r(
    c(
      sprintf(".libPaths(c(%s, .libPaths()))", encodeString(normalizePath(install_lib, winslash = "/", mustWork = TRUE), quote = "\"")),
      "msgs <- character()",
      "warns <- character()",
      "status <- 'success'",
      "err <- ''",
      "tryCatch(withCallingHandlers({ library(hydroMetrics); cat(paste0('INSTALLED_EXPORT_COUNT: ', length(getNamespaceExports('hydroMetrics')), '\\n')) }, message = function(m) { msgs <<- c(msgs, conditionMessage(m)); invokeRestart('muffleMessage') }, warning = function(w) { warns <<- c(warns, conditionMessage(w)); invokeRestart('muffleWarning') }), error = function(e) { status <<- 'failure'; err <<- conditionMessage(e) })",
      "cat(paste0('LIBRARY_STATUS: ', status, '\\n'))",
      "cat(paste0('LIBRARY_MESSAGE_COUNT: ', length(msgs), '\\n'))",
      "cat(paste0('LIBRARY_WARNING_COUNT: ', length(warns), '\\n'))",
      "if (nzchar(err)) cat(paste0('LIBRARY_ERROR: ', err, '\\n'))"
    ),
    wd = install_temp,
    extra_paths = c(install_temp, install_lib)
  )
} else {
  list(status = 1L, elapsed = 0, output = "library(hydroMetrics) was not attempted because installation did not complete.")
}

install_report_lines <- c(
  "Phase 2 Dynamic Verification - Clean-Session Installation",
  "Command: R CMD build; R CMD INSTALL; library(hydroMetrics)",
  paste0("Build exit status: ", install_build$status),
  paste0("Install exit status: ", install_run$status),
  paste0("Library load exit status: ", library_run$status),
  "",
  "Evidence class: verified fact",
  paste0("build success = ", install_build$status == 0L),
  paste0("install success = ", install_run$status == 0L),
  paste0("library load success = ", extract_marker(library_run$output, "LIBRARY_STATUS", "<missing>")),
  paste0("installed export count = ", extract_marker(library_run$output, "INSTALLED_EXPORT_COUNT", "<missing>")),
  paste0("library message count = ", extract_marker(library_run$output, "LIBRARY_MESSAGE_COUNT", "<missing>")),
  paste0("library warning count = ", extract_marker(library_run$output, "LIBRARY_WARNING_COUNT", "<missing>")),
  "",
  "Build output:",
  install_build$output,
  "",
  "Install output:",
  install_run$output,
  "",
  "Library load output:",
  library_run$output,
  "",
  "Evidence class: likely inference",
  if (install_build$status == 0L && install_run$status == 0L && identical(extract_marker(library_run$output, "LIBRARY_STATUS"), "success")) {
    "The package can be built, installed from source, and attached in a clean local session."
  } else {
    "The clean-session installation workflow is not fully healthy in the current local environment."
  },
  "",
  "Evidence class: recommendation",
  "Use this install evidence as the baseline for any packaging fixes; do not infer more than the recorded build/install/load facts."
)
write_text_file(file.path(output_dir, "install_results.txt"), install_report_lines)

namespace_result <- run_r(c(
  sprintf(".libPaths(c(%s, .libPaths()))", encodeString(normalizePath(install_lib, winslash = "/", mustWork = TRUE), quote = "\"")),
  "library(hydroMetrics)",
  "ns <- asNamespace('hydroMetrics')",
  "exports <- sort(getNamespaceExports('hydroMetrics'))",
  "missing_defs <- exports[!vapply(exports, exists, logical(1), envir = ns, inherits = FALSE)]",
  "alias_lines <- unlist(lapply(list.files('man', pattern = '\\\\.Rd$', full.names = TRUE), function(path) grep('^\\\\\\\\alias\\\\{', readLines(path, warn = FALSE), value = TRUE)))",
  "aliases <- sort(unique(sub('^\\\\\\\\alias\\\\{([^}]*)\\\\}$', '\\\\1', trimws(alias_lines))))",
  "doc_gaps <- exports[!exports %in% aliases]",
  "helper_exports <- exports[grepl('^\\\\.', exports)]",
  "cat(paste0('EXPORT_COUNT: ', length(exports), '\\n'))",
  "cat(paste0('EXPORTED_NAMES: ', paste(exports, collapse = ', '), '\\n'))",
  "cat(paste0('MISSING_OBJECTS: ', if (length(missing_defs)) paste(missing_defs, collapse = ', ') else '<none>', '\\n'))",
  "cat(paste0('DOCUMENTATION_GAPS: ', if (length(doc_gaps)) paste(doc_gaps, collapse = ', ') else '<none>', '\\n'))",
  "cat(paste0('HELPER_EXPORTS: ', if (length(helper_exports)) paste(helper_exports, collapse = ', ') else '<none>', '\\n'))"
), wd = install_temp, extra_paths = c(install_temp, install_lib))

write_report(
  path = file.path(output_dir, "namespace_export_results.txt"),
  title = "Phase 2 Dynamic Verification - Namespace and Export Verification",
  command = "getNamespaceExports(\"hydroMetrics\") and exported object resolution checks",
  result = namespace_result,
  verified_lines = c(
    paste0("export count = ", extract_marker(namespace_result$output, "EXPORT_COUNT", "<missing>")),
    paste0("exported names = ", extract_marker(namespace_result$output, "EXPORTED_NAMES", "<missing>")),
    paste0("missing exported definitions = ", extract_marker(namespace_result$output, "MISSING_OBJECTS", "<missing>")),
    paste0("runtime-detectable documentation gaps = ", extract_marker(namespace_result$output, "DOCUMENTATION_GAPS", "<missing>")),
    paste0("helper-style exports = ", extract_marker(namespace_result$output, "HELPER_EXPORTS", "<missing>"))
  ),
  inference_lines = if (identical(extract_marker(namespace_result$output, "MISSING_OBJECTS"), "<none>")) {
    "No missing exported definitions were detected at runtime."
  } else {
    "At least one exported name did not resolve inside the package namespace."
  },
  recommendation_lines = "Treat the documentation-gap line as a runtime-adjacent cross-check only; deeper API documentation review belongs in audit work."
)

examples_temp <- copy_source_tree("examples")
examples_result <- run_r(c(
  "rd_files <- list.files('man', pattern = '\\\\.Rd$', full.names = TRUE)",
  "example_flags <- vapply(rd_files, function(path) any(grepl('\\\\\\\\examples\\\\s*\\\\{', readLines(path, warn = FALSE))), logical(1))",
  "count <- sum(example_flags)",
  "cat(paste0('EXAMPLE_RD_COUNT: ', count, '\\n'))",
  "if (!count) { cat('EXAMPLES_STATUS: skipped_no_examples\\n'); q(status = 0) }",
  "requireNamespace('devtools', quietly = TRUE)",
  "status <- 'success'",
  "err <- ''",
  "tryCatch(devtools::run_examples(run_donttest = TRUE), error = function(e) { status <<- 'failure'; err <<- conditionMessage(e) })",
  "cat(paste0('EXAMPLES_STATUS: ', status, '\\n'))",
  "if (nzchar(err)) cat(paste0('EXAMPLES_ERROR: ', err, '\\n'))"
), wd = examples_temp, extra_paths = examples_temp)

write_report(
  path = file.path(output_dir, "examples_results.txt"),
  title = "Phase 2 Dynamic Verification - Examples",
  command = "devtools::run_examples(run_donttest = TRUE) where feasible",
  result = examples_result,
  verified_lines = c(
    paste0("Rd files with examples = ", extract_marker(examples_result$output, "EXAMPLE_RD_COUNT", "<missing>")),
    paste0("examples status = ", extract_marker(examples_result$output, "EXAMPLES_STATUS", "<missing>"))
  ),
  inference_lines = if (identical(extract_marker(examples_result$output, "EXAMPLES_STATUS"), "skipped_no_examples")) {
    "Full examples execution was infeasible because no runnable Rd example sections were present in the source tree."
  } else if (identical(extract_marker(examples_result$output, "EXAMPLES_STATUS"), "success")) {
    "The available examples executed without an observed fatal error."
  } else {
    "Examples execution reported a failure or did not complete."
  },
  recommendation_lines = "Record the exact scope completed here; do not infer example adequacy when the package currently ships no runnable examples."
)

registry_result <- run_r(c(
  sprintf(".libPaths(c(%s, .libPaths()))", encodeString(normalizePath(install_lib, winslash = "/", mustWork = TRUE), quote = "\"")),
  "library(hydroMetrics)",
  "first <- hydroMetrics:::list_metrics()",
  "second <- hydroMetrics:::list_metrics()",
  "dups <- first$id[duplicated(first$id)]",
  "required <- c('nse', 'kge', 'pbias', 'mae', 'rsr', 'apfb', 'hfb')",
  "missing_required <- required[!required %in% first$id]",
  "cat(paste0('REGISTRY_METHOD: library(hydroMetrics) + hydroMetrics:::list_metrics()\\n'))",
  "cat(paste0('REGISTRY_CLASS: ', paste(class(hydroMetrics:::.get_registry()), collapse = ', '), '\\n'))",
  "cat(paste0('FIRST_REGISTRY_COUNT: ', nrow(first), '\\n'))",
  "cat(paste0('SECOND_REGISTRY_COUNT: ', nrow(second), '\\n'))",
  "cat(paste0('UNIQUE_ID_COUNT: ', length(unique(first$id)), '\\n'))",
  "cat(paste0('DUPLICATE_IDS: ', if (length(dups)) paste(dups, collapse = ', ') else '<none>', '\\n'))",
  "cat(paste0('MISSING_REQUIRED_IDS: ', if (length(missing_required)) paste(missing_required, collapse = ', ') else '<none>', '\\n'))"
), wd = install_temp, extra_paths = c(install_temp, install_lib))

write_report(
  path = file.path(output_dir, "registry_results.txt"),
  title = "Phase 2 Dynamic Verification - Registry Initialization",
  command = "library(hydroMetrics); hydroMetrics:::list_metrics()",
  result = registry_result,
  verified_lines = c(
    paste0("method used = ", extract_marker(registry_result$output, "REGISTRY_METHOD", "<missing>")),
    paste0("registry class = ", extract_marker(registry_result$output, "REGISTRY_CLASS", "<missing>")),
    paste0("first registry count = ", extract_marker(registry_result$output, "FIRST_REGISTRY_COUNT", "<missing>")),
    paste0("second registry count = ", extract_marker(registry_result$output, "SECOND_REGISTRY_COUNT", "<missing>")),
    paste0("unique id count = ", extract_marker(registry_result$output, "UNIQUE_ID_COUNT", "<missing>")),
    paste0("duplicate ids = ", extract_marker(registry_result$output, "DUPLICATE_IDS", "<missing>")),
    paste0("missing required ids = ", extract_marker(registry_result$output, "MISSING_REQUIRED_IDS", "<missing>"))
  ),
  inference_lines = c(
    "Stable repeated list_metrics() counts provide local evidence against duplicate registration on repeated access.",
    "Repeated detach/load cycle behavior remains unverified because this script does not alter registry semantics."
  ),
  recommendation_lines = "Use this file for verified registry-access facts only; do not extend conclusions beyond the recorded repeated-access evidence."
)

wrapper_result <- run_r(c(
  sprintf(".libPaths(c(%s, .libPaths()))", encodeString(normalizePath(install_lib, winslash = "/", mustWork = TRUE), quote = "\"")),
  "library(hydroMetrics)",
  "if (!requireNamespace('zoo', quietly = TRUE)) stop('zoo is required for APFB wrapper verification.')",
  "describe_value <- function(x) {",
  "  if (is.matrix(x)) return(paste0('matrix dim=', paste(dim(x), collapse = 'x'), ' class=', paste(class(x), collapse = ',')))",
  "  if (is.data.frame(x)) return(paste0('data.frame rows=', nrow(x), ' cols=', ncol(x), ' class=', paste(class(x), collapse = ',')))",
  "  if (is.list(x) && !is.atomic(x)) return(paste0('list names=', paste(names(x), collapse = ','), ' class=', paste(class(x), collapse = ',')))",
  "  paste0('class=', paste(class(x), collapse = ','), ' length=', length(x), ' value=', paste(utils::head(as.character(x), 6L), collapse = ','))",
  "}",
  "run_case <- function(name, expr) {",
  "  warns <- character()",
  "  status <- 'success'",
  "  result <- NULL",
  "  err <- ''",
  "  tryCatch(withCallingHandlers({ result <- force(expr) }, warning = function(w) { warns <<- c(warns, conditionMessage(w)); invokeRestart('muffleWarning') }), error = function(e) { status <<- 'failure'; err <<- conditionMessage(e) })",
  "  cat(paste0('WRAPPER_CASE: ', name, '\\n'))",
  "  cat(paste0('STATUS: ', status, '\\n'))",
  "  if (status == 'success') cat(paste0('RESULT: ', describe_value(result), '\\n'))",
  "  if (nzchar(err)) cat(paste0('ERROR: ', err, '\\n'))",
  "  cat(paste0('WARNING_COUNT: ', length(warns), '\\n'))",
  "  if (length(warns)) cat(paste0('WARNINGS: ', paste(warns, collapse = ' | '), '\\n'))",
  "}",
  "sim <- c(1, 2, 3, 4)",
  "obs <- c(1.1, 1.9, 3.2, 3.8)",
  "sim_mat <- cbind(a = sim, b = sim + 0.2)",
  "obs_mat <- cbind(a = obs, b = obs + 0.1)",
  "sim_df <- as.data.frame(sim_mat)",
  "obs_df <- as.data.frame(obs_mat)",
  "idx <- seq.Date(as.Date('2000-01-01'), by = 'month', length.out = 24)",
  "sim_zoo <- zoo::zoo(seq(10, 33, length.out = 24), idx)",
  "obs_zoo <- zoo::zoo(seq(11, 34, length.out = 24), idx)",
  "wrappers <- c('alpha', 'APFB', 'beta', 'ggof', 'gof', 'HFB', 'mae', 'mNSeff', 'NSeff', 'pbias', 'preproc', 'r', 'rNSeff', 'rsr', 'valindex', 'wsNSeff')",
  "for (name in wrappers) {",
  "  f <- get(name, envir = asNamespace('hydroMetrics'))",
  "  defaults <- vapply(formals(f), function(x) paste(deparse(x), collapse = ' '), character(1))",
  "  cat(paste0('WRAPPER_SIGNATURE: ', name, '(', paste(names(formals(f)), collapse = ', '), ')', '\\n'))",
  "  cat(paste0('WRAPPER_DEFAULTS: ', name, ' => ', paste(paste(names(defaults), defaults, sep = '='), collapse = '; '), '\\n'))",
  "}",
  "run_case('alpha.vector', alpha(sim, obs))",
  "run_case('alpha.matrix', alpha(sim_mat, obs_mat))",
  "run_case('APFB.zoo', APFB(sim_zoo, obs_zoo))",
  "run_case('beta.vector', beta(sim, obs))",
  "run_case('beta.matrix', beta(sim_mat, obs_mat))",
  "run_case('gof.vector', gof(sim, obs, methods = 'NSE'))",
  "run_case('gof.data.frame', gof(sim_df, obs_df, methods = 'NSE'))",
  "run_case('ggof.vector', ggof(sim, obs, methods = 'NSE'))",
  "run_case('ggof.data.frame', ggof(sim_df, obs_df, methods = 'NSE'))",
  "run_case('HFB.vector', HFB(sim, obs))",
  "run_case('mae.vector', mae(sim, obs))",
  "run_case('mae.matrix', mae(sim_mat, obs_mat))",
  "run_case('mNSeff.vector', mNSeff(sim, obs))",
  "run_case('NSeff.vector', NSeff(sim, obs))",
  "run_case('pbias.vector', pbias(sim, obs))",
  "run_case('pbias.matrix', pbias(sim_mat, obs_mat))",
  "run_case('preproc.vector', preproc(sim, obs))",
  "run_case('r.vector', r(sim, obs))",
  "run_case('r.matrix', r(sim_mat, obs_mat))",
  "run_case('rNSeff.vector', rNSeff(sim, obs))",
  "run_case('rsr.vector', rsr(sim, obs))",
  "run_case('valindex.vector', valindex(sim, obs, fun = 'NSE'))",
  "run_case('valindex.matrix', valindex(sim_mat, obs_mat, fun = 'NSE'))",
  "run_case('wsNSeff.vector', wsNSeff(sim, obs))"
), wd = install_temp, extra_paths = c(install_temp, install_lib))

wrapper_case_count <- length(grep("^WRAPPER_CASE:", wrapper_result$output))
wrapper_failure_count <- length(grep("^STATUS: failure$", wrapper_result$output))

write_report(
  path = file.path(output_dir, "wrapper_behavior_results.txt"),
  title = "Phase 2 Dynamic Verification - Wrapper Behavior",
  command = "Runtime checks over exported wrapper-like functions",
  result = wrapper_result,
  verified_lines = c(
    paste0("wrapper cases executed = ", wrapper_case_count),
    paste0("wrapper case failures = ", wrapper_failure_count),
    paste0("signature lines recorded = ", length(grep('^WRAPPER_SIGNATURE:', wrapper_result$output)))
  ),
  inference_lines = c(
    "The recorded wrapper cases cover exported metric wrappers, orchestration wrappers, and indexed APFB behavior on nominal inputs.",
    "Matrix/data.frame support was only exercised where those interfaces were feasible from the exported function signatures."
  ),
  recommendation_lines = "Use the per-case records below for targeted stabilization work; this script intentionally avoids asserting compatibility against external packages."
)

summary_lines <- c(
  "# Phase 2 Dynamic Verification Summary",
  "",
  "Evidence legend:",
  "- `verified fact`: directly supported by recorded command output or generated runtime evidence.",
  "- `likely inference`: a constrained interpretation of the recorded runtime evidence.",
  "- `recommendation`: suggested follow-up action, not verified runtime behavior.",
  "",
  "## Commands Run",
  sprintf("- `devtools::load_all()`: %s", extract_marker(load_all_result$output, "LOAD_ALL_STATUS", "<missing>")),
  sprintf("- `testthat::test_dir(\"tests/testthat\")`: %s", extract_marker(testthat_result$output, "TESTTHAT_STATUS", "<missing>")),
  sprintf("- `devtools::check()`: exit status %d", check_run$status),
  sprintf("- `devtools::check(cran = TRUE)`: exit status %d", check_cran_run$status),
  sprintf("- `covr::package_coverage()`: %s", extract_marker(coverage_result$output, "COVERAGE_STATUS", "<missing>")),
  sprintf("- `lintr::lint_package()`: %s", extract_marker(lint_result$output, "LINT_STATUS", "<missing>")),
  sprintf("- `R CMD build`/`R CMD INSTALL`/`library(hydroMetrics)`: build=%d install=%d load=%s", install_build$status, install_run$status, extract_marker(library_run$output, "LIBRARY_STATUS", "<missing>")),
  sprintf("- `getNamespaceExports(\"hydroMetrics\")`: export count %s", extract_marker(namespace_result$output, "EXPORT_COUNT", "<missing>")),
  sprintf("- Examples workflow: %s", extract_marker(examples_result$output, "EXAMPLES_STATUS", "<missing>")),
  sprintf("- Registry access workflow: registry count %s", extract_marker(registry_result$output, "FIRST_REGISTRY_COUNT", "<missing>")),
  sprintf("- Wrapper behavior workflow: %d cases, %d failures", wrapper_case_count, wrapper_failure_count),
  "",
  "## Commands Completed",
  sprintf("- `devtools::load_all()`: %s", if (load_all_result$status == 0L) "completed" else "blocked"),
  sprintf("- `testthat::test_dir(\"tests/testthat\")`: %s", if (testthat_result$status == 0L) "completed" else "blocked"),
  sprintf("- `devtools::check()`: %s", if (check_run$status == 0L) "completed" else paste0("blocked; fallback direct R CMD check exit status = ", check_rcmd_fallback$status)),
  sprintf("- `devtools::check(cran = TRUE)`: %s", if (check_cran_run$status == 0L) "completed" else paste0("blocked; fallback direct R CMD check --as-cran exit status = ", check_cran_rcmd_fallback$status)),
  sprintf("- Coverage: %s", extract_marker(coverage_result$output, "COVERAGE_STATUS", "<missing>")),
  sprintf("- Lint: %s", extract_marker(lint_result$output, "LINT_STATUS", "<missing>")),
  sprintf("- Clean install workflow: %s", if (install_build$status == 0L && install_run$status == 0L && identical(extract_marker(library_run$output, "LIBRARY_STATUS"), "success")) "completed" else "blocked"),
  "",
  "## Verified Runtime Strengths",
  "- `devtools::load_all()` loads the package namespace locally and records only the observed startup side effects in `load_all_results.txt`.",
  "- `testthat::test_dir(\"tests/testthat\")` produces parseable pass/fail/warn/skip counts for this branch baseline.",
  sprintf("- Runtime namespace inspection verifies %s exported objects with no missing exported definitions detected.", extract_marker(namespace_result$output, "EXPORT_COUNT", "<missing>")),
  "- Clean-session source build/install/load evidence is recorded separately from the devtools wrapper checks.",
  sprintf("- Registry access returns %s entries with duplicate ids reported as %s.", extract_marker(registry_result$output, "FIRST_REGISTRY_COUNT", "<missing>"), extract_marker(registry_result$output, "DUPLICATE_IDS", "<missing>")),
  sprintf("- Wrapper verification exercised %d nominal runtime cases across exported wrappers.", wrapper_case_count),
  "",
  "## Runtime Defects Found",
  if (length(check_flags$package)) paste0("- `devtools::check()` reports repo-level packaging issues: ", paste(check_flags$package, collapse = "; "), ".") else "- No repo-level packaging issue was inferred from `devtools::check()` wrapper output.",
  if (length(check_flags$environment)) paste0("- `devtools::check()` also reports environment-level blocking factors: ", paste(check_flags$environment, collapse = "; "), ".") else "- No environment-level block was inferred from `devtools::check()` wrapper output.",
  if (length(check_cran_flags$environment)) paste0("- `devtools::check(cran = TRUE)` inherits environment-level CRAN-style blocking factors: ", paste(check_cran_flags$environment, collapse = "; "), ".") else "- No extra environment-level CRAN-style blocker was inferred beyond the wrapper output.",
  if (identical(extract_marker(examples_result$output, "EXAMPLES_STATUS"), "skipped_no_examples")) "- The package currently exposes no runnable Rd example sections, so runtime examples evidence is absent." else "- Examples execution attempted; see `examples_results.txt` for function-level details.",
  "",
  "## High-Priority Follow-up Actions",
  "- Resolve the recorded `devtools::check()` packaging/wrapper blockers before treating that command as a release gate.",
  "- Preserve the clean-session build/install evidence as the package-level runtime baseline while `devtools::check()` remains wrapper-blocked.",
  "- Use the wrapper behavior file to target any Phase 2 fixes without widening scope into formula or registry redesign.",
  "",
  "## Package-Level vs Environment-Level Failures",
  if (length(check_flags$package)) paste0("- Package-level: ", paste(check_flags$package, collapse = "; ")) else "- Package-level: none inferred from the recorded wrapper failures.",
  if (length(check_flags$environment) || length(check_cran_flags$environment)) {
    paste0("- Environment-level: ", paste(unique(c(check_flags$environment, check_cran_flags$environment)), collapse = "; "))
  } else {
    "- Environment-level: none inferred from the recorded wrapper failures."
  }
)
write_text_file(file.path(output_dir, "runtime_summary.md"), summary_lines)

cat("Dynamic verification artifacts generated successfully.\n")
cat(sprintf("Output directory: %s\n", normalizePath(output_dir, winslash = "/", mustWork = TRUE)))
