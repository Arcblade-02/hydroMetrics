# Repo/Process Checks

This directory contains source-tree, archive, release-process, and repository
artifact checks that should not count as package runtime test coverage.

These checks were moved out of `tests/testthat/` so `devtools::test()` and
`R CMD check` stay focused on package behavior and package-integrity concerns.

Run them explicitly from the repository root with:

```r
Rscript tools/repo_process_checks/run_repo_process_checks.R
```

The checks here are expected to inspect repository history, notes, release
artifacts, archived branches, and other process evidence that is not part of
the installed package contract.
