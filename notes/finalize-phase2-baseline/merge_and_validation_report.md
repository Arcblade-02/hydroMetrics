# Merge And Validation Report

- Generated: `2026-03-10 11:06:41 +05:30`
- Working branch: `feature/finalize-phase2-baseline`
- Merge source branch: `feature/final-cran-evidence-confirmation`
- Merge result: `fast-forward`
- Resulting HEAD commit: `e7a9fff6e16ce185f5ae302cdd01e83ddce5ceab`
- Conflicts encountered: `none`
- Final DESCRIPTION version: `0.2.0`
- PHASE2_EXIT_MEMO.md GO state: `YES`
- README.md present: `YES`
- NEWS.md present: `YES`
- vignettes/ present: `YES`
- notes/final-cran-evidence/ present: `YES`
- notes/pre-phase3-cran-readiness/ present: `YES`
- devtools::test status: `pass`
- R CMD build status: `pass`
- R CMD check --no-manual status: `pass`
- Main merge result: `fast-forward`
- Main push result: `success`

## Merge output

```text
Updating 680476f..e7a9fff
Fast-forward
 docs/PHASE2_EXIT_MEMO.md                           |  37 +++---
 .../devtools_check_cran_results.txt                | 127 +++++++++++++++++++++
 .../final-cran-evidence/devtools_check_results.txt | 127 +++++++++++++++++++++
 .../final_cran_evidence_summary.md                 |  15 +++
 notes/final-cran-evidence/live_ci_status_report.md |  33 ++++++
 .../nonbroken_environment_report.md                |  64 +++++++++++
 .../cran_preflight_report.md                       |  26 +++++
 .../testthat/test-final-cran-evidence-artifacts.R  |  40 +++++++
 tools/final_cran_evidence_confirmation.R           |  77 +++++++++++++
 9 files changed, 533 insertions(+), 13 deletions(-)
 create mode 100644 notes/final-cran-evidence/devtools_check_cran_results.txt
 create mode 100644 notes/final-cran-evidence/devtools_check_results.txt
 create mode 100644 notes/final-cran-evidence/final_cran_evidence_summary.md
 create mode 100644 notes/final-cran-evidence/live_ci_status_report.md
 create mode 100644 notes/final-cran-evidence/nonbroken_environment_report.md
 create mode 100644 notes/pre-phase3-cran-readiness/cran_preflight_report.md
 create mode 100644 tests/testthat/test-final-cran-evidence-artifacts.R
 create mode 100644 tools/final_cran_evidence_confirmation.R
```

## Validation output

### `devtools::test()`

