phase2_archive_repo_root <- function() {
  normalizePath(file.path(testthat::test_path(), "..", ".."), winslash = "/", mustWork = TRUE)
}

phase2_archive_repo_path <- function(...) {
  file.path(phase2_archive_repo_root(), ...)
}

phase2_archive_branch <- "archive/phase2-validation-artifacts"

phase2_archive_source_repo_available <- function() {
  file.exists(phase2_archive_repo_path("DESCRIPTION")) &&
    dir.exists(phase2_archive_repo_path(".git"))
}

phase2_archive_git_stdout <- function(args) {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(phase2_archive_repo_root())

  out <- suppressWarnings(system2("git", args = args, stdout = TRUE, stderr = FALSE))
  status <- attr(out, "status")
  if (is.null(status) || identical(status, 0L)) {
    return(out)
  }
  character()
}

phase2_archive_branch_exists <- function(branch = phase2_archive_branch) {
  length(phase2_archive_git_stdout(c("rev-parse", "--verify", branch))) > 0L
}

phase2_archive_has_path <- function(path, branch = phase2_archive_branch) {
  length(phase2_archive_git_stdout(c("ls-tree", "-r", "--name-only", branch, "--", path))) > 0L
}
