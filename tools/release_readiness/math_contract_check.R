run_math_contract_check <- function(context) {
  report_path <- file.path(context$notes_dir, "math_contract_report.md")

  code <- paste(
    "library(hydroMetrics)",
    "obs <- c(1, 2, 3, 4, 5)",
    "sim_bias <- obs + 1",
    "sim_probe <- c(1, 2, 2.5, 4.5, 5)",
    "scores_bias <- gof(sim_bias, obs, methods = c('R2', 'NSE', 'KGE', 'pbias', 'nrmse'))",
    "scores_probe <- gof(sim_probe, obs, methods = c('R2', 'NSE', 'KGE', 'pbias', 'nrmse', 'br2'))",
    "manual_nrmse <- sqrt(mean((sim_probe - obs)^2)) / mean(obs)",
    "manual_nse <- 1 - sum((sim_probe - obs)^2) / sum((obs - mean(obs))^2)",
    "manual_pbias <- 100 * sum(sim_probe - obs) / sum(obs)",
    "manual_kge <- {",
    "  r <- cor(sim_probe, obs)",
    "  alpha <- sd(sim_probe) / sd(obs)",
    "  beta <- mean(sim_probe) / mean(obs)",
    "  1 - sqrt((r - 1)^2 + (alpha - 1)^2 + (beta - 1)^2)",
    "}",
    "ns <- asNamespace('hydroMetrics')",
    "get_metric_internal <- get('get_metric', envir = ns, inherits = FALSE)",
    "metric_specs <- lapply(c('r2', 'nrmse', 'nse', 'kge', 'pbias', 'br2'), function(id) {",
    "  spec <- tryCatch(get_metric_internal(id), error = function(e) NULL)",
    "  if (is.null(spec)) {",
    "    data.frame(id = id, description = NA_character_, references = NA_character_, stringsAsFactors = FALSE)",
    "  } else {",
    "    data.frame(id = id, description = spec$description, references = spec$references, stringsAsFactors = FALSE)",
    "  }",
    "})",
    "metric_specs <- do.call(rbind, metric_specs)",
    "cat(sprintf('R2_BIAS==%0.12f\\n', unname(scores_bias['R2'])))",
    "cat(sprintf('NSE_BIAS==%0.12f\\n', unname(scores_bias['NSE'])))",
    "cat(sprintf('NRMSE_PROBE==%0.12f\\n', unname(scores_probe['nrmse'])))",
    "cat(sprintf('NRMSE_MANUAL==%0.12f\\n', manual_nrmse))",
    "cat(sprintf('NSE_PROBE==%0.12f\\n', unname(scores_probe['NSE'])))",
    "cat(sprintf('NSE_MANUAL==%0.12f\\n', manual_nse))",
    "cat(sprintf('PBIAS_PROBE==%0.12f\\n', unname(scores_probe['pbias'])))",
    "cat(sprintf('PBIAS_MANUAL==%0.12f\\n', manual_pbias))",
    "cat(sprintf('KGE_PROBE==%0.12f\\n', unname(scores_probe['KGE'])))",
    "cat(sprintf('KGE_MANUAL==%0.12f\\n', manual_kge))",
    "cat(sprintf('BR2_PRESENT==%s\\n', !is.na(unname(scores_probe['br2']))))",
    "for (i in seq_len(nrow(metric_specs))) {",
    "  cat(sprintf('SPEC==%s||%s||%s\\n', metric_specs$id[[i]], metric_specs$description[[i]], metric_specs$references[[i]]))",
    "}",
    sep = "\n"
  )

  run <- rr_run_r_code(code, wd = context$root)
  output <- c(run$stdout, run$stderr)
  grab_num <- function(prefix) {
    line <- output[grepl(paste0("^", prefix, "=="), output)]
    if (length(line) == 0L) return(NA_real_)
    as.numeric(sub(paste0("^", prefix, "=="), "", line[[1]]))
  }

  r2_bias <- grab_num("R2_BIAS")
  nse_bias <- grab_num("NSE_BIAS")
  nrmse_probe <- grab_num("NRMSE_PROBE")
  nrmse_manual <- grab_num("NRMSE_MANUAL")
  nse_probe <- grab_num("NSE_PROBE")
  nse_manual <- grab_num("NSE_MANUAL")
  pbias_probe <- grab_num("PBIAS_PROBE")
  pbias_manual <- grab_num("PBIAS_MANUAL")
  kge_probe <- grab_num("KGE_PROBE")
  kge_manual <- grab_num("KGE_MANUAL")
  br2_present <- any(grepl("^BR2_PRESENT==TRUE$", output))
  spec_lines <- output[grepl("^SPEC==", output)]

  contract_ok <- isTRUE(all.equal(nrmse_probe, nrmse_manual, tolerance = 1e-10)) &&
    isTRUE(all.equal(nse_probe, nse_manual, tolerance = 1e-10)) &&
    isTRUE(all.equal(pbias_probe, pbias_manual, tolerance = 1e-10)) &&
    isTRUE(all.equal(kge_probe, kge_manual, tolerance = 1e-10)) &&
    is.finite(r2_bias) &&
    is.finite(nse_bias) &&
    !isTRUE(all.equal(r2_bias, nse_bias, tolerance = 1e-10))

  rr_write_lines(
    report_path,
    c(
      "# Mathematical Contract Report",
      "",
      sprintf("- Generated: %s", rr_now()),
      sprintf("- Source version: %s", context$description[["Version"]]),
      "",
      "## Probe results",
      "",
      sprintf("- Biased prediction check: `R2 = %.6f`, `NSE = %.6f`.", r2_bias, nse_bias),
      sprintf("- `NRMSE(norm = \"mean\")` runtime/manual comparison: `%.6f` vs `%.6f`.", nrmse_probe, nrmse_manual),
      sprintf("- `NSE` runtime/manual comparison: `%.6f` vs `%.6f`.", nse_probe, nse_manual),
      sprintf("- `PBIAS` runtime/manual comparison: `%.6f` vs `%.6f`.", pbias_probe, pbias_manual),
      sprintf("- `KGE` runtime/manual comparison: `%.6f` vs `%.6f`.", kge_probe, kge_manual),
      sprintf("- `br2` included in registry: `%s`.", rr_bool(br2_present)),
      "",
      "## Interpretation",
      "",
      if (!is.na(r2_bias) && !is.na(nse_bias) && !isTRUE(all.equal(r2_bias, nse_bias, tolerance = 1e-10))) {
        "- `R2()` is demonstrably different from `NSE()` on a biased-but-perfectly-correlated probe."
      } else {
        "- `R2()` versus `NSE()` could not be distinguished on the runtime probe; this requires investigation."
      },
      if (isTRUE(all.equal(nrmse_probe, nrmse_manual, tolerance = 1e-10))) {
        "- `NRMSE` matches `RMSE / mean(obs)` on the probe series."
      } else {
        "- `NRMSE` did not match the documented mean-normalized calculation on the probe series."
      },
      if (br2_present) {
        "- `br2` is present in the internal metric registry and should be treated as project-defined until a definitive literature citation is added."
      } else {
        "- `br2` is not available on this source snapshot."
      },
      "",
      "## Metric metadata observed at runtime",
      "",
      rr_md_code_block(sub("^SPEC==", "", spec_lines))
    )
  )

  rr_result(
    stage = "mathematical contract verification",
    status = if (contract_ok && identical(run$status, 0L)) "PASS" else "FAIL",
    summary = if (contract_ok) {
      "Runtime probes support the current mathematical contract for R2, NRMSE, NSE, KGE, and PBIAS."
    } else {
      "Mathematical contract evidence is incomplete or inconsistent; inspect the report."
    },
    fatal = FALSE,
    artifacts = report_path,
    details = list(exit_status = run$status, br2_present = br2_present)
  )
}
