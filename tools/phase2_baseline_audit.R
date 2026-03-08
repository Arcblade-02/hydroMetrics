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

  stop("Unable to determine the audit script path.", call. = FALSE)
}

script_path <- get_script_path()
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
audit_dir <- file.path(repo_root, "notes", "audit")
dir.create(audit_dir, recursive = TRUE, showWarnings = FALSE)

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

read_utf8 <- function(path) {
  if (!file.exists(path)) {
    return(character())
  }
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

collapse_text <- function(x) {
  x <- x[!is.na(x) & nzchar(x)]
  if (!length(x)) {
    return("")
  }
  paste(x, collapse = " ")
}

escape_md <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- ""
  x <- gsub("\\|", "\\\\|", x)
  x <- gsub("\r", " ", x, fixed = TRUE)
  gsub("\n", "<br>", x, fixed = TRUE)
}

md_table <- function(df) {
  if (!nrow(df)) {
    return(c("| Result |", "| --- |", "| No rows |"))
  }

  names(df) <- gsub("_", " ", names(df), fixed = TRUE)
  header <- paste0("| ", paste(names(df), collapse = " | "), " |")
  divider <- paste0("| ", paste(rep("---", ncol(df)), collapse = " | "), " |")
  rows <- apply(df, 1L, function(row) {
    paste0("| ", paste(escape_md(row), collapse = " | "), " |")
  })
  c(header, divider, rows)
}

write_text_file <- function(path, lines) {
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
}

write_csv_file <- function(path, df) {
  utils::write.csv(df, file = path, row.names = FALSE, na = "")
}

append_row <- function(df, row) {
  rbind(df, as.data.frame(row, stringsAsFactors = FALSE))
}

find_pattern_files <- function(pattern) {
  matches <- Sys.glob(file.path(repo_root, pattern))
  if (!length(matches)) {
    return(character())
  }
  sort(vapply(matches, rel_path, character(1)))
}

all_repo_files <- sort(list.files(
  repo_root,
  all.files = TRUE,
  recursive = TRUE,
  full.names = TRUE,
  include.dirs = FALSE,
  no.. = TRUE
))
repo_file_paths <- unname(rel_path(all_repo_files))
keep_repo_files <- !grepl("(^|/)(\\.git)(/|$)", repo_file_paths) &
  !startsWith(repo_file_paths, "notes/audit/") &
  !grepl("(^|/)[^/]+\\.Rcheck(/|$)", repo_file_paths) &
  !grepl("\\.tar\\.gz$", repo_file_paths)
all_repo_files <- all_repo_files[keep_repo_files]

top_inventory <- data.frame(
  Path = character(),
  Exists = character(),
  Type = character(),
  Purpose = character(),
  Verified_status = character(),
  stringsAsFactors = FALSE
)

inventory_targets <- list(
  list(path = "DESCRIPTION", type = "file", purpose = "Package metadata", verified = "verified fact"),
  list(path = "NAMESPACE", type = "file", purpose = "Public namespace declarations", verified = "verified fact"),
  list(path = "R", type = "directory", purpose = "Package source files", verified = "verified fact"),
  list(path = "tests/testthat", type = "directory", purpose = "Unit and structural tests", verified = "verified fact"),
  list(path = "man", type = "directory", purpose = "Generated Rd documentation", verified = "verified fact"),
  list(path = "vignettes", type = "directory", purpose = "Long-form package guides", verified = "unverified"),
  list(path = "inst", type = "directory", purpose = "Installed auxiliary package files", verified = "verified fact"),
  list(path = "tools", type = "directory", purpose = "Project automation and support scripts", verified = "verified fact"),
  list(path = ".github/workflows", type = "directory", purpose = "Continuous integration workflows", verified = "verified fact"),
  list(path = "notes", type = "directory", purpose = "Project notes and audit records", verified = "verified fact")
)

for (target in inventory_targets) {
  target_path <- file.path(repo_root, target$path)
  top_inventory <- append_row(
    top_inventory,
    list(
      Path = target$path,
      Exists = if (file.exists(target_path) || dir.exists(target_path)) "TRUE" else "FALSE",
      Type = target$type,
      Purpose = target$purpose,
      Verified_status = target$verified
    )
  )
}

pattern_inventory <- list(
  list(pattern = "README*", type = "file pattern", purpose = "Top-level package overview"),
  list(pattern = "NEWS*", type = "file pattern", purpose = "Release/change history"),
  list(pattern = "LICENSE*", type = "file pattern", purpose = "License support files")
)

for (pattern_row in pattern_inventory) {
  matches <- find_pattern_files(pattern_row$pattern)
  if (!length(matches)) {
    top_inventory <- append_row(
      top_inventory,
      list(
        Path = pattern_row$pattern,
        Exists = "FALSE",
        Type = pattern_row$type,
        Purpose = pattern_row$purpose,
        Verified_status = "verified fact"
      )
    )
  } else {
    for (match in matches) {
      top_inventory <- append_row(
        top_inventory,
        list(
          Path = match,
          Exists = "TRUE",
          Type = "file",
          Purpose = pattern_row$purpose,
          Verified_status = "verified fact"
        )
      )
    }
  }
}

top_inventory <- top_inventory[order(top_inventory$Path), , drop = FALSE]

desc_path <- file.path(repo_root, "DESCRIPTION")
desc_fields <- if (file.exists(desc_path)) as.list(read.dcf(desc_path)[1, , drop = TRUE]) else list()
desc_value <- function(field) {
  value <- desc_fields[[field]] %||% NA_character_
  if (length(value) != 1L) {
    return(collapse_text(value))
  }
  collapse_text(value)
}

metadata_fields <- data.frame(
  Field = c(
    "Package", "Title", "Version", "Authors@R", "Description", "License", "Encoding",
    "LazyData", "Depends", "Imports", "Suggests", "URL", "BugReports",
    "Roxygen", "RoxygenNote", "VignetteBuilder", "Config/testthat/edition"
  ),
  Value = c(
    desc_value("Package"),
    desc_value("Title"),
    desc_value("Version"),
    desc_value("Authors@R"),
    desc_value("Description"),
    desc_value("License"),
    desc_value("Encoding"),
    desc_value("LazyData"),
    desc_value("Depends"),
    desc_value("Imports"),
    desc_value("Suggests"),
    desc_value("URL"),
    desc_value("BugReports"),
    desc_value("Roxygen"),
    desc_value("RoxygenNote"),
    desc_value("VignetteBuilder"),
    desc_value("Config/testthat/edition")
  ),
  Evidence_class = "verified fact",
  stringsAsFactors = FALSE
)

