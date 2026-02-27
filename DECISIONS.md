# Architecture Decisions

## D-001: License and Clean-Room Boundary
- Decision: `hydroMetrics` is MIT-licensed and implemented under clean-room rules.
- Status: Accepted
- Notes: No code may be copied from GPL-family projects. Derivations must come from literature and independent design.

## D-002: Output Object Model
- Decision: Public API returns S3 objects.
- Status: Accepted
- Notes: Stable, idiomatic R interfaces and print/summary extensibility are required.

## D-003: Internal Engine Style
- Decision: Functions-first internal engine (not R6) for Phase 0/1.
- Status: Accepted
- Notes: Keep internals simple and testable; reconsider R6 only if stateful workflows become necessary.

## D-004: Output Data Formats
- Decision: Tibble-first outputs with optional legacy matrix mode.
- Status: Accepted
- Notes: Primary outputs should be tidy-friendly. Matrix mode remains available for compatibility.

## D-005: R2 Definition
- Decision: `R2` means Pearson correlation squared (`r^2`) and never NSE.
- Status: Accepted
- Notes: Naming and documentation must keep this distinction explicit.
