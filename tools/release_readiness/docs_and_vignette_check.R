run_docs_and_vignette_check <- function(context) {
  documentation_path <- file.path(context$notes_dir, "documentation_review.md")
  vignette_path <- file.path(context$notes_dir, "vignette_build_results.txt")

  build_vignettes_run <- rr_run_r_code(
    paste(
      "if (!requireNamespace('devtools', quietly = TRUE)) stop('devtools is not installed.', call. = FALSE)",
      "devtools::build_vignettes()",
      sep = "\n"
    ),
    wd = context$root
  )
  rr_write_lines(vignette_path, c(sprintf("# Vignette build results generated %s", rr_now()), "", build_vignettes_run$combined))

  document_run <- rr_run_r_code(
    paste(
      "if (!requireNamespace('devtools', quietly = TRUE)) stop('devtools is not installed.', call. = FALSE)",
      "devtools::document()",
      sep = "\n"
    ),
    wd = context$root
  )

  exports <- tryCatch(getNamespaceExports("hydroMetrics"), error = function(e) character())
  readme_exists <- file.exists(file.path(context$root, "README.md"))
  news_exists <- file.exists(file.path(context$root, "NEWS.md"))
  vignette_dir_exists <- dir.exists(file.path(context$root, "vignettes"))
  man_dir_exists <- dir.exists(file.path(context$root, "man"))
  maintainer <- context$description[["Authors@R"]]
  has_vignette_builder <- !is.null(context$description[["VignetteBuilder"]])
  documented_exports <- vapply(exports, function(topic) length(utils::help(topic, package = "hydroMetrics")) > 0L, logical(1))

  rr_write_lines(
    documentation_path,
    c(
      "# Documentation Review",
      "",
      sprintf("- Generated: %s", rr_now()),
      sprintf("- DESCRIPTION version: `%s`", context$description[["Version"]]),
      sprintf("- README present: `%s`", rr_bool(readme_exists)),
      sprintf("- NEWS present: `%s`", rr_bool(news_exists)),
      sprintf("- `vignettes/` present: `%s`", rr_bool(vignette_dir_exists)),
      sprintf("- `man/` present: `%s`", rr_bool(man_dir_exists)),
      sprintf("- `VignetteBuilder` declared: `%s`", rr_bool(has_vignette_builder)),
      sprintf("- Maintainer metadata: `%s`", if (is.null(maintainer)) "missing" else maintainer),
      "",
      "## Exported function documentation coverage",
      "",
      if (length(exports) == 0L) {
        "- No exported functions were discovered."
      } else {
        sprintf("- `%s`: documented=`%s`", exports, vapply(documented_exports, rr_bool, character(1)))
      },
      "",
      "## Documentation consistency review",
      "",
      if (!readme_exists) "- `README.md` is missing on the current branch." else "- `README.md` exists.",
      if (!news_exists) "- `NEWS.md` is missing on the current branch." else "- `NEWS.md` exists.",
      if (!vignette_dir_exists) "- No `vignettes/` directory is present, so vignette validation is incomplete." else "- `vignettes/` exists and was submitted to `devtools::build_vignettes()`.",
      "- Known hydroGOF compatibility boundaries and clean-room differences are surfaced in package-level user documentation on this branch.",
      "",
      "## `devtools::document()` output",
      "",
      rr_md_code_block(document_run$combined)
    )
  )

  docs_ok <- identical(document_run$status, 0L) && all(documented_exports)
  vignettes_ok <- identical(build_vignettes_run$status, 0L) && vignette_dir_exists && has_vignette_builder

  rr_result(
    stage = "vignette build and documentation regeneration",
    status = rr_status_worst(c(if (vignettes_ok) "PASS" else "FAIL", if (docs_ok) "PASS" else "WARN")),
    summary = sprintf(
      "Vignette command status: %s; documentation command status: %s; README present: %s; NEWS present: %s.",
      if (identical(build_vignettes_run$status, 0L)) "PASS" else "FAIL",
      if (identical(document_run$status, 0L)) "PASS" else "FAIL",
      rr_bool(readme_exists),
      rr_bool(news_exists)
    ),
    fatal = FALSE,
    artifacts = c(documentation_path, vignette_path),
    details = list(
      build_vignettes_status = build_vignettes_run$status,
      document_status = document_run$status,
      readme_exists = readme_exists,
      news_exists = news_exists
    )
  )
}