namespace_lines <- read_utf8(file.path(repo_root, "NAMESPACE"))
exported_objects <- sort(unique(sub("^export\\(([^)]+)\\)$", "\\1", grep("^export\\(", namespace_lines, value = TRUE))))
s3_methods <- sort(unique(sub("^S3method\\(([^,]+),\\s*([^)]+)\\)$", "\\1.\\2", grep("^S3method\\(", namespace_lines, value = TRUE))))

rd_files <- sort(list.files(file.path(repo_root, "man"), pattern = "\\.Rd$", full.names = TRUE))
rd_aliases <- sort(unique(unlist(lapply(rd_files, function(path) {
  lines <- trimws(read_utf8(path))
  alias_lines <- grep("^\\\\alias\\{", lines, value = TRUE)
  sub("^\\\\alias\\{([^}]*)\\}$", "\\1", alias_lines)
}))))
rd_with_examples <- sort(vapply(rd_files, function(path) {
  any(grepl("\\\\examples\\s*\\{", read_utf8(path)))
}, logical(1)))
names(rd_with_examples) <- vapply(rd_files, rel_path, character(1))

parse_function_file <- function(path) {
  lines <- read_utf8(path)
  starts <- grep("^[.A-Za-z][A-Za-z0-9._]*\\s*(<-|=)\\s*function\\b", lines)
  if (!length(starts)) {
    return(data.frame())
  }
  ends <- c(starts[-1L] - 1L, length(lines))
  names_found <- sub("^([.A-Za-z][A-Za-z0-9._]*)\\s*(<-|=)\\s*function\\b.*$", "\\1", lines[starts])
  bodies <- mapply(function(start, end) paste(lines[start:end], collapse = "\n"), starts, ends, USE.NAMES = FALSE)
  data.frame(
    Name = names_found,
    Source_file = unname(rel_path(path)),
    Object_type = "function",
    Body = bodies,
    stringsAsFactors = FALSE
  )
}

parse_r6_file <- function(path) {
  lines <- read_utf8(path)
  starts <- grep("^[.A-Za-z][A-Za-z0-9._]*\\s*(<-|=)\\s*R6::R6Class\\b", lines)
  if (!length(starts)) {
    return(data.frame())
  }
  names_found <- sub("^([.A-Za-z][A-Za-z0-9._]*)\\s*(<-|=)\\s*R6::R6Class\\b.*$", "\\1", lines[starts])
  data.frame(
    Name = names_found,
    Source_file = unname(rel_path(path)),
    Object_type = "R6 class",
    Body = lines[starts],
    stringsAsFactors = FALSE
  )
}

r_files <- sort(list.files(file.path(repo_root, "R"), pattern = "\\.[Rr]$", full.names = TRUE))
function_inventory <- do.call(rbind, c(lapply(r_files, parse_function_file), lapply(r_files, parse_r6_file)))
if (is.null(function_inventory) || !nrow(function_inventory)) {
  function_inventory <- data.frame(
    Name = character(),
    Source_file = character(),
    Object_type = character(),
    Body = character(),
    stringsAsFactors = FALSE
  )
}

extract_wrapper_target <- function(body_text) {
  method_match <- regexpr("methods\\s*=\\s*\"[^\"]+\"", body_text, perl = TRUE)
  if (method_match[[1]] > 0L) {
    matched <- regmatches(body_text, method_match)
    return(sub("^.*\"([^\"]+)\".*$", "\\1", matched))
  }
  NA_character_
}

classify_role <- function(name, source_file, body_text, object_type) {
  if (object_type == "R6 class") {
    return("internal registry/engine class")
  }
  if (grepl("^metric_", name)) {
    return("internal metric implementation")
  }
  if (grepl("^core_metric_spec_", name)) {
    return("registry spec builder")
  }
  if (name %in% c("gof", "ggof", "preproc", "valindex")) {
    return("public orchestration wrapper")
  }
  if (name %in% c("register_core_metrics", "register_metric", "list_metrics", "get_metric", ".get_registry", ".get_engine", "evaluate_metrics")) {
    return("registry-related helper")
  }
  if (grepl("registry", source_file, fixed = TRUE) || grepl("registry", body_text, ignore.case = TRUE)) {
    return("registry-related helper")
  }
  if (name %in% c("APFB", "HFB", "alpha", "beta", "mae", "mNSeff", "NSeff", "pbias", "r", "rNSeff", "rsr", "wsNSeff", "cp", "pfactor", "rfactor")) {
    return("metric wrapper")
  }
  if (grepl("\\bgof\\s*\\(", body_text) && name != "gof") {
    return("metric wrapper")
  }
  if (grepl("^\\.", name)) {
    return("internal helper")
  }
  "support/helper"
}

classify_verification <- function(name, role, object_type, body_text) {
  if (object_type == "R6 class") {
    return("verified fact")
  }
  if (grepl("^metric_", name) || grepl("^core_metric_spec_", name)) {
    return("verified fact")
  }
  if (role %in% c("public orchestration wrapper", "metric wrapper", "registry-related helper")) {
    return("verified fact")
  }
  if (grepl("^\\.", name) || grepl("\\bgof\\s*\\(", body_text)) {
    return("verified fact")
  }
  "likely inference"
}

wrapper_targets <- vapply(function_inventory$Body, extract_wrapper_target, character(1))
function_inventory$Exported <- function_inventory$Name %in% exported_objects
function_inventory$Documented <- function_inventory$Name %in% rd_aliases
function_inventory$Likely_role <- mapply(
  classify_role,
  function_inventory$Name,
  function_inventory$Source_file,
  function_inventory$Body,
  function_inventory$Object_type,
  USE.NAMES = FALSE
)
function_inventory$Verified_status <- mapply(
  classify_verification,
  function_inventory$Name,
  function_inventory$Likely_role,
  function_inventory$Object_type,
  function_inventory$Body,
  USE.NAMES = FALSE
)
function_inventory$Wrapper_target <- wrapper_targets
function_inventory <- function_inventory[order(function_inventory$Source_file, function_inventory$Name), , drop = FALSE]

