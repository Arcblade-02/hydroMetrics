`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L || is.na(x[[1]])) y else x
}

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- sub("^--file=", "", script_arg[1] %||% "tools/phase2_coverage_gap_analysis.R")
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
setwd(repo_root)

notes_dir <- file.path("notes", "phase2-closure")
dir.create(notes_dir, recursive = TRUE, showWarnings = FALSE)

escape_csv <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  needs_quote <- grepl("[\",\n]", x)
  x <- gsub("\"", "\"\"", x, fixed = TRUE)
  ifelse(needs_quote, paste0("\"", x, "\""), x)
}

write_csv_lines <- function(path, df) {
  lines <- apply(df, 1L, function(row) paste(escape_csv(row), collapse = ","))
  writeLines(c(paste(names(df), collapse = ","), lines), path, useBytes = TRUE)
}

categorize_gap <- function(filename, function_name) {
  if (grepl("phase2_compat_wrappers|NSeff|mae|pbias|alpha|beta|rsr|rfactor", filename, ignore.case = TRUE) ||
      grepl("NSE|KGE|RMSE|MAE|PBIAS|R2|NRMSE|wrapper|NSeff|mNSeff|rNSeff|wsNSeff", function_name, ignore.case = TRUE)) {
    return("wrappers")
  }
  if (grepl("na|prepare|preproc|APFB|HFB", function_name, ignore.case = TRUE)) {
    return("NA handling")
  }
  if (grepl("error|validate|initialize|exists|get|register|compute_", function_name, ignore.case = TRUE) ||
      grepl("MetricRegistry|HydroEngine|validate", filename, ignore.case = TRUE)) {
    return("error branches")
  }
  if (grepl("epsilon|transform|norm|NRMSE", function_name, ignore.case = TRUE) ||
      grepl("preproc|hm_prepare", filename, ignore.case = TRUE)) {
    return("normalization logic")
  }
  if (grepl("ggof", function_name, ignore.case = TRUE) || grepl("ggof", filename, ignore.case = TRUE)) {
    return("ggof plotting paths")
  }
  if (grepl("print|as.data.frame|as.numeric|as.double|hm_result|hydro_metrics", function_name, ignore.case = TRUE) ||
      grepl("classes", filename, ignore.case = TRUE)) {
    return("output formatting paths")
  }
  if (grepl("dispatch|resolve|normalize_metrics|metric|registry|engine|gof", function_name, ignore.case = TRUE) ||
      grepl("registry|engine|gof", filename, ignore.case = TRUE)) {
    return("method dispatch")
  }
  "other"
}

if (!requireNamespace("covr", quietly = TRUE)) {
  stop("covr is required to run Phase 2 coverage gap analysis.", call. = FALSE)
}

cov <- covr::package_coverage(type = "tests")
coverage_pct <- covr::percent_coverage(cov)
zero <- covr::zero_coverage(cov)

if (!nrow(zero)) {
  zero <- data.frame(
    filename = character(),
    functions = character(),
    line = integer(),
    value = numeric(),
    stringsAsFactors = FALSE
  )
}

zero$category <- mapply(categorize_gap, zero$filename, zero$functions, USE.NAMES = FALSE)
zero$filename <- gsub("\\\\", "/", zero$filename)
report <- zero[, c("filename", "functions", "line", "value", "category")]
names(report) <- c("filename", "function", "line", "value", "category")
write_csv_lines(file.path(notes_dir, "coverage_gap_report.csv"), report)

file_summary <- if (nrow(report)) {
  stats::aggregate(line ~ filename + category, data = report, FUN = length)
} else {
  data.frame(filename = character(), category = character(), line = integer(), stringsAsFactors = FALSE)
}

category_summary <- if (nrow(report)) {
  stats::aggregate(line ~ category, data = report, FUN = length)
} else {
  data.frame(category = character(), line = integer(), stringsAsFactors = FALSE)
}

summary_lines <- c(
  "# Phase 2 Coverage Gap Summary",
  "",
  paste0("- Coverage percent: ", sprintf("%.2f%%", coverage_pct)),
  paste0("- Uncovered lines recorded: ", nrow(report)),
  paste0("- Report path: `", file.path("notes", "phase2-closure", "coverage_gap_report.csv"), "`."),
  "",
  "## Uncovered categories",
  ""
)

if (nrow(category_summary)) {
  for (i in seq_len(nrow(category_summary))) {
    summary_lines <- c(
      summary_lines,
      sprintf("- `%s`: %d uncovered line(s)", category_summary$category[[i]], category_summary$line[[i]])
    )
  }
} else {
  summary_lines <- c(summary_lines, "- None.")
}

summary_lines <- c(summary_lines, "", "## Top files by uncovered lines", "")
if (nrow(file_summary)) {
  order_idx <- order(file_summary$line, decreasing = TRUE)
  top_rows <- file_summary[order_idx, , drop = FALSE]
  for (i in seq_len(min(10L, nrow(top_rows)))) {
    summary_lines <- c(
      summary_lines,
      sprintf("- `%s` (%s): %d uncovered line(s)", top_rows$filename[[i]], top_rows$category[[i]], top_rows$line[[i]])
    )
  }
} else {
  summary_lines <- c(summary_lines, "- None.")
}

writeLines(summary_lines, file.path(notes_dir, "coverage_gap_summary.md"), useBytes = TRUE)

coverage_lines <- c(
  "Phase 2 closure coverage results",
  paste0("Coverage percent: ", sprintf("%.2f%%", coverage_pct)),
  paste0("Target met (>=95%): ", if (coverage_pct >= 95) "TRUE" else "FALSE"),
  "",
  capture.output(print(cov))
)
writeLines(coverage_lines, file.path(notes_dir, "coverage_results.txt"), useBytes = TRUE)

cat(sprintf("coverage percent: %.2f%%\n", coverage_pct))
cat(sprintf("uncovered lines recorded: %d\n", nrow(report)))
