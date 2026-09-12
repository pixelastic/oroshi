# Reduce — Wave 1 Analysis Guide

Surface-level cleanup: remove what's dead, rename what's drifted.

---

## Categories

### 1. Dead code

- Unused functions/methods (no callers)
- Stale imports (imported but never used)
- Unreachable branches (conditions that can never be true)
- Commented-out code (if it's in version control, delete it)
- Unused variables and parameters
- Dead feature flags or config entries

Heuristics: grep for function definitions and check call sites; look for imports not referenced; look for `if false`, `if 0`, blocks after unconditional returns.

### 2. Naming drift

- Functions whose name no longer matches what they do (function grew beyond its original purpose)
- Variables with generic names that could be specific (`data`, `result`, `temp`, `info`)
- Inconsistent naming conventions within the same module (camelCase mixed with snake_case, abbreviations mixed with full words)
- Magic literals (numbers, strings) that should be named constants
- Boolean variables/parameters that read backwards (`disabled` when `enabled` would be clearer)

Heuristics: read each function's name, then read its body — does the name still describe what it does? Look for numeric/string literals used in comparisons or assignments.

---

## What this wave does NOT do

- Does not rewrite logic inside functions (that's wave 2: rewrite)
- Does not move code between files (that's wave 3: restructure)
- Does not add features or change behavior
- Does not fix bugs (catalog them in GUIDANCE.md `## Bugs found`)

---

## How to scan

1. List all files in scope
2. For each file, scan for dead code signals (unused exports, stale imports, unreachable paths)
3. For each file, scan for naming issues (read function names vs bodies, look for magic literals)
4. Record each finding with: file path, line range, category (dead-code or naming), description, confidence (high/medium/low)
5. If a bug is discovered, add it to the bugs list — do not create a refactoring issue for it

---

## Ordering findings

Rank by safety (high confidence first) then by impact (most code removed/clarified first). Dead code removal before naming fixes — removing code first reduces the surface area for renaming.