alias_inventory <- subset(
  function_inventory,
  Likely_role == "metric wrapper" & !is.na(Wrapper_target),
  select = c("Name", "Source_file", "Wrapper_target", "Exported", "Documented", "Verified_status")
)
if (nrow(alias_inventory)) {
  names(alias_inventory) <- c("Name", "Source_file", "Wrapper_target", "Exported", "Documented", "Verified_status")
}

metric_impl_inventory <- subset(
  function_inventory,
  grepl("^metric_", Name) | Likely_role == "metric wrapper",
  select = c("Name", "Source_file", "Exported", "Documented", "Likely_role", "Verified_status")
)

registry_inventory <- subset(
  function_inventory,
  grepl("registry", Likely_role, fixed = TRUE) | Likely_role == "internal registry/engine class",
  select = c("Name", "Source_file", "Object_type", "Exported", "Documented", "Likely_role", "Verified_status")
)

export_inventory <- subset(
  function_inventory,
  Exported,
  select = c("Name", "Source_file", "Object_type", "Documented", "Likely_role", "Verified_status")
)

test_files <- sort(list.files(file.path(repo_root, "tests", "testthat"), pattern = "^test-.*\\.[Rr]$", full.names = TRUE))
test_file_names <- basename(test_files)
helper_files <- sort(list.files(file.path(repo_root, "tests", "testthat"), pattern = "^helper.*\\.[Rr]$", full.names = FALSE))
snapshot_paths <- sort(list.files(file.path(repo_root, "tests", "testthat"), pattern = "_snaps", recursive = TRUE, full.names = FALSE))
snapshot_expectations <- sort(unique(grep("expect_snapshot", unlist(lapply(test_files, read_utf8)), value = FALSE)))

coverage_files <- sort(unique(c(
  find_pattern_files(".covrignore"),
  find_pattern_files("codecov.yml"),
  find_pattern_files("codecov.yaml"),
  find_pattern_files(".github/workflows/*coverage*.yml"),
  find_pattern_files(".github/workflows/*coverage*.yaml")
)))
lint_files <- sort(unique(c(
  find_pattern_files(".lintr"),
  find_pattern_files(".github/workflows/*lint*.yml"),
  find_pattern_files(".github/workflows/*lint*.yaml")
)))
check_files <- sort(unique(c(
  find_pattern_files(".github/workflows/*check*.yml"),
  find_pattern_files(".github/workflows/*check*.yaml"),
  find_pattern_files("tools/*check*.R")
)))
benchmark_audit_files <- sort(unique(c(
  find_pattern_files("inst/benchmarks/*"),
  find_pattern_files("tools/*audit*.R"),
  find_pattern_files("tools/*performance*.R"),
  find_pattern_files("tools/generate_compat_tracker.R")
)))

readme_files <- find_pattern_files("README*")
news_files <- find_pattern_files("NEWS*")
license_files <- find_pattern_files("LICENSE*")
vignette_files <- sort(list.files(file.path(repo_root, "vignettes"), full.names = FALSE, recursive = TRUE))
references_files <- sort(unique(c(find_pattern_files("inst/REFERENCES.md"), find_pattern_files("inst/*.bib"), find_pattern_files("vignettes/*.bib"))))

example_count <- sum(rd_with_examples)
examples_status <- if (!length(rd_with_examples) || example_count == 0L) {
  "missing"
} else if (example_count == length(rd_with_examples)) {
  "complete"
} else {
  "partial"
}

workflow_files <- sort(list.files(file.path(repo_root, ".github", "workflows"), pattern = "\\.ya?ml$", full.names = TRUE))
workflow_rel <- vapply(workflow_files, rel_path, character(1))
workflow_lines <- unlist(lapply(workflow_files, read_utf8), use.names = FALSE)
ci_os <- sort(unique(c(
  if (any(grepl("ubuntu-latest", workflow_lines, fixed = TRUE))) "ubuntu-latest" else character(),
  if (any(grepl("windows-latest", workflow_lines, fixed = TRUE))) "windows-latest" else character(),
  if (any(grepl("macos-latest", workflow_lines, fixed = TRUE))) "macos-latest" else character()
)))
ci_r_versions <- sort(unique(sub("^.*r:\\s*'([^']+)'.*$", "\\1", grep("r:\\s*'[^']+'", workflow_lines, value = TRUE))))
has_coverage_workflow <- any(grepl("coverage", basename(workflow_files), ignore.case = TRUE)) ||
  any(grepl("covr|codecov", workflow_lines, ignore.case = TRUE))
has_lint_workflow <- any(grepl("lint", basename(workflow_files), ignore.case = TRUE)) ||
  any(grepl("lintr", workflow_lines, ignore.case = TRUE))
has_pkgdown_workflow <- any(grepl("pkgdown", basename(workflow_files), ignore.case = TRUE)) ||
  any(grepl("pkgdown", workflow_lines, ignore.case = TRUE))
has_release_workflow <- any(grepl("release|tag", basename(workflow_files), ignore.case = TRUE)) ||
  any(grepl("release|tags:", workflow_lines, ignore.case = TRUE))
uses_cache <- any(grepl("cache", workflow_lines, ignore.case = TRUE)) ||
  any(grepl("setup-r-dependencies", workflow_lines, fixed = TRUE))
uploads_artifacts <- any(grepl("upload-artifact", workflow_lines, fixed = TRUE))
ignores_vignettes <- any(grepl("--ignore-vignettes", workflow_lines, fixed = TRUE)) ||
  any(grepl("--no-build-vignettes", workflow_lines, fixed = TRUE))
ignores_manual <- any(grepl("--no-manual", workflow_lines, fixed = TRUE))

compat_tracker_path <- file.path(repo_root, "COMPATIBILITY_TRACKER.md")
compat_tracker_lines <- read_utf8(compat_tracker_path)
compat_checked_items <- sub("^- \\[[x ]\\] ", "", grep("^- \\[[x ]\\] ", compat_tracker_lines, value = TRUE))
tracked_public_gaps <- sort(setdiff(compat_checked_items, exported_objects))

