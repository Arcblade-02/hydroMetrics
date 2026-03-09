# Phase 2 Oldrel Compatibility Repair Log

## Preprocessing repair

- Added `.hm_index_key()` and `.hm_align_indexed_series()` in `R/hm_prepare.R`.
- Replaced fragile direct zoo/xts subsetting by common index with ordered position-based matching.
- Added deterministic errors for non-unique indexed inputs to avoid ambiguous alignment on oldrel.
- Preserved the existing preprocessing contract outside the indexed alignment path.

## Example repair

- Updated the `APFB()` roxygen example in `R/APFB.R` to a minimal deterministic zoo example that still exercises supported indexed behavior.
- Regenerated `man/APFB.Rd` with `devtools::document()`.

## Regression tests

- Added indexed-input regression coverage in `tests/testthat/test-preprocessing.R`.
- Added exported `preproc()` regression coverage in `tests/testthat/test-preproc-export.R`.
- Added indexed `gof()` regression coverage in `tests/testthat/test-gof.R`.
- Added partially overlapping zoo `APFB()` regression coverage in `tests/testthat/test-apfb.R`.

- Documentation regeneration status: pass.