```text
✔ | F W  S  OK | Context

⠏ |          0 | alpha
⠹ |          3 | alpha
✔ |          5 | alpha

⠏ |          0 | apfb
⠏ |         10 | apfb
✔ |         20 | apfb

⠏ |          0 | backward-compatibility
⠋ |         21 | backward-compatibility
✔ |         22 | backward-compatibility

⠏ |          0 | beta
✔ |          5 | beta

⠏ |          0 | compat-hydrogof
✔ |          1 | compat-hydrogof

⠏ |          0 | cp
✔ |          4 | cp

⠏ |          0 | description-merge-sync-exists
✔ |          7 | description-merge-sync-exists

⠏ |          0 | engine
⠇ |          9 | engine
✔ |         14 | engine

⠏ |          0 | error-handling-phase2
⠹ |         23 | error-handling-phase2
⠏ |         50 | error-handling-phase2
⠸ |         74 | error-handling-phase2
✔ |         75 | error-handling-phase2

⠏ |          0 | final-cran-evidence-artifacts
✔ |         11 | final-cran-evidence-artifacts

⠏ |          0 | finalize-phase2-baseline-artifacts
✔ |          6 | finalize-phase2-baseline-artifacts

⠏ |          0 | ggof
✔ |         13 | ggof

⠏ |          0 | gof
⠦ |         17 | gof
✔ |         20 | gof

⠏ |          0 | hfb
✔ |         16 | hfb

⠏ |          0 | indexed-public-api-phase2
⠇ |         19 | indexed-public-api-phase2
✔ |         24 | indexed-public-api-phase2

⠏ |          0 | init
✔ |          1 | init

⠏ |          0 | legacy-nse-aliases
⠹ |         13 | legacy-nse-aliases
✔ |         17 | legacy-nse-aliases

⠏ |          0 | mae
✔ |          5 | mae

⠏ |          0 | metric-params
✔ |          4 | metric-params

⠏ |          0 | metrics-batch2
⠦ |         17 | metrics-batch2
✔ |         17 | metrics-batch2

⠏ |          0 | metrics-batch3
⠋ |         21 | metrics-batch3
✔ |         23 | metrics-batch3

⠏ |          0 | metrics-batch4
⠇ |         19 | metrics-batch4
✔ |         21 | metrics-batch4

⠏ |          0 | metrics-batch5
⠋ |         21 | metrics-batch5
✔ |         23 | metrics-batch5

⠏ |          0 | metrics-batch6
⠹ |         13 | metrics-batch6
✔ |         22 | metrics-batch6

⠏ |          0 | metrics-batch7
✔ |          7 | metrics-batch7

⠏ |          0 | normalization-paths-phase2
⠸ |         24 | normalization-paths-phase2
✔ |         31 | normalization-paths-phase2

⠏ |          0 | output-contract-phase2
✔ |         20 | output-contract-phase2

⠏ |          0 | pbias
✔ |          5 | pbias

⠏ |          0 | performance-suite-exists
✔ |          3 | performance-suite-exists

⠏ |          0 | pfactor
✔ |          6 | pfactor

⠏ |          0 | phase2-archive-cleanup-exists
✔ |          7 | phase2-archive-cleanup-exists

⠏ |          0 | phase2-audit-exists
⠋ |          1 | phase2-audit-exists
⠹ |          3 | phase2-audit-exists
⠸ |          4 | phase2-audit-exists
⠼ |          5 | phase2-audit-exists
⠴ |          6 | phase2-audit-exists
✔ |          6 | phase2-audit-exists [1.1s]

⠏ |          0 | phase2-ci-repair-exists
✔ |          7 | phase2-ci-repair-exists

⠏ |          0 | phase2-compatibility-audit-exists
⠋ |          1 | phase2-compatibility-audit-exists
⠹ |          3 | phase2-compatibility-audit-exists
⠸ |          4 | phase2-compatibility-audit-exists
⠼ |          5 | phase2-compatibility-audit-exists
⠴ |          6 | phase2-compatibility-audit-exists
⠦ |          7 | phase2-compatibility-audit-exists
⠧ |          8 | phase2-compatibility-audit-exists
⠇ |          9 | phase2-compatibility-audit-exists
✔ |          9 | phase2-compatibility-audit-exists [1.7s]

⠏ |          0 | phase2-dynamic-verification-exists
⠋ |          1 | phase2-dynamic-verification-exists
⠹ |          3 | phase2-dynamic-verification-exists
⠸ |          4 | phase2-dynamic-verification-exists
⠼ |          5 | phase2-dynamic-verification-exists
⠴ |          6 | phase2-dynamic-verification-exists
⠦ |          7 | phase2-dynamic-verification-exists
⠧ |          8 | phase2-dynamic-verification-exists
✔ |          8 | phase2-dynamic-verification-exists [1.6s]

⠏ |          0 | phase2-exit-contract-exists
✔ |         11 | phase2-exit-contract-exists

⠏ |          0 | phase2-fix-program-exists
⠋ |          1 | phase2-fix-program-exists
⠹ |          3 | phase2-fix-program-exists
⠸ |          4 | phase2-fix-program-exists
⠼ |          5 | phase2-fix-program-exists
✔ |         15 | phase2-fix-program-exists

⠏ |          0 | phase2-github-integration-exists
✔ |          8 | phase2-github-integration-exists

⠏ |          0 | phase2-math-validation-exists
⠋ |          1 | phase2-math-validation-exists
⠹ |          3 | phase2-math-validation-exists
⠸ |          4 | phase2-math-validation-exists
⠼ |          5 | phase2-math-validation-exists
⠴ |          6 | phase2-math-validation-exists
⠦ |          7 | phase2-math-validation-exists
⠧ |          8 | phase2-math-validation-exists
⠇ |          9 | phase2-math-validation-exists
✔ |          9 | phase2-math-validation-exists [1.8s]

⠏ |          0 | phase2-merge-resolution-exists
✔ |          6 | phase2-merge-resolution-exists

⠏ |          0 | phase2-oldrel-compatibility-repair-exists
✔ |          7 | phase2-oldrel-compatibility-repair-exists

⠏ |          0 | phase2-readiness-rebase-exists
⠋ |          1 | phase2-readiness-rebase-exists
⠙ |          2 | phase2-readiness-rebase-exists
⠹ |          3 | phase2-readiness-rebase-exists
⠸ |          4 | phase2-readiness-rebase-exists
⠼ |          5 | phase2-readiness-rebase-exists
⠴ |          6 | phase2-readiness-rebase-exists
✔ |          6 | phase2-readiness-rebase-exists [1.4s]

⠏ |          0 | phase2-release-hardening-exists
⠋ |          1 | phase2-release-hardening-exists
⠹ |          3 | phase2-release-hardening-exists
⠸ |          4 | phase2-release-hardening-exists
⠼ |          5 | phase2-release-hardening-exists
⠴ |          6 | phase2-release-hardening-exists
⠦ |          7 | phase2-release-hardening-exists
⠧ |          8 | phase2-release-hardening-exists
✔ |          8 | phase2-release-hardening-exists [1.6s]

⠏ |          0 | preproc-export
⠙ |         22 | preproc-export
✔ |         35 | preproc-export

⠏ |          0 | preprocessing
⠸ |         24 | preprocessing
✔ |         34 | preprocessing

⠏ |          0 | r
✔ |          7 | r

⠏ |          0 | r2-nrmse-phase2
✔ |          5 | r2-nrmse-phase2

⠏ |          0 | release-readiness-pipeline-exists
✔ |         15 | release-readiness-pipeline-exists

⠏ |          0 | rfactor
✔ |          5 | rfactor

⠏ |          0 | rsr
✔ |          5 | rsr

⠏ |          0 | structural-integrity
⠧ |         28 | structural-integrity
⠙ |         52 | structural-integrity
⠋ |         81 | structural-integrity
⠼ |        115 | structural-integrity
⠋ |        151 | structural-integrity
✔ |        170 | structural-integrity

⠏ |          0 | valindex
✔ |          7 | valindex

⠏ |          0 | wrapper-contract-phase2
✔ |         22 | wrapper-contract-phase2

⠏ |          0 | wrapper-edgecases-phase2
⠏ |         20 | wrapper-edgecases-phase2
⠇ |         49 | wrapper-edgecases-phase2
✔ |         55 | wrapper-edgecases-phase2

══ Results ═════════════════════════════════════════════════════════════════════
Duration: 15.0 s

[ FAIL 0 | WARN 0 | SKIP 0 | PASS 915 ]
ℹ Testing hydroMetrics
```

