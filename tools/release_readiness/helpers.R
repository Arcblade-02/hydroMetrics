rr_root <- function() {
  normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

rr_path <- function(...) {
  file.path(rr_root(), ...)
}

rr_notes_dir <- function() {
  rr_path("notes", "release-readiness")
}

rr_docs_dir <- function() {
  rr_path("docs")
}

rr_tools_dir <- function() {
  rr_path("tools", "release_readiness")
}

rr_ensure_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  invisible(path)
}

rr_initialize_layout <- function() {
  rr_ensure_dir(rr_notes_dir())
  rr_ensure_dir(rr_docs_dir())
  invisible(TRUE)
}

rr_now <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
}

rr_normalize_file <- function(path) {
  normalizePath(path, winslash = "/", mustWork = FALSE)
}

rr_write_lines <- function(path, lines) {
  rr_ensure_dir(dirname(path))
  writeLines(enc2utf8(lines), con = path, useBytes = TRUE)
  invisible(path)
}

rr_write_csv <- function(path, data) {
  rr_ensure_dir(dirname(path))
  utils::write.csv(data, file = path, row.names = FALSE, na = "")
  invisible(path)
}

rr_format_command <- function(command, args = character()) {
  pieces <- c(command, args)
  pieces <- vapply(
    pieces,
    function(x) {
      if (grepl("[[:space:]\"]", x)) shQuote(x) else x
    },
    character(1)
  )
  paste(pieces, collapse = " ")
}

rr_run_command <- function(command, args = character(), wd = rr_root(), env = character()) {
  stdout_file <- tempfile("rr-stdout-", fileext = ".log")
  stderr_file <- tempfile("rr-stderr-", fileext = ".log")
  on.exit(unlink(c(stdout_file, stderr_file), force = TRUE), add = TRUE)

  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(wd)

  status <- tryCatch(
    system2(
      command = command,
      args = args,
      stdout = stdout_file,
      stderr = stderr_file,
      wait = TRUE,
      env = env
    ),
    error = function(e) structure(127L, error_message = conditionMessage(e))
  )

  stdout <- if (file.exists(stdout_file)) readLines(stdout_file, warn = FALSE, encoding = "UTF-8") else character()
  stderr <- if (file.exists(stderr_file)) readLines(stderr_file, warn = FALSE, encoding = "UTF-8") else character()

  if (!is.null(attr(status, "error_message"))) {
    stderr <- c(stderr, paste("system2 error:", attr(status, "error_message")))
  }

  combined <- c(
    paste("$", rr_format_command(command, args)),
    if (length(stdout) > 0L) stdout,
    if (length(stderr) > 0L) c("[stderr]", stderr)
  )

  list(
    status = as.integer(status),
    stdout = stdout,
    stderr = stderr,
    combined = combined
  )
}

rr_rscript <- function() {
  exe <- if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
  file.path(R.home("bin"), exe)
}

rr_r_cmd <- function() {
  if (.Platform$OS.type == "windows") {
    bin_dir <- R.home("bin")
    candidates <- c(
      file.path(bin_dir, "Rcmd.exe"),
      file.path(dirname(bin_dir), "Rcmd.exe")
    )
    existing <- candidates[file.exists(candidates)]
    if (length(existing) == 0L) stop("Rcmd.exe could not be located.", call. = FALSE)
    return(existing[[1]])
  }

  file.path(R.home("bin"), "R")
}

rr_run_r_code <- function(code, wd = rr_root()) {
  script <- tempfile("release-readiness-", fileext = ".R")
  writeLines(enc2utf8(code), con = script, useBytes = TRUE)
  on.exit(unlink(script, force = TRUE), add = TRUE)
  rr_run_command(rr_rscript(), c("--vanilla", script), wd = wd)
}

rr_result <- function(stage, status, summary, fatal = FALSE, artifacts = character(), details = list()) {
  list(
    stage = stage,
    status = status,
    summary = summary,
    fatal = isTRUE(fatal),
    artifacts = artifacts,
    details = details
  )
}

rr_status_rank <- function(status) {
  ranks <- c(PASS = 1L, WARN = 2L, FAIL = 3L, SKIP = 4L)
  if (!status %in% names(ranks)) return(99L)
  ranks[[status]]
}

rr_status_worst <- function(statuses) {
  if (length(statuses) == 0L) return("SKIP")
  statuses[[which.max(vapply(statuses, rr_status_rank, integer(1)))]]
}

