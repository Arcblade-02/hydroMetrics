# Final Release Validation

- Generated: `2026-03-10 11:21:33 +05:30`
- Validation branch: `main`
- Final main HEAD: `ce5cf29cf663f58e14a78c2c40e2e00a75a43a9b`
- Final package version: `0.2.0`
- Local v0.2.0 tag present: `YES`
- Remote v0.2.0 tag present: `YES`
- devtools::test summary: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 915 ]`
- R CMD build result: `pass`
- R CMD check result: `Status: OK`

## Final repository state

```text
$ git status
## main...origin/main

$ git log --oneline -n 5
ce5cf29 Tests: add Phase 2 baseline finalization artifact verification
c3b1787 Chore: finalize Phase 2 stable baseline and tag v0.2.0
e7a9fff Tests: add final CRAN evidence artifact verification
2e22b60 Audit: confirm non-broken CRAN-style checks and live CI status for 0.2.0 baseline
680476f Docs: refresh Phase-2 release-readiness verification artifacts

$ git tag
v0.1.0
v0.2.0
```

## `devtools::test()`

```text
Start: 2026-03-10 11:19:50 +05:30
Command: devtools::test()
Host command: C:\Program Files\R\R-4.5.2\bin\Rscript.exe -e "devtools::test()"
Duration: 23.6 s
[ FAIL 0 | WARN 0 | SKIP 0 | PASS 915 ]
End: 2026-03-10 11:20:15 +05:30
Exit status: 0
ℹ Testing hydroMetrics
```

## `R CMD build .`

```text
Start: 2026-03-10 11:20:26 +05:30
Command: R CMD build .
Host command: C:\Program Files\R\R-4.5.2\bin\x64\Rcmd.exe build .
* checking for file './DESCRIPTION' ... OK
* preparing 'hydroMetrics':
* checking DESCRIPTION meta-information ... OK
* installing the package to build vignettes
* creating vignettes ... OK
* checking for LF line-endings in source and make files and shell scripts
* checking for empty or unneeded directories
Omitted 'LazyData' from DESCRIPTION
* building 'hydroMetrics_0.2.0.tar.gz'
End: 2026-03-10 11:20:36 +05:30
Exit status: 0
```

## `R CMD check --no-manual hydroMetrics_0.2.0.tar.gz`

```text
Start: 2026-03-10 11:20:54 +05:30
Command: R CMD check --no-manual hydroMetrics_0.2.0.tar.gz
Host command: C:\Program Files\R\R-4.5.2\bin\x64\Rcmd.exe check --no-manual hydroMetrics_0.2.0.tar.gz
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
End: 2026-03-10 11:21:33 +05:30
Exit status: 0
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
