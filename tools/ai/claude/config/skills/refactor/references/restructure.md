# Restructure — Wave 3 Analysis Guide

Architectural changes across function and module boundaries: deduplicate, split
responsibilities, simplify abstractions.

---

## Categories

### 1. Duplication (Rule of Three — 3+ instances only)

- Copy-pasted blocks of 5+ lines across functions or files (not 2 instances — only 3+)
- Near-duplicates: same structure with small variations that could be parameterized
- Repeated patterns that could become a shared helper or utility

Important: Metz's principle — "duplication is far cheaper than the wrong abstraction."
Only deduplicate when the abstraction is clear and stable. If unsure, leave the duplication.

### 2. Responsibility violations

- Functions doing too many things (Fowler's "Long Method" smell, Martin's SRP)
  - A function that fetches data AND transforms it AND renders it
  - A function whose description requires "and" — it should be split at the "and"
- Artificial separation — functions that are always called together and share most of their context
  - Two functions that always run in sequence and share the same parameters
  - A function that exists only to call another function with no added logic (unnecessary indirection)
- Classes/modules with mixed concerns (a "utils" file that contains unrelated helpers)

### 3. Simplification opportunities

- Unnecessary indirection: wrapper functions that add no value, delegate classes that just forward calls
- Abstractions serving a single call site (Metz's "wrong abstraction" territory)
  - An interface with only one implementation
  - A factory that creates only one type
  - A strategy pattern with only one strategy
- Over-engineering: generic solutions for non-generic problems
- Beck's "One Pile" move: sometimes code has been over-extracted — inline
everything back into one function and re-extract with better boundaries

---

## What this wave does NOT do

- Does not add features or change behavior
- Does not fix bugs (catalog them in GUIDANCE.md `## Bugs found`)

---

## How to scan

1. For each file in scope, look at function and module boundaries
2. Scan for duplication: compare functions across files, look for repeated blocks of 5+ lines appearing 3+ times
3. Scan for responsibility violations: read each function's purpose — does it do one thing?
    - Look for always-paired functions. Look for mixed-concern files.
4. Scan for simplification: count consumers of each abstraction, look for single-use wrappers, identify over-engineering
5. Record each finding with: file path(s), line range(s), category (duplication/responsibility/simplification), description, suggested refactoring (extract/merge/inline/move)
6. If a bug is discovered, add it to the bugs list — do not create a refactoring issue for it

---

## Ordering findings

Rank by:
- simplification first (inlining unnecessary indirection is safest — you're removing code),
- then responsibility splits (extract function/class is well-understood),
- then duplication (deduplication requires choosing the right abstraction — highest judgment needed, do last).
