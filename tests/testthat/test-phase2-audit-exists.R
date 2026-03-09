test_that("phase 2 audit artifacts are generated", {
  find_repo_root <- function() {
    seeds <- unique(normalizePath(
      c(
        getwd(),
        testthat::test_path(),
        file.path(testthat::test_path(), ".."),
        file.path(testthat::test_path(), "..", ".."),
        file.path(testthat::test_path(), "..", "..", "..")
      ),
      winslash = "/",
      mustWork = FALSE
    ))

    for (seed in seeds) {
      current <- seed
      for (i in seq_len(6)) {
        if (file.exists(file.path(current, "DESCRIPTION")) &&
            file.exists(file.path(current, "tools", "phase2_baseline_audit.R"))) {
          return(normalizePath(current, winslash = "/", mustWork = TRUE))
        }
        parent <- dirname(current)
        if (identical(parent, current)) {
          break
        }
        current <- parent
      }
    }

    stop("Could not locate the package source root for phase2_baseline_audit.R.")
  }

  repo_root <- find_repo_root()
  script_path <- file.path(repo_root, "tools", "phase2_baseline_audit.R")

  expect_true(file.exists(script_path))

  old_wd <- setwd(repo_root)
  on.exit(setwd(old_wd), add = TRUE)

  output <- system2(
    file.path(R.home("bin"), "Rscript.exe"),
    "tools/phase2_baseline_audit.R",
    stdout = TRUE,
    stderr = TRUE
  )
  status <- attr(output, "status")
  if (is.null(status)) {
    status <- 0L
  }

  expect_equal(status, 0L, info = paste(output, collapse = "\n"))
  expect_true(dir.exists(file.path(repo_root, "notes", "audit")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "repository_inventory.md")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "phase2_compliance_matrix.csv")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "defect_risk_register.csv")))
  expect_true(file.exists(file.path(repo_root, "notes", "audit", "dynamic_verification_plan.md")))
})