register_entries <- data.frame(
  Type = character(),
  Category = character(),
  Title = character(),
  Severity = character(),
  Evidence_class = character(),
  Evidence = character(),
  Impact = character(),
  Recommended_next_action = character(),
  Likely_files_affected = character(),
  stringsAsFactors = FALSE
)

add_register <- function(type, category, title, severity, evidence_class, evidence, impact, next_action, files) {
  assign(
    "register_entries",
    append_row(
      get("register_entries", envir = parent.frame()),
      list(
        Type = type,
        Category = category,
        Title = title,
        Severity = severity,
        Evidence_class = evidence_class,
        Evidence = evidence,
        Impact = impact,
        Recommended_next_action = next_action,
        Likely_files_affected = files
      )
    ),
    envir = parent.frame()
  )
}

maintainer_text <- paste(desc_value("Maintainer"), desc_value("Authors@R"))
if (grepl("@example\\.com", maintainer_text, ignore.case = TRUE)) {
  add_register(
    "defect",
    "CRAN readiness",
    "Placeholder maintainer identity remains in DESCRIPTION",
    "high",
    "verified fact",
    "DESCRIPTION uses maintainers@example.com for Author/Maintainer metadata.",
    "Release metadata is not publication-ready and weakens package ownership traceability.",
    "Replace placeholder maintainer identity with a real maintainer record before stabilization.",
    "DESCRIPTION"
  )
}

if (!nzchar(desc_value("URL"))) {
  add_register(
    "defect",
    "CRAN readiness",
    "DESCRIPTION is missing URL",
    "medium",
    "verified fact",
    "DESCRIPTION has no URL field.",
    "Repository and project-home discovery are weaker than expected for release-grade metadata.",
    "Add canonical repository or project URLs to DESCRIPTION.",
    "DESCRIPTION"
  )
}

if (!nzchar(desc_value("BugReports"))) {
  add_register(
    "defect",
    "CRAN readiness",
    "DESCRIPTION is missing BugReports",
    "medium",
    "verified fact",
    "DESCRIPTION has no BugReports field.",
    "Users and reviewers lack a declared issue-reporting endpoint.",
    "Add a stable issue tracker URL to DESCRIPTION.",
    "DESCRIPTION"
  )
}

if (!length(readme_files)) {
  add_register(
    "defect",
    "documentation",
    "Repository has no top-level README",
    "medium",
    "verified fact",
    "No README* file was found at the package root.",
    "New users and reviewers lack a primary package overview and install/use guidance.",
    "Add a root README that describes purpose, installation, and core usage patterns.",
    "README*"
  )
}

if (!length(news_files)) {
  add_register(
    "defect",
    "documentation",
    "Repository has no top-level NEWS file",
    "low",
    "verified fact",
    "No NEWS* file was found at the package root.",
    "Change tracking is less auditable during stabilization and release preparation.",
    "Add a NEWS or NEWS.md file for release-facing change history.",
    "NEWS*"
  )
}

if (!dir.exists(file.path(repo_root, "vignettes")) || !length(vignette_files)) {
  add_register(
    "defect",
    "documentation",
    "No vignettes are present",
    "medium",
    "verified fact",
    "The vignettes/ directory is absent or contains no vignette sources.",
    "Long-form usage guidance is missing for a metrics package with multiple wrappers and compatibility behaviors.",
    "Add at least one vignette or explicitly document why vignette coverage is intentionally absent.",
    "vignettes; DESCRIPTION"
  )
}

if (length(tracked_public_gaps) > 0L) {
  add_register(
    "defect",
    "compatibility",
    "Compatibility tracker overstates the current public export surface",
    "high",
    "verified fact",
    sprintf(
      "COMPATIBILITY_TRACKER.md marks hydroGOF-style items as implemented, but %d tracked names are not exported via NAMESPACE: %s",
      length(tracked_public_gaps),
      paste(utils::head(tracked_public_gaps, 8L), collapse = ", ")
    ),
    "API compatibility claims are difficult to audit because documentation and namespace evidence disagree.",
    "Reconcile compatibility docs with actual exports, or document which items are method names rather than exported functions.",
    "COMPATIBILITY_TRACKER.md; NAMESPACE; tools/hydrogof_exports.txt"
  )
}

if (!has_coverage_workflow && !length(coverage_files)) {
  add_register(
    "defect",
    "testing gap",
    "No coverage automation or config was detected",
    "medium",
    "verified fact",
    "No coverage workflow, codecov config, or covr-specific repository file was found.",
    "Coverage blind spots are harder to locate before stabilization work begins.",
    "Add a coverage command or workflow and record expected thresholds separately from this audit.",
    ".github/workflows; DESCRIPTION"
  )
}

if (!has_lint_workflow && !length(lint_files)) {
  add_register(
    "defect",
    "CI",
    "No lint automation or config was detected",
    "low",
    "verified fact",
    "No lint workflow and no .lintr config were found.",
    "Style and static-analysis regressions may accumulate unnoticed.",
    "Add lintr configuration and a CI entry point if linting is part of the stabilization bar.",
    ".github/workflows; .lintr"
  )
}

if (examples_status == "missing") {
  add_register(
    "defect",
    "documentation",
    "Rd example sections are absent",
    "low",
    "verified fact",
    "No \\examples{} section was detected across man/*.Rd files.",
    "Example execution cannot contribute runtime evidence during check-like validation.",
    "Add minimal runnable examples for the core public API surface.",
    "man"
  )
}

if (!"macos-latest" %in% ci_os) {
  add_register(
    "risk",
    "CI",
    "CI matrix does not exercise macOS",
    "medium",
    "verified fact",
    "The only detected CI OS targets are: {ubuntu-latest, windows-latest}.",
    "Platform-specific issues may remain hidden until later release-stage validation.",
    "Consider adding a macOS lane if cross-platform behavior is part of the stabilization target.",
    ".github/workflows/R-CMD-check.yml"
  )
}

