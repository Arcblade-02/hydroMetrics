# Clean-Room Policy

## Purpose
This project is an independent MIT-licensed implementation of hydrological evaluation tooling. All code must be created in a clean-room manner.

## No GPL Code Copying
- Do not copy, translate, adapt, or paste code from GPL, AGPL, LGPL, or any copyleft-licensed source.
- Do not use non-permissive source code as implementation templates.
- If a source license is unclear, treat it as prohibited until verified.

## Allowed Inputs
- Peer-reviewed papers, textbooks, standards, and public domain definitions.
- Original derivations and independent pseudocode written within this repository.
- Synthetic examples created by maintainers.

## Derivation Rules
- Work from equations and definitions in literature, not from existing package code.
- Record formula choices and assumptions in `DECISIONS.md` and `inst/REFERENCES.md`.
- Prefer explicit symbol definitions, domains, and edge-case behavior before coding.

## Prohibited Practices
- Side-by-side reimplementation from non-permissive source files.
- Reverse engineering from proprietary or copyleft code output behavior as a cloning target.
- Importing snippets from forums or gists without clear permissive licensing.

## Review Requirements
- New metric implementations must cite at least one paper/source in `inst/REFERENCES.md`.
- Pull requests should state the derivation source and confirm clean-room compliance.
- Suspected contamination requires immediate quarantine and rewrite.

## Enforcement
Maintainers may reject or remove contributions that do not meet this policy.