rr_bool <- function(x) {
  if (isTRUE(x)) {
    "TRUE"
  } else if (identical(x, FALSE)) {
    "FALSE"
  } else {
    "NA"
  }
}

rr_md_code_block <- function(lines) {
  c("```text", if (length(lines) > 0L) lines else "<no output>", "```")
}

rr_read_description <- function() {
  as.list(read.dcf(rr_path("DESCRIPTION"))[1, ])
}

rr_load_csv_if_exists <- function(path) {
  if (!file.exists(path)) return(data.frame())
  utils::read.csv(path, stringsAsFactors = FALSE)
}

rr_required_api <- function() {
  c("gof", "ggof", "preproc", "valindex", "metric_search", "metric_preset", "hm_result")
}

rr_default_stage_rows <- function(results) {
  data.frame(
    stage = vapply(results, `[[`, character(1), "stage"),
    status = vapply(results, `[[`, character(1), "status"),
    summary = vapply(results, `[[`, character(1), "summary"),
    fatal = vapply(results, function(x) rr_bool(x$fatal), character(1)),
    stringsAsFactors = FALSE
  )
}

rr_classify_check_failure <- function(output_lines, status_code) {
  if (identical(status_code, 0L)) return("pass")

  patterns_env <- c(
    "there is no package called",
    "cannot open URL",
    "Could not resolve host",
    "timed out",
    "internet routines",
    "not available for package",
    "failed to lock directory",
    "pandoc",
    "quarto",
    "Rtools",
    "is not writable"
  )

  joined <- paste(output_lines, collapse = "\n")
  if (any(grepl(paste(patterns_env, collapse = "|"), joined, ignore.case = TRUE))) {
    return("environment-specific")
  }

  "package-specific"
}

rr_extract_latest_tarball <- function() {
  tarballs <- Sys.glob(rr_path("hydroMetrics_*.tar.gz"))
  if (length(tarballs) == 0L) return(NA_character_)
  info <- file.info(tarballs)
  tarballs[[order(info$mtime, decreasing = TRUE)[1]]]
}

rr_read_text_if_exists <- function(path) {
  if (!file.exists(path)) return(character())
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

rr_find_ci_status <- function() {
  desc <- rr_read_description()
  url_field <- desc[["URL"]]
  if (is.null(url_field) || !nzchar(url_field)) {
    return(list(status = "unverified", details = "DESCRIPTION has no URL field."))
  }

  repo_url <- trimws(strsplit(url_field, ",", fixed = TRUE)[[1]][1])
  repo_path <- sub("^https://github.com/", "", repo_url)
  repo_path <- sub("/+$", "", repo_path)
  if (!nzchar(repo_path) || identical(repo_path, repo_url)) {
    return(list(status = "unverified", details = "GitHub repository URL could not be parsed."))
  }

  api_url <- sprintf("https://api.github.com/repos/%s/actions/runs?branch=main&per_page=5", repo_path)
  raw <- tryCatch(readLines(api_url, warn = FALSE), error = identity)
  if (inherits(raw, "error")) {
    return(list(status = "unverified", details = paste("GitHub Actions API query failed:", conditionMessage(raw))))
  }

  json <- paste(raw, collapse = "")
  names <- unlist(regmatches(json, gregexpr('"name":"[^"]+"', json, perl = TRUE)))
  conclusions <- unlist(regmatches(json, gregexpr('"conclusion":"[^"]+"', json, perl = TRUE)))
  statuses <- unlist(regmatches(json, gregexpr('"status":"[^"]+"', json, perl = TRUE)))

  names <- sub('^"name":"', "", sub('"$', "", names))
  conclusions <- sub('^"conclusion":"', "", sub('"$', "", conclusions))
  statuses <- sub('^"status":"', "", sub('"$', "", statuses))

  if (length(names) == 0L) {
    return(list(status = "unverified", details = "GitHub Actions API returned no workflow runs."))
  }

  latest <- paste0(
    "Latest observed runs: ",
    paste(
      sprintf(
        "%s (%s/%s)",
        names[seq_len(min(length(names), 3L))],
        statuses[seq_len(min(length(statuses), 3L))],
        conclusions[seq_len(min(length(conclusions), 3L))]
      ),
      collapse = "; "
    )
  )

  overall <- if (length(conclusions) > 0L && any(conclusions == "failure")) {
    "failing"
  } else if (length(conclusions) > 0L && all(conclusions == "success")) {
    "green"
  } else {
    "unverified"
  }

  list(status = overall, details = latest)
}
