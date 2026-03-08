# Dynamic Verification Plan

This artifact records exact next-step commands. It does not claim that these commands were executed by the audit runner.

## 1. Load package code without installation
- Purpose: Load package code without installation
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "devtools::load_all('.')"`
- Expected success condition: Package loads with no load-time errors and the namespace is attached for local inspection.
- Likely failure interpretation: Namespace, DESCRIPTION, or dependency issues are preventing local loadability.

## 2. Run testthat suite directly from tests/testthat
- Purpose: Run testthat suite directly from tests/testthat
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "testthat::test_dir('tests/testthat')"`
- Expected success condition: All test files complete without failures or unexpected errors.
- Likely failure interpretation: Behavioral regressions or environment-sensitive tests need investigation before stabilization.

## 3. Run standard package check
- Purpose: Run standard package check
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "devtools::check()"`
- Expected success condition: Source package builds and checks cleanly under the default devtools policy.
- Likely failure interpretation: Package metadata, examples, docs, or tests are incompatible with check-time expectations.

## 4. Run CRAN-oriented package check
- Purpose: Run CRAN-oriented package check
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "devtools::check(cran = TRUE)"`
- Expected success condition: CRAN-oriented checks complete without new warnings, notes, or errors that block release review.
- Likely failure interpretation: CRAN-style validation is stricter than current local defaults; failures identify release-hardening gaps.

## 5. Measure package coverage
- Purpose: Measure package coverage
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "covr::package_coverage()"`
- Expected success condition: Coverage object is returned and metric coverage can be inspected without execution errors.
- Likely failure interpretation: Coverage dependencies are missing or instrumentation is blocked by package load/check issues.

## 6. Run package lint checks
- Purpose: Run package lint checks
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "lintr::lint_package()"`
- Expected success condition: Lint results are returned; zero lint findings is ideal, but the command must complete successfully.
- Likely failure interpretation: Lint dependencies are missing or the codebase currently violates configured lint rules.

## 7. Verify clean-session source installation
- Purpose: Verify clean-session source installation
- Command: `"C:\Program Files\R\R-4.5.2\bin\R.exe" CMD INSTALL --preclean --no-multiarch .`
- Expected success condition: The package installs from the current source tree in a fresh R process without installation errors.
- Likely failure interpretation: Build-time metadata, file inclusion, or dependency declarations are incomplete for installation.

## 8. Verify namespace exports
- Purpose: Verify namespace exports
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "devtools::load_all('.'); print(sort(getNamespaceExports('hydroMetrics')))"`
- Expected success condition: Expected exports print successfully and match the audited public API surface.
- Likely failure interpretation: Namespace declarations or roxygen-generated artifacts are out of sync with intended exports.

## 9. Run documented examples
- Purpose: Run documented examples
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "devtools::load_all('.'); devtools::run_examples(run_donttest = TRUE)"`
- Expected success condition: Examples run to completion, demonstrating that documented examples are executable.
- Likely failure interpretation: Documentation examples are missing, stale, or rely on undeclared runtime assumptions.

## 10. Verify registry initialization
- Purpose: Verify registry initialization
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "devtools::load_all('.'); x <- hydroMetrics:::list_metrics(); stopifnot(is.data.frame(x), nrow(x) > 0L, all(c('nse', 'kge', 'pbias') %in% x$id))"`
- Expected success condition: The registry auto-initializes and exposes a non-empty metric table containing core ids.
- Likely failure interpretation: Registry bootstrap or metric registration behavior is broken or incomplete.

## 11. Verify wrapper behavior on a small numeric example
- Purpose: Verify wrapper behavior on a small numeric example
- Command: `"C:\Program Files\R\R-4.5.2\bin\Rscript.exe" -e "devtools::load_all('.'); sim <- c(1, 2, 3, 4); obs <- c(1.1, 1.9, 3.2, 3.8); stopifnot(inherits(hydroMetrics::preproc(sim, obs), 'hydro_preproc'), inherits(hydroMetrics::gof(sim, obs), 'hydro_metrics'), is.numeric(hydroMetrics::mae(sim, obs)))"`
- Expected success condition: Core wrappers return the expected S3 classes or numeric scalar outputs on a deterministic toy input.
- Likely failure interpretation: Wrapper contracts, preprocessing integration, or exported API classes have drifted.