### `R CMD build .`

```text
* checking for file './DESCRIPTION' ... OK
* preparing 'hydroMetrics':
* checking DESCRIPTION meta-information ... OK
* installing the package to build vignettes
* creating vignettes ... OK
* checking for LF line-endings in source and make files and shell scripts
* checking for empty or unneeded directories
Omitted 'LazyData' from DESCRIPTION
* building 'hydroMetrics_0.2.0.tar.gz'
```

### `R CMD check --no-manual hydroMetrics_0.2.0.tar.gz`

```text
* using log directory 'D:/R Package/hydroMetrics/hydroMetrics.Rcheck'
* using R version 4.5.2 (2025-10-31 ucrt)
* using platform: x86_64-w64-mingw32
* R was compiled by
    gcc.exe (GCC) 14.3.0
    GNU Fortran (GCC) 14.3.0
* running under: Windows 11 x64 (build 26200)
* using session charset: UTF-8
* using option '--no-manual'
* checking for file 'hydroMetrics/DESCRIPTION' ... OK
* this is package 'hydroMetrics' version '0.2.0'
* package encoding: UTF-8
* checking package namespace information ... OK
* checking package dependencies ... OK
* checking if this is a source package ... OK
* checking if there is a namespace ... OK
* checking for .dll and .exe files ... OK
* checking for hidden files and directories ... OK
* checking for portable file names ... OK
* checking whether package 'hydroMetrics' can be installed ... OK
* checking installed package size ... OK
* checking package directory ... OK
* checking 'build' directory ... OK
* checking DESCRIPTION meta-information ... OK
* checking top-level files ... OK
* checking for left-over files ... OK
* checking index information ... OK
* checking package subdirectories ... OK
* checking code files for non-ASCII characters ... OK
* checking R files for syntax errors ... OK
* checking whether the package can be loaded ... OK
* checking whether the package can be loaded with stated dependencies ... OK
* checking whether the package can be unloaded cleanly ... OK
* checking whether the namespace can be loaded with stated dependencies ... OK
* checking whether the namespace can be unloaded cleanly ... OK
* checking loading without being on the library search path ... OK
* checking whether startup messages can be suppressed ... OK
* checking dependencies in R code ... OK
* checking S3 generic/method consistency ... OK
* checking replacement functions ... OK
* checking foreign function calls ... OK
* checking R code for possible problems ... OK
* checking Rd files ... OK
* checking Rd metadata ... OK
* checking Rd cross-references ... OK
* checking for missing documentation entries ... OK
* checking for code/documentation mismatches ... OK
* checking Rd \usage sections ... OK
* checking Rd contents ... OK
* checking for unstated dependencies in examples ... OK
* checking installed files from 'inst/doc' ... OK
* checking files in 'vignettes' ... OK
* checking examples ... OK
* checking for unstated dependencies in 'tests' ... OK
* checking tests ...
 OK
* checking for unstated dependencies in vignettes ... OK
* checking package vignettes ... OK
* checking re-building of vignette outputs ... OK
* DONE
Status: OK
Warning: unable to access index for repository https://CRAN.R-project.org/src/contrib:
  cannot open URL 'https://CRAN.R-project.org/src/contrib/PACKAGES'
Warning: unable to access index for repository https://bioconductor.org/packages/3.22/bioc/src/contrib:
  cannot open URL 'https://bioconductor.org/packages/3.22/bioc/src/contrib/PACKAGES'
Warning: unable to access index for repository https://bioconductor.org/packages/3.22/data/annotation/src/contrib:
  cannot open URL 'https://bioconductor.org/packages/3.22/data/annotation/src/contrib/PACKAGES'
Warning: unable to access index for repository https://bioconductor.org/packages/3.22/data/experiment/src/contrib:
  cannot open URL 'https://bioconductor.org/packages/3.22/data/experiment/src/contrib/PACKAGES'
Warning in system2("du", "-k", TRUE, TRUE) :
  running command '"du" -k' had status 322
  Running 'testthat.R'
```

