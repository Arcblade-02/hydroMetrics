get_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) == 0L) {
    stop("Script path not available from commandArgs().", call. = FALSE)
  }
  normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE)
}

escape_cell <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  gsub("\\|", "\\\\|", x)
}

script_path <- get_script_path()
repo_root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
setwd(repo_root)

devtools::load_all(path = ".", quiet = TRUE)

ns <- asNamespace("hydroMetrics")
if (exists(".get_registry", envir = ns, inherits = FALSE)) {
  invisible(get(".get_registry", envir = ns, inherits = FALSE)())
}

implemented <- get("list_metrics", envir = ns, inherits = FALSE)()
implemented <- implemented[order(tolower(implemented$id)), , drop = FALSE]
implemented_ids <- unique(tolower(as.character(implemented$id)))
exported_names <- tolower(getNamespaceExports("hydroMetrics"))
present_keys <- unique(c(implemented_ids, exported_names))

targets_path <- file.path("tools", "hydrogof_exports.txt")
targets <- trimws(readLines(targets_path, warn = FALSE, encoding = "UTF-8"))
targets <- targets[nzchar(targets)]

target_keys <- tolower(targets)
is_present <- target_keys %in% present_keys
missing_items <- targets[!is_present]

date_str <- format(as.Date(Sys.time()), "%Y-%m-%d")

lines <- c(
  "# hydroGOF Compatibility Tracker",
  "",
  paste0("Generated on: ", date_str),
  "",
  "## Target hydroGOF exports (checklist)"
)

checklist_lines <- ifelse(is_present, paste0("- [x] ", targets), paste0("- [ ] ", targets))
lines <- c(lines, checklist_lines, "", "## Implemented metrics table (auto)")

table_header <- c(
  "| id | name | category | version_added | references |",
  "| --- | --- | --- | --- | --- |"
)

if (nrow(implemented) == 0L) {
  table_rows <- "| (none) |  |  |  |  |"
} else {
  table_rows <- apply(implemented, 1, function(row) {
    paste0(
      "| ", escape_cell(row[["id"]]),
      " | ", escape_cell(row[["name"]]),
      " | ", escape_cell(row[["category"]]),
      " | ", escape_cell(row[["version_added"]]),
      " | ", escape_cell(row[["references"]]),
      " |"
    )
  })
}

lines <- c(lines, table_header, table_rows, "", "## Missing items summary (auto)")
if (length(missing_items) == 0L) {
  lines <- c(lines, "- None")
} else {
  lines <- c(lines, paste0("- ", missing_items))
}

writeLines(lines, con = "COMPATIBILITY_TRACKER.md", useBytes = TRUE)
message("Wrote COMPATIBILITY_TRACKER.md with ", length(missing_items), " missing item(s).")
