find_repo_root <- function(path = getwd()) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)

  repeat {
    if (file.exists(file.path(path, "DESCRIPTION"))) {
      return(path)
    }

    parent <- dirname(path)
    if (identical(parent, path)) {
      stop("Could not locate repository root.", call. = FALSE)
    }
    path <- parent
  }
}

repo_root <- find_repo_root()
setwd(repo_root)

testthat::test_dir(
  file.path(repo_root, "tools", "repo_process_checks"),
  stop_on_failure = TRUE
)