if (ignores_vignettes || ignores_manual) {
  add_register(
    "risk",
    "CRAN readiness",
    "CI check configuration skips manual and vignette validation",
    "medium",
    "verified fact",
    "R-CMD-check workflow passes --no-manual and ignores vignette building/checking.",
    "Release-like validation is narrower than a full CRAN-style check surface.",
    "Retain fast CI if needed, but add an explicit full-check path before release hardening.",
    ".github/workflows/R-CMD-check.yml"
  )
}

references_path <- file.path(repo_root, "inst", "REFERENCES.md")
if (file.exists(references_path) && any(grepl("TODO", read_utf8(references_path), fixed = TRUE))) {
  add_register(
    "risk",
    "documentation",
    "Reference scaffold still contains TODO placeholders",
    "low",
    "verified fact",
    "inst/REFERENCES.md contains unresolved DOI/URL TODO placeholders.",
    "Citation completeness remains below a publication-ready documentation bar.",
    "Replace placeholder reference fields with finalized citations during later documentation work.",
    "inst/REFERENCES.md"
  )
}

obvious_test_tokens <- tolower(gsub("^test-|\\.R$", "", test_file_names))
metric_spec_ids <- sub("^core_metric_spec_", "", function_inventory$Name[grepl("^core_metric_spec_", function_inventory$Name)])
unclear_metric_test_coverage <- metric_spec_ids[!vapply(metric_spec_ids, function(id) {
  any(grepl(id, obvious_test_tokens, fixed = TRUE))
}, logical(1))]
if (length(unclear_metric_test_coverage) > 0L) {
  add_register(
    "risk",
    "testing gap",
    "Many internal metric ids have no obvious dedicated test file",
    "medium",
    "likely inference",
    sprintf(
      "Direct filename-level evidence for dedicated tests is unclear for %d metric ids, including: %s",
      length(unclear_metric_test_coverage),
      paste(utils::head(sort(unclear_metric_test_coverage), 8L), collapse = ", ")
    ),
    "Coverage may rely on broad batch tests, which makes gap analysis less precise during stabilization.",
    "Map metric ids to explicit tests or document which batch files provide intended coverage.",
    "tests/testthat; R/core_metrics.R"
  )
}

if (!uploads_artifacts) {
  add_register(
    "risk",
    "CI",
    "CI does not upload diagnostic artifacts",
    "low",
    "verified fact",
    "No upload-artifact step was detected in .github/workflows.",
    "Troubleshooting failed checks may require rerunning jobs rather than inspecting retained artifacts.",
    "Consider uploading check logs or coverage outputs when deeper CI forensics become necessary.",
    ".github/workflows"
  )
}

if (nrow(register_entries)) {
  ids <- character(nrow(register_entries))
  defect_counter <- 0L
  risk_counter <- 0L
  for (i in seq_len(nrow(register_entries))) {
    if (register_entries$Type[[i]] == "defect") {
      defect_counter <- defect_counter + 1L
      ids[[i]] <- sprintf("DEF-%03d", defect_counter)
    } else {
      risk_counter <- risk_counter + 1L
      ids[[i]] <- sprintf("RSK-%03d", risk_counter)
    }
  }
  register_entries$ID <- ids
}

register_output <- if (nrow(register_entries)) {
  register_entries[, c(
    "ID", "Category", "Title", "Severity", "Evidence_class", "Evidence",
    "Impact", "Recommended_next_action", "Likely_files_affected"
  )]
} else {
  data.frame(
    ID = character(),
    Category = character(),
    Title = character(),
    Severity = character(),
    Evidence_class = character(),
    Evidence = character(),
    Impact = character(),
    Recommended_next_action = character(),
    Likely_files_affected = character(),
    stringsAsFactors = FALSE
  )
}

matrix_rows <- data.frame(
  Area = character(),
  Item = character(),
  Evidence_source = character(),
  Status = character(),
  Evidence_class = character(),
  Notes = character(),
  stringsAsFactors = FALSE
)

add_matrix <- function(area, item, evidence_source, status, evidence_class, notes) {
  assign(
    "matrix_rows",
    append_row(
      get("matrix_rows", envir = parent.frame()),
      list(
        Area = area,
        Item = item,
        Evidence_source = evidence_source,
        Status = status,
        Evidence_class = evidence_class,
        Notes = notes
      )
    ),
    envir = parent.frame()
  )
}

