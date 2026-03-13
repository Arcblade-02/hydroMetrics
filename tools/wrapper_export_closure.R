args <- commandArgs(trailingOnly = TRUE)

notes_dir <- file.path("notes", "wrapper-export-closure")
required_files <- c(
  file.path(notes_dir, "wrapper_gap_inventory.csv"),
  file.path(notes_dir, "wrapper_export_decisions.md"),
  file.path(notes_dir, "wrapper_runtime_verification.md"),
  file.path(notes_dir, "naming_policy_verification.md"),
  file.path(notes_dir, "validation_results.txt"),
  file.path(notes_dir, "release_patch_recommendation.md")
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0L) {
  stop(
    sprintf(
      "Missing required wrapper export closure artifact(s): %s",
      paste(missing_files, collapse = ", ")
    ),
    call. = FALSE
  )
}

inventory <- utils::read.csv(
  file.path(notes_dir, "wrapper_gap_inventory.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

required_exports <- c("NSE", "KGE", "RMSE", "R2", "NRMSE", "PBIAS", "gof", "ggof", "preproc", "valindex")
namespace_lines <- readLines("NAMESPACE", warn = FALSE)
namespace_exports <- sub("^export\\((.+)\\)$", "\\1", grep("^export\\(", namespace_lines, value = TRUE))
missing_exports <- setdiff(required_exports, namespace_exports)
if (length(missing_exports) > 0L) {
  stop(
    sprintf(
      "NAMESPACE is missing intended wrapper export(s): %s",
      paste(missing_exports, collapse = ", ")
    ),
    call. = FALSE
  )
}

missing_before <- inventory[["function"]][
  inventory[["source file present"]] &
    !inventory[["callable from installed package"]]
]

validation_lines <- readLines(file.path(notes_dir, "validation_results.txt"), warn = FALSE)
runtime_lines <- readLines(file.path(notes_dir, "wrapper_runtime_verification.md"), warn = FALSE)
recommendation_lines <- readLines(file.path(notes_dir, "release_patch_recommendation.md"), warn = FALSE)

extract_status <- function(pattern, lines) {
  hit <- grep(pattern, lines, value = TRUE)
  if (length(hit) == 0L) {
    return("not recorded")
  }
  hit[[1]]
}

cat("wrapper export closure summary\n")
cat(sprintf("missing wrappers before: %s\n", paste(missing_before, collapse = ", ")))
cat(sprintf("exported wrappers after: %s\n", paste(required_exports, collapse = ", ")))
cat(sprintf(
  "direct runtime wrapper verification status: %s\n",
  extract_status("^Overall status:", runtime_lines)
))
cat(sprintf("test status: %s\n", extract_status("^devtools::test\\(\\):", validation_lines)))
cat(sprintf("build/check status: %s\n", extract_status("^R CMD build/check:", validation_lines)))
cat(sprintf(
  "patch release recommendation: %s\n",
  extract_status("^Recommendation:", recommendation_lines)
))