## Main finalization

```text
$ git checkout main
Your branch is up to date with 'origin/main'.
Switched to branch 'main'

$ git pull origin main
Already up to date.
From https://github.com/Arcblade-02/hydroMetrics
 * branch            main       -> FETCH_HEAD

$ git merge feature/finalize-phase2-baseline
Updating 680476f..ce5cf29
Fast-forward
 docs/PHASE2_EXIT_MEMO.md                           |  37 +-
 .../devtools_check_cran_results.txt                | 127 +++++++
 .../final-cran-evidence/devtools_check_results.txt | 127 +++++++
 .../final_cran_evidence_summary.md                 |  15 +
 notes/final-cran-evidence/live_ci_status_report.md |  33 ++
 .../nonbroken_environment_report.md                |  64 ++++
 notes/finalize-phase2-baseline/cleanup_report.md   |  23 ++
 .../final_baseline_summary.md                      |  16 +
 .../merge_and_validation_report.md                 | 380 +++++++++++++++++++++
 .../finalize-phase2-baseline/tag_release_report.md |  37 ++
 .../cran_preflight_report.md                       |  26 ++
 .../testthat/test-final-cran-evidence-artifacts.R  |  40 +++
 .../test-finalize-phase2-baseline-artifacts.R      |  33 ++
 tools/final_cran_evidence_confirmation.R           |  77 +++++
 tools/finalize_phase2_baseline.R                   |  73 ++++
 15 files changed, 1095 insertions(+), 13 deletions(-)

$ git push origin main
To https://github.com/Arcblade-02/hydroMetrics.git
   680476f..ce5cf29  main -> main
```