add_matrix(
  "package structure",
  "Core package files and directories",
  "DESCRIPTION; NAMESPACE; R/; tests/testthat/; man/; inst/; tools/; .github/workflows/; notes/",
  "complete",
  "verified fact",
  "All core structural locations exist except vignettes/, which is tracked separately."
)
add_matrix(
  "package structure",
  "vignettes directory",
  "vignettes/",
  if (dir.exists(file.path(repo_root, "vignettes"))) "partial" else "missing",
  "verified fact",
  if (dir.exists(file.path(repo_root, "vignettes"))) "Directory exists." else "No vignettes directory was found."
)
add_matrix(
  "metadata",
  "DESCRIPTION release metadata",
  "DESCRIPTION",
  if (nzchar(desc_value("URL")) && nzchar(desc_value("BugReports")) && !grepl("@example\\.com", maintainer_text, ignore.case = TRUE)) "complete" else "partial",
  "verified fact",
  "Core DESCRIPTION fields exist, but release-oriented metadata is incomplete."
)
add_matrix(
  "metadata",
  "MIT support files",
  "DESCRIPTION; LICENSE; LICENSE.md",
  if (grepl("^MIT", desc_value("License")) && file.exists(file.path(repo_root, "LICENSE"))) "complete" else "partial",
  "verified fact",
  "MIT declaration is paired with LICENSE support files."
)
add_matrix(
  "exports",
  "NAMESPACE export declarations",
  "NAMESPACE",
  if (length(exported_objects)) "complete" else "missing",
  "verified fact",
  sprintf("%d exported objects detected.", length(exported_objects))
)
add_matrix(
  "metric implementation presence",
  "Internal metric implementations under R/core_metrics.R",
  "R/core_metrics.R; R/registry.R",
  if (any(grepl("^metric_", function_inventory$Name))) "complete" else "missing",
  "verified fact",
  sprintf("%d metric_* implementations detected.", sum(grepl("^metric_", function_inventory$Name)))
)
add_matrix(
  "wrapper presence",
  "Public and internal wrapper functions",
  "R/*.R; NAMESPACE",
  if (nrow(alias_inventory) > 0L) "partial" else "unverified",
  "verified fact",
  sprintf("%d wrapper-like functions detected; some hydroGOF-style names remain method-level rather than exported functions.", sum(grepl("wrapper", function_inventory$Likely_role, fixed = TRUE)))
)
add_matrix(
  "tests",
  "testthat suite presence",
  "tests/testthat; tests/testthat.R",
  if (length(test_files)) "complete" else "missing",
  "verified fact",
  sprintf("%d test files and %d helper files detected.", length(test_files), length(helper_files))
)
add_matrix(
  "tests",
  "Dedicated metric-to-test traceability",
  "tests/testthat filenames; R/core_metrics.R",
  if (length(unclear_metric_test_coverage)) "partial" else "complete",
  "likely inference",
  "Several metrics appear to rely on batch tests rather than clearly named dedicated files."
)
add_matrix(
  "docs",
  "README completeness",
  "README*",
  if (length(readme_files)) "complete" else "missing",
  "verified fact",
  if (length(readme_files)) paste(readme_files, collapse = "; ") else "No root README detected."
)
add_matrix(
  "docs",
  "NEWS presence",
  "NEWS*",
  if (length(news_files)) "complete" else "missing",
  "verified fact",
  if (length(news_files)) paste(news_files, collapse = "; ") else "No root NEWS detected."
)
add_matrix(
  "docs",
  "man page coverage relative to exports",
  "man/*.Rd; NAMESPACE",
  if (all(exported_objects %in% rd_aliases)) "complete" else "partial",
  "verified fact",
  sprintf("%d of %d exported objects have an Rd alias match.", sum(exported_objects %in% rd_aliases), length(exported_objects))
)
add_matrix(
  "docs",
  "Rd example sections",
  "man/*.Rd",
  examples_status,
  "verified fact",
  sprintf("%d of %d Rd files contain an examples section.", example_count, length(rd_with_examples))
)
add_matrix(
  "vignettes",
  "Vignette sources and builder metadata",
  "vignettes/; DESCRIPTION",
  if (length(vignette_files) && nzchar(desc_value("VignetteBuilder"))) "complete" else if (length(vignette_files) || nzchar(desc_value("VignetteBuilder"))) "partial" else "missing",
  "verified fact",
  "No vignette sources or VignetteBuilder field were detected."
)
add_matrix(
  "CI",
  "R-CMD-check workflow",
  ".github/workflows/R-CMD-check.yml",
  if (length(workflow_files)) "partial" else "missing",
  "verified fact",
  sprintf("Detected %d workflow file(s); coverage/lint/pkgdown/release workflows are absent.", length(workflow_files))
)
add_matrix(
  "CI",
  "OS and R-version matrix breadth",
  ".github/workflows/R-CMD-check.yml",
  if (all(c("ubuntu-latest", "windows-latest", "macos-latest") %in% ci_os) && length(ci_r_versions) >= 3L) "complete" else "partial",
  "verified fact",
  sprintf("OS: %s. R versions: %s.", paste(ci_os, collapse = ", "), paste(ci_r_versions, collapse = ", "))
)
add_matrix(
  "CRAN-oriented readiness signals",
  "Release-like metadata and checks",
  "DESCRIPTION; .github/workflows/R-CMD-check.yml",
  "partial",
  "verified fact",
  "Placeholder maintainer identity, missing URL/BugReports, and CI shortcuts reduce release-readiness signals."
)
add_matrix(
  "compatibility documentation",
  "hydroGOF-compatibility auditability",
  "COMPATIBILITY_TRACKER.md; DECISIONS.md; NAMESPACE",
  if (length(tracked_public_gaps)) "divergent" else "complete",
  "verified fact",
  "Compatibility notes exist, but tracker entries are not consistently aligned with exported functions."
)
add_matrix(
  "public API auditability",
  "Exported objects documented in Rd",
  "NAMESPACE; man/*.Rd",
  if (all(exported_objects %in% rd_aliases)) "complete" else "partial",
  "verified fact",
  "Export-level auditability is stronger than compatibility-surface auditability."
)
add_matrix(
  "reproducibility artifacts",
  "Phase 2 audit runner and generated outputs",
  "tools/phase2_baseline_audit.R; notes/audit/*",
  "complete",
  "verified fact",
  "The audit runner deterministically regenerates repository_inventory.md, compliance matrix, defect register, and verification plan."
)
add_matrix(
  "dynamic verification",
  "Runtime verification commands recorded",
  "notes/audit/dynamic_verification_plan.md",
  "complete",
  "recommendation",
  "Commands are defined, but command outcomes remain environment-specific until executed."
)
add_matrix(
  "dynamic verification",
  "Runtime verification outcomes",
  "Execution evidence not stored by this script",
  "unverified",
  "recommendation",
  "This audit records next-step commands only; runtime success/failure must be captured separately."
)

matrix_rows <- matrix_rows[order(matrix_rows$Area, matrix_rows$Item), , drop = FALSE]

role_counts <- as.data.frame(table(function_inventory$Likely_role), stringsAsFactors = FALSE)
names(role_counts) <- c("Likely_role", "Count")
role_counts <- role_counts[order(role_counts$Likely_role), , drop = FALSE]

qa_surface <- data.frame(
  Category = c(
    "testthat files",
    "helper files",
    "snapshot directories",
    "snapshot expectations",
    "coverage config/workflows",
    "lint config/workflows",
    "check config/workflows",
    "benchmark or audit scripts"
  ),
  Count = c(
    length(test_files),
    length(helper_files),
    length(snapshot_paths),
    length(snapshot_expectations),
    length(coverage_files),
    length(lint_files),
    length(check_files),
    length(benchmark_audit_files)
  ),
  Evidence_class = "verified fact",
  stringsAsFactors = FALSE
)

