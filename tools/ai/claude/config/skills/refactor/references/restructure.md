# Restructure — Wave 3 Analysis Guide

Architectural changes across function and module boundaries: deduplicate, split responsibilities, simplify abstractions.

---

## Categories

### 1. Duplication (Rule of Three — 3+ instances only)

- Copy-pasted logic across functions or files (not 2 instances — only 3+)
- Near-duplicates: same structure with small variations that could be parameterized
- Repeated patterns that could become a shared helper or utility

Heuristics: after waves 1-2, symmetry normalization has made duplicates visually obvious. Look for blocks of 5+ lines that appear 3+ times. Look for functions with near-identical signatures doing near-identical work.

Important: Metz's principle — "duplication is far cheaper than the wrong abstraction." Only deduplicate when the abstraction is clear and stable. If unsure, leave the duplication.

### 2. Responsibility violations

- Functions doing too many things (Fowler's "Long Method" smell, Martin's SRP)
  - A function that fetches data AND transforms it AND renders it
  - A function whose description requires "and" — it should be split at the "and"
- Artificial separation — functions that are always called together and share most of their context
  - Two functions that always run in sequence and share the same parameters
  - A function that exists only to call another function with no added logic (unnecessary indirection)
- Classes/modules with mixed concerns (a "utils" file that contains unrelated helpers)

Heuristics: read the function — can you describe it in one sentence without "and"? If not, it's a split candidate. Look for functions that are always called in pairs — merge candidates. Look for "utils" or "helpers" files — regrouping candidates.

### 3. Simplification opportunities

- Unnecessary indirection: wrapper functions that add no value, delegate classes that just forward calls
- Abstractions serving a single call site (Metz's "wrong abstraction" territory)
  - An interface with only one implementation
  - A factory that creates only one type
  - A strategy pattern with only one strategy
- Over-engineering: generic solutions for non-generic problems
- Beck's "One Pile" move: sometimes code has been over-extracted — inline everything back into one function and re-extract with better boundaries

Heuristics: for each abstraction (interface, factory, base class, helper), count its consumers. If there's only one, it may be unnecessary indirection. Look for layers that exist "just in case."

---

## What this wave does NOT do

- Does not rename things (that was wave 1: reduce)
- Does not rewrite internal logic (that was wave 2: rewrite)
- Does not add features or change behavior
- Does not fix bugs (catalog them in GUIDANCE.md `## Bugs found`)

---

## How to scan

1. For each file in scope, look at function and module boundaries (waves 1-2 have already cleaned the code — structure issues are now visible)
2. Scan for duplication: compare functions across files, look for repeated blocks of 5+ lines appearing 3+ times
3. Scan for responsibility violations: read each function's purpose — does it do one thing? Look for always-paired functions. Look for mixed-concern files.
4. Scan for simplification: count consumers of each abstraction, look for single-use wrappers, identify over-engineering
5. Record each finding with: file path(s), line range(s), category (duplication/responsibility/simplification), description, suggested refactoring (extract/merge/inline/move)
6. If a bug is discovered, add it to the bugs list — do not create a refactoring issue for it

---

## Ordering findings

Rank by: simplification first (inlining unnecessary indirection is safest — you're removing code), then responsibility splits (extract function/class is well-understood), then duplication (deduplication requires choosing the right abstraction — highest judgment needed, do last).
