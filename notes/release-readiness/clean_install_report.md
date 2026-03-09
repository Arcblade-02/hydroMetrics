# Clean Install Report

- Generated: 2026-03-10 00:14:30 IST
- Source version: 0.1.0
- Working directory: `D:/R Package/hydroMetrics`

## Command sequence

1. `remove.packages("hydroMetrics")` when already installed
2. `devtools::install_deps(dependencies = TRUE)`
3. `devtools::install()`
4. `library(hydroMetrics)`

## Installed dependency summary

```text
R6==2.6.1
testthat==3.3.2
covr==3.6.5
ggplot2==4.0.2
hydroGOF==0.6-0.1
knitr==1.51
rmarkdown==2.30
zoo==1.8-15
```

## Result classification

- Install result: `PASS`
- Load result: `PASS`
- Namespace export count observed: `3`

## Startup and command output

```text
SESSION_START
DEPENDENCY_SUMMARY_START
R6==2.6.1
testthat==3.3.2
covr==3.6.5
ggplot2==4.0.2
hydroGOF==0.6-0.1
knitr==1.51
rmarkdown==2.30
zoo==1.8-15
DEPENDENCY_SUMMARY_END
REMOVE_START
REMOVE_DONE
INSTALL_DEPS_START
INSTALL_DEPS_DONE
INSTALL_START
ERROR: ! Native call to `processx_exec` failed
Caused by error in `chain_call(c_processx_exec, command, c(command, args), pty, pty_options, …`:
! creating write pipe for 'C:/PROGRA~1/R/R-45~1.2/bin/x64/Rcmd.exe' (system error 5, Access is denied.
) @win/stdio.c:164 (processx__create_pipe)
FALLBACK_INSTALL_START
$ C:/PROGRA~1/R/R-45~1.2/bin/x64/Rcmd.exe INSTALL --library=D:\RPACKA~1\HYDROM~1\notes\RELEAS~1\TMP-LI~1 .
[stderr]
* installing *source* package 'hydroMetrics' ...
** this is package 'hydroMetrics' version '0.1.0'
** using staged installation
** R
** inst
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (hydroMetrics)
FALLBACK_INSTALL_DONE
LOAD_START
LOAD_DONE
EXPORT_COUNT==3
SESSION_END
```