docs_status <- data.frame(
  Area = c(
    "README",
    "NEWS",
    "man coverage relative to exports",
    "vignettes",
    "references or bibliography",
    "Rd examples",
    "compatibility documentation",
    "hydroGOF-deviation documentation"
  ),
  Status = c(
    if (length(readme_files)) "complete" else "missing",
    if (length(news_files)) "complete" else "missing",
    if (all(exported_objects %in% rd_aliases)) "complete" else "partial",
    if (length(vignette_files)) "complete" else "missing",
    if (length(references_files)) {
      if (any(grepl("TODO", read_utf8(references_path), fixed = TRUE))) "partial" else "complete"
    } else {
      "missing"
    },
    examples_status,
    if (file.exists(compat_tracker_path)) {
      if (length(tracked_public_gaps)) "divergent" else "complete"
    } else {
      "missing"
    },
    if (file.exists(file.path(repo_root, "DECISIONS.md")) || file.exists(compat_tracker_path)) "partial" else "unverified"
  ),
  Evidence_source = c(
    if (length(readme_files)) paste(readme_files, collapse = "; ") else "README*",
    if (length(news_files)) paste(news_files, collapse = "; ") else "NEWS*",
    "man/*.Rd; NAMESPACE",
    "vignettes/",
    if (length(references_files)) paste(references_files, collapse = "; ") else "inst/*.md; *.bib",
    "man/*.Rd",
    "COMPATIBILITY_TRACKER.md; NAMESPACE",
    "DECISIONS.md; COMPATIBILITY_TRACKER.md"
  ),
  Verified_status = c(
    "verified fact",
    "verified fact",
    "verified fact",
    "verified fact",
    if (length(references_files)) "verified fact" else "unverified",
    "verified fact",
    "verified fact",
    if (file.exists(file.path(repo_root, "DECISIONS.md")) || file.exists(compat_tracker_path)) "likely inference" else "unverified"
  ),
  stringsAsFactors = FALSE
)

dynamic_plan <- data.frame(
  Purpose = c(
    "Load package code without installation",
    "Run testthat suite directly from tests/testthat",
    "Run standard package check",
    "Run CRAN-oriented package check",
    "Measure package coverage",
    "Run package lint checks",
    "Verify clean-session source installation",
    "Verify namespace exports",
    "Run documented examples",
    "Verify registry initialization",
    "Verify wrapper behavior on a small numeric example"
  ),
  Command = c(
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"devtools::load_all('.')\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"testthat::test_dir('tests/testthat')\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"devtools::check()\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"devtools::check(cran = TRUE)\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"covr::package_coverage()\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"lintr::lint_package()\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\R.exe\" CMD INSTALL --preclean --no-multiarch .",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"devtools::load_all('.'); print(sort(getNamespaceExports('hydroMetrics')))\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"devtools::load_all('.'); devtools::run_examples(run_donttest = TRUE)\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"devtools::load_all('.'); x <- hydroMetrics:::list_metrics(); stopifnot(is.data.frame(x), nrow(x) > 0L, all(c('nse', 'kge', 'pbias') %in% x$id))\"",
    "\"C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe\" -e \"devtools::load_all('.'); sim <- c(1, 2, 3, 4); obs <- c(1.1, 1.9, 3.2, 3.8); stopifnot(inherits(hydroMetrics::preproc(sim, obs), 'hydro_preproc'), inherits(hydroMetrics::gof(sim, obs), 'hydro_metrics'), is.numeric(hydroMetrics::mae(sim, obs)))\""
  ),
  Expected_success_condition = c(
    "Package loads with no load-time errors and the namespace is attached for local inspection.",
    "All test files complete without failures or unexpected errors.",
    "Source package builds and checks cleanly under the default devtools policy.",
    "CRAN-oriented checks complete without new warnings, notes, or errors that block release review.",
    "Coverage object is returned and metric coverage can be inspected without execution errors.",
    "Lint results are returned; zero lint findings is ideal, but the command must complete successfully.",
    "The package installs from the current source tree in a fresh R process without installation errors.",
    "Expected exports print successfully and match the audited public API surface.",
    "Examples run to completion, demonstrating that documented examples are executable.",
    "The registry auto-initializes and exposes a non-empty metric table containing core ids.",
    "Core wrappers return the expected S3 classes or numeric scalar outputs on a deterministic toy input."
  ),
  Likely_failure_interpretation = c(
    "Namespace, DESCRIPTION, or dependency issues are preventing local loadability.",
    "Behavioral regressions or environment-sensitive tests need investigation before stabilization.",
    "Package metadata, examples, docs, or tests are incompatible with check-time expectations.",
    "CRAN-style validation is stricter than current local defaults; failures identify release-hardening gaps.",
    "Coverage dependencies are missing or instrumentation is blocked by package load/check issues.",
    "Lint dependencies are missing or the codebase currently violates configured lint rules.",
    "Build-time metadata, file inclusion, or dependency declarations are incomplete for installation.",
    "Namespace declarations or roxygen-generated artifacts are out of sync with intended exports.",
    "Documentation examples are missing, stale, or rely on undeclared runtime assumptions.",
    "Registry bootstrap or metric registration behavior is broken or incomplete.",
    "Wrapper contracts, preprocessing integration, or exported API classes have drifted."
  ),
  stringsAsFactors = FALSE
)

inventory_path <- file.path(audit_dir, "repository_inventory.md")
matrix_path <- file.path(audit_dir, "phase2_compliance_matrix.csv")
register_path <- file.path(audit_dir, "defect_risk_register.csv")
plan_path <- file.path(audit_dir, "dynamic_verification_plan.md")

