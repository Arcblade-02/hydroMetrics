run_public_api_check <- function(context) {
  inventory_path <- file.path(context$notes_dir, "public_api_inventory.csv")
  runtime_path <- file.path(context$notes_dir, "public_api_runtime_results.md")

  targets <- rr_required_api()
  quoted_targets <- paste(sprintf("'%s'", targets), collapse = ", ")

  code <- paste(
    "library(hydroMetrics)",
    sprintf("targets <- c(%s)", quoted_targets),
    "exports <- getNamespaceExports('hydroMetrics')",
    "ns <- asNamespace('hydroMetrics')",
    "sim <- c(1, 2, 3, 4, 5)",
    "obs <- c(1, 2, 2.5, 4.5, 5)",
    "runtime_targets <- c('NSE', 'KGE', 'RMSE', 'PBIAS', 'R2', 'NRMSE', 'gof', 'ggof', 'preproc', 'valindex', 'MAE')",
    "inventory <- lapply(targets, function(name) {",
    "  exported <- name %in% exports",
    "  namespace_present <- exists(name, envir = ns, inherits = FALSE)",
    "  fn <- if (namespace_present) get(name, envir = ns, inherits = FALSE) else NULL",
    "  formals_list <- if (is.function(fn)) formals(fn) else NULL",
    "  args_txt <- if (is.function(fn)) paste(names(formals_list), collapse = ', ') else NA_character_",
    "  defaults_txt <- if (is.function(fn)) {",
    "    parts <- mapply(function(arg_name, default_value) {",
    "      sprintf('%s=%s', arg_name, paste(deparse(default_value), collapse = ' '))",
    "    }, names(formals_list), formals_list, USE.NAMES = FALSE)",
    "    paste(parts, collapse = '; ')",
    "  } else {",
    "    NA_character_",
    "  }",
    "  warning_behavior <- 'not_checked'",
    "  na_rm_behavior <- if (is.function(fn) && 'na.rm' %in% names(formals_list)) {",
    "    paste0('has na.rm (default=', paste(deparse(formals_list[['na.rm']]), collapse = ' '), ')')",
    "  } else {",
    "    'no na.rm argument'",
    "  }",
    "  return_type <- NA_character_",
    "  clean_session_usable <- exported",
    "  note <- if (exported) 'exported from package namespace' else if (namespace_present) 'present in namespace but not exported' else 'object absent from namespace'",
    "  if (exported && name %in% runtime_targets) {",
    "    call_result <- withCallingHandlers(",
    "      tryCatch({",
    "        value <- do.call(fn, list(sim = sim, obs = obs))",
    "        list(ok = TRUE, value = value, error = NULL)",
    "      }, error = function(e) list(ok = FALSE, value = NULL, error = conditionMessage(e))),",
    "      warning = function(w) {",
    "        warning_behavior <<- conditionMessage(w)",
    "        invokeRestart('muffleWarning')",
    "      }",
    "    )",
    "    if (isTRUE(call_result$ok)) {",
    "      return_type <- paste(class(call_result$value), collapse = ', ')",
    "      note <- paste(note, 'runtime check succeeded', sep = '; ')",
    "    } else {",
    "      return_type <- 'error'",
    "      clean_session_usable <- FALSE",
    "      note <- paste(note, paste('runtime error:', call_result$error), sep = '; ')",
    "    }",
    "  }",
    "  data.frame(",
    "    function_name = name,",
    "    exported = exported,",
    "    namespace_present = namespace_present,",
    "    clean_session_usable = clean_session_usable,",
    "    signature = args_txt,",
    "    defaults = defaults_txt,",
    "    return_type = return_type,",
    "    warning_behavior = warning_behavior,",
    "    na_rm_behavior = na_rm_behavior,",
    "    notes = note,",
    "    stringsAsFactors = FALSE",
    "  )",
    "})",
    "inventory <- do.call(rbind, inventory)",
    sprintf("utils::write.csv(inventory, %s, row.names = FALSE, na = '')", shQuote(rr_normalize_file(inventory_path))),
    "runtime_results <- c(",
    "  '# Public API Runtime Results',",
    "  '',",
    "  sprintf('- Generated: %s', format(Sys.time(), '%Y-%m-%d %H:%M:%S %Z')),",
    "  sprintf('- Export count: %s', length(exports)),",
    "  '',",
    "  '## Minimum runtime probe',",
    "  '',",
    "  sprintf('- `gof(sim, obs)` => %s', paste(capture.output(print(gof(sim, obs))), collapse = ' '))",
    ")",
    "for (target in c('NSE', 'KGE', 'RMSE', 'PBIAS', 'R2', 'NRMSE', 'MAE', 'preproc', 'valindex', 'ggof')) {",
    "  if (!(target %in% exports)) {",
    "    runtime_results <- c(runtime_results, sprintf('- `%s(sim, obs)` => unavailable: not exported from clean session.', target))",
    "    next",
    "  }",
    "  fn <- get(target, envir = ns, inherits = FALSE)",
    "  value <- tryCatch(do.call(fn, list(sim = sim, obs = obs)), error = function(e) e)",
    "  rendered <- if (inherits(value, 'error')) conditionMessage(value) else paste(capture.output(str(value)), collapse = ' ')",
    "  runtime_results <- c(runtime_results, sprintf('- `%s(sim, obs)` => %s', target, rendered))",
    "}",
    sprintf("writeLines(runtime_results, %s, useBytes = TRUE)", shQuote(rr_normalize_file(runtime_path))),
    sep = "\n"
  )

  run <- rr_run_r_code(code, wd = context$root)
  inventory <- rr_load_csv_if_exists(inventory_path)
  missing_required <- if (nrow(inventory) > 0L) inventory$function_name[!inventory$exported] else targets

  if (!file.exists(runtime_path)) {
    rr_write_lines(runtime_path, c("# Public API Runtime Results", "", "Runtime verification did not complete; inspect pipeline logs."))
  }

  rr_result(
    stage = "public API wrapper verification",
    status = if (length(missing_required) == 0L && identical(run$status, 0L)) "PASS" else "FAIL",
    summary = if (length(missing_required) == 0L && identical(run$status, 0L)) {
      "All required public entry points are exported and callable from a clean session."
    } else {
      sprintf(
        "Required public surface is incomplete on the current snapshot; missing or non-exported: %s.",
        paste(missing_required, collapse = ", ")
      )
    },
    fatal = FALSE,
    artifacts = c(inventory_path, runtime_path),
    details = list(exit_status = run$status)
  )
}
