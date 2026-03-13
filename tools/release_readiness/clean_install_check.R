run_clean_install_check <- function(context) {
  report_path <- file.path(context$notes_dir, "clean_install_report.md")
  output <- character()
  add_line <- function(...) {
    output <<- c(output, paste0(...))
  }

  add_line("SESSION_START")
  desc <- read.dcf(file.path(context$root, "DESCRIPTION"))[1, ]
  deps <- unique(trimws(unlist(strsplit(paste(na.omit(desc[c("Imports", "Suggests")]), collapse = ","), ","))))
  deps <- deps[nzchar(deps)]
  deps <- sub("[[:space:]]*\\(.*$", "", deps)
  deps <- deps[deps != "R"]
  lib_path <- file.path(context$notes_dir, "tmp-library")
  rr_ensure_dir(lib_path)

  add_line("DEPENDENCY_SUMMARY_START")
  installed <- installed.packages()[, "Version"]
  for (pkg_name in deps) {
    version <- if (pkg_name %in% names(installed)) installed[[pkg_name]] else "<missing>"
    add_line(sprintf("%s==%s", pkg_name, version))
  }
  add_line("DEPENDENCY_SUMMARY_END")

  install_ok <- FALSE
  load_ok <- FALSE
  exit_status <- 0L
  fallback_used <- FALSE
  fallback_ok <- FALSE

  run_step <- function(expr) {
    withCallingHandlers(
      expr,
      message = function(m) {
        add_line(paste("MESSAGE:", conditionMessage(m)))
        invokeRestart("muffleMessage")
      },
      warning = function(w) {
        add_line(paste("WARNING:", conditionMessage(w)))
        invokeRestart("muffleWarning")
      }
    )
  }

  tryCatch({
    if (!requireNamespace("devtools", quietly = TRUE)) {
      stop("devtools is not installed in this R environment.", call. = FALSE)
    }

    pkg <- "hydroMetrics"
    .libPaths(c(lib_path, .libPaths()))
    if (pkg %in% rownames(installed.packages(lib.loc = lib_path))) {
      add_line("REMOVE_START")
      try(remove.packages(pkg, lib = lib_path), silent = TRUE)
      add_line("REMOVE_DONE")
    }

    add_line("INSTALL_DEPS_START")
    install_deps_out <- capture.output(run_step(devtools::install_deps(dependencies = TRUE, upgrade = "never", quiet = FALSE)))
    if (length(install_deps_out) > 0L) output <- c(output, install_deps_out)
    add_line("INSTALL_DEPS_DONE")

    add_line("INSTALL_START")
    install_out <- capture.output(run_step(devtools::install(upgrade = "never", quiet = FALSE)))
    if (length(install_out) > 0L) output <- c(output, install_out)
    add_line("INSTALL_DONE")
    install_ok <- TRUE

    add_line("LOAD_START")
    run_step(library(pkg, lib.loc = lib_path, character.only = TRUE))
    add_line("LOAD_DONE")
    load_ok <- TRUE
    add_line(sprintf("EXPORT_COUNT==%s", length(getNamespaceExports("hydroMetrics"))))
    add_line("SESSION_END")
  }, error = function(e) {
    error_message <- conditionMessage(e)
    add_line(paste("ERROR:", error_message))

    if (grepl("processx_exec|Access is denied", error_message, ignore.case = TRUE)) {
      fallback_used <<- TRUE
      add_line("FALLBACK_INSTALL_START")
      lib_arg <- paste0("--library=", utils::shortPathName(lib_path))
      fallback_run <- rr_run_command(rr_r_cmd(), c("INSTALL", lib_arg, "."), wd = context$root)
      output <<- c(output, fallback_run$combined)
      add_line("FALLBACK_INSTALL_DONE")
      fallback_ok <<- identical(fallback_run$status, 0L)

      if (fallback_ok) {
        install_ok <<- TRUE
        add_line("LOAD_START")
        .libPaths(c(lib_path, .libPaths()))
        run_step(library(pkg, lib.loc = lib_path, character.only = TRUE))
        add_line("LOAD_DONE")
        load_ok <<- TRUE
        add_line(sprintf("EXPORT_COUNT==%s", length(getNamespaceExports("hydroMetrics"))))
        add_line("SESSION_END")
      } else {
        exit_status <<- fallback_run$status
      }
    } else {
      exit_status <<- 1L
    }
  })

  dep_start <- match("DEPENDENCY_SUMMARY_START", output)
  dep_end <- match("DEPENDENCY_SUMMARY_END", output)
  dep_lines <- if (!is.na(dep_start) && !is.na(dep_end) && dep_end > dep_start) {
    output[(dep_start + 1L):(dep_end - 1L)]
  } else {
    "Dependency summary unavailable."
  }

  export_line <- output[grepl("^EXPORT_COUNT==", output)]
  export_count <- if (length(export_line) == 0L) "unavailable" else sub("^EXPORT_COUNT==", "", export_line[[1]])

  rr_write_lines(
    report_path,
    c(
      "# Clean Install Report",
      "",
      sprintf("- Generated: %s", rr_now()),
      sprintf("- Source version: %s", context$description[["Version"]]),
      sprintf("- Working directory: `%s`", rr_normalize_file(context$root)),
      "",
      "## Command sequence",
      "",
      "1. `remove.packages(\"hydroMetrics\")` when already installed",
      "2. `devtools::install_deps(dependencies = TRUE)`",
      "3. `devtools::install()`",
      "4. `library(hydroMetrics)`",
      "",
      "## Installed dependency summary",
      "",
      rr_md_code_block(dep_lines),
      "",
      "## Result classification",
      "",
      sprintf("- Install result: `%s`", if (install_ok) "PASS" else "FAIL"),
      sprintf("- Load result: `%s`", if (load_ok) "PASS" else "FAIL"),
      sprintf("- Namespace export count observed: `%s`", export_count),
      "",
      "## Startup and command output",
      "",
      rr_md_code_block(output)
    )
  )

  rr_result(
    stage = "clean install/load",
    status = if (install_ok && load_ok && !fallback_used) {
      "PASS"
    } else if (install_ok && load_ok && fallback_used) {
      "WARN"
    } else {
      "FAIL"
    },
    summary = if (install_ok && load_ok && !fallback_used) {
      "Fresh-session install and namespace load completed without errors."
    } else if (install_ok && load_ok && fallback_used) {
      "Fresh-session install/load succeeded via `R CMD INSTALL` after an environment-specific `devtools::install()` failure."
    } else {
      "Fresh-session install/load did not complete cleanly; inspect the captured output."
    },
    fatal = !(install_ok && load_ok),
    artifacts = report_path,
    details = list(exit_status = exit_status)
  )
}