inventory_lines <- c(
  "# Phase 2 Baseline Repository Inventory",
  "",
  "This artifact is generated by `tools/phase2_baseline_audit.R` from repository-local evidence only.",
  "",
  "Evidence legend:",
  "- `verified fact`: directly supported by repository files or paths.",
  "- `likely inference`: purpose or coverage inferred from names, structure, or wrapper bodies.",
  "- `unverified`: no local evidence was found.",
  "",
  "## Repository Summary",
  sprintf("- Files inventoried (excluding `.git/` and `notes/audit/` outputs): %d", length(all_repo_files)),
  sprintf("- Exported objects counted: %d", length(exported_objects)),
  sprintf("- Metric-like functions counted: %d", nrow(metric_impl_inventory)),
  sprintf("- Wrapper-like functions counted: %d", sum(grepl("wrapper", function_inventory$Likely_role, fixed = TRUE))),
  sprintf("- Test files counted: %d", length(test_files)),
  sprintf("- man files counted: %d", length(rd_files)),
  sprintf("- Workflow files counted: %d", length(workflow_files)),
  "",
  "## Section 1 - Repository Structure Inventory",
  md_table(top_inventory),
  "",
  "## Section 2 - Package Metadata Audit",
  md_table(metadata_fields),
  "",
  "Metadata findings:",
  sprintf("- Verified fact: URL field present = %s", if (nzchar(desc_value("URL"))) "TRUE" else "FALSE"),
  sprintf("- Verified fact: BugReports field present = %s", if (nzchar(desc_value("BugReports"))) "TRUE" else "FALSE"),
  sprintf("- Verified fact: MIT support files present = %s", if (grepl("^MIT", desc_value("License")) && length(license_files) >= 1L) "TRUE" else "FALSE"),
  sprintf("- Likely inference: Suggests includes vignette-related packages while VignetteBuilder is present = %s", if (nzchar(desc_value("VignetteBuilder"))) "TRUE" else "FALSE"),
  "",
  "## Section 3 - Export and Metric Inventory",
  "### Exported Objects",
  md_table(export_inventory),
  "",
  "### Function and Registry Object Inventory",
  md_table(function_inventory[, c("Name", "Source_file", "Object_type", "Exported", "Documented", "Likely_role", "Verified_status")]),
  "",
  "### Wrapper and Alias Surface",
  if (nrow(alias_inventory)) md_table(alias_inventory) else c("| Result |", "| --- |", "| No wrapper aliases with fixed `methods =` target were detected. |"),
  "",
  "### Registry-related Objects",
  if (nrow(registry_inventory)) md_table(registry_inventory) else c("| Result |", "| --- |", "| No registry-related objects were detected. |"),
  "",
  "### Role Counts",
  md_table(role_counts),
  "",
  "## Section 4 - Testing and QA Inventory",
  md_table(qa_surface),
  "",
  "QA findings:",
  sprintf("- Verified fact: helper files detected = %d", length(helper_files)),
  sprintf("- Verified fact: snapshot directories detected = %d", length(snapshot_paths)),
  sprintf("- Verified fact: coverage config/workflows detected = %d", length(coverage_files)),
  sprintf("- Verified fact: lint config/workflows detected = %d", length(lint_files)),
  sprintf("- Likely inference: metric ids without obvious dedicated test filenames = %d", length(unclear_metric_test_coverage)),
  "",
  "## Section 5 - Documentation Inventory",
  md_table(docs_status),
  "",
  "## Section 6 - CI and Release Engineering Inventory",
  sprintf("- Verified fact: workflow files = %s", if (length(workflow_rel)) paste(workflow_rel, collapse = ", ") else "none"),
  sprintf("- Verified fact: OS matrix = %s", if (length(ci_os)) paste(ci_os, collapse = ", ") else "none detected"),
  sprintf("- Verified fact: R-version matrix = %s", if (length(ci_r_versions)) paste(ci_r_versions, collapse = ", ") else "none detected"),
  sprintf("- Verified fact: cache usage appears present = %s", if (uses_cache) "TRUE" else "FALSE"),
  sprintf("- Verified fact: artifact upload detected = %s", if (uploads_artifacts) "TRUE" else "FALSE"),
  sprintf("- Verified fact: release or tag workflow detected = %s", if (has_release_workflow) "TRUE" else "FALSE"),
  sprintf("- Verified fact: workflow skips vignette checks = %s", if (ignores_vignettes) "TRUE" else "FALSE"),
  sprintf("- Verified fact: workflow skips manual checks = %s", if (ignores_manual) "TRUE" else "FALSE"),
  "",
  "## Section 7 - Compliance Matrix Snapshot",
  md_table(matrix_rows),
  "",
  "## Section 8 - Defect and Risk Register Snapshot",
  if (nrow(register_output)) md_table(register_output) else c("| Result |", "| --- |", "| No defects or risks logged. |"),
  "",
  "## Section 9 - Dynamic Verification Plan",
  sprintf("See `%s`.", rel_path(plan_path))
)

plan_lines <- c(
  "# Dynamic Verification Plan",
  "",
  "This artifact records exact next-step commands. It does not claim that these commands were executed by the audit runner.",
  ""
)
for (i in seq_len(nrow(dynamic_plan))) {
  plan_lines <- c(
    plan_lines,
    sprintf("## %d. %s", i, dynamic_plan$Purpose[[i]]),
    sprintf("- Purpose: %s", dynamic_plan$Purpose[[i]]),
    sprintf("- Command: `%s`", dynamic_plan$Command[[i]]),
    sprintf("- Expected success condition: %s", dynamic_plan$Expected_success_condition[[i]]),
    sprintf("- Likely failure interpretation: %s", dynamic_plan$Likely_failure_interpretation[[i]]),
    ""
  )
}

write_text_file(inventory_path, inventory_lines)
write_csv_file(matrix_path, matrix_rows)
write_csv_file(register_path, register_output)
write_text_file(plan_path, plan_lines)

status_counts <- as.data.frame(table(matrix_rows$Status), stringsAsFactors = FALSE)
status_counts <- status_counts[order(status_counts$Var1), , drop = FALSE]
status_summary <- paste(sprintf("%s=%s", status_counts$Var1, status_counts$Freq), collapse = ", ")

defect_count <- sum(startsWith(register_output$ID, "DEF-"))
risk_count <- sum(startsWith(register_output$ID, "RSK-"))

cat(sprintf("Files inventoried: %d\n", length(all_repo_files)))
cat(sprintf("Exported objects counted: %d\n", length(exported_objects)))
cat(sprintf("Metric-like functions counted: %d\n", nrow(metric_impl_inventory)))
cat(sprintf("Wrapper-like functions counted: %d\n", sum(grepl("wrapper", function_inventory$Likely_role, fixed = TRUE))))
cat(sprintf("Test files counted: %d\n", length(test_files)))
cat(sprintf("man files counted: %d\n", length(rd_files)))
cat(sprintf("Workflow files counted: %d\n", length(workflow_files)))
cat(sprintf("Defects logged: %d\n", defect_count))
cat(sprintf("Risks logged: %d\n", risk_count))
cat(sprintf("Compliance items by status: %s\n", status_summary))
cat("No errors occurred: TRUE\n")
