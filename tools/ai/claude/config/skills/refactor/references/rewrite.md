# Rewrite — Wave 2 Analysis Guide

Improve code within function boundaries: normalize patterns, simplify conditions, tighten cohesion.

---

## Categories

### 1. Symmetry normalization (Beck's "Normalize Symmetries")

- Code that does similar things but looks different for no reason
- One function uses `if/else`, its sibling uses early return for the same pattern
- One place destructures, another uses dot access for the same object
- Inconsistent error handling patterns within the same module (some throw, some return null, some use Result types)
- Inconsistent iteration patterns (some use `for`, some use `.map`/`.forEach` for equivalent operations)

Heuristics: look at sibling functions or adjacent blocks — do they follow the same structural pattern? If not, is there a reason?

### 2. Conditional simplification

- Deep nesting that could be flattened with guard clauses / early returns
- Complex boolean expressions that could be extracted into named variables (Beck's "Explaining Variables")
- Repeated condition checks that could be consolidated (Fowler's "Consolidate Conditional Expression")
- Negated conditions that could be inverted for readability (`if !notReady` → `if ready`)
- Switch/if-else chains where several branches do very similar things

Heuristics: count nesting depth — anything >3 levels is a candidate. Look for `if` blocks where the else is the happy path (invert). Look for `&&`/`||` chains longer than 3 conditions.

### 3. Cohesion & reading order

- Related code scattered within a file (a helper defined far from its only caller)
- Unrelated functions grouped together by accident of history
- Public API functions buried between private helpers (reading order: public first, then private in call order)
- Declarations far from their first use (Beck's "Move Declaration and Initialization Together")
- Missing blank lines between logical groups (Beck's "Chunk Statements")

Heuristics: for each function, check where its callers and callees are — are they nearby? Do public functions appear at the top? Are there "sections" of the file that have a theme?

---

## What this wave does NOT do

- Does not delete functions or remove code (that was wave 1: reduce)
- Does not move code between files or extract new modules (that's wave 3: restructure)
- Does not change function signatures or public APIs
- Does not add features or change behavior
- Does not fix bugs (catalog them in GUIDANCE.md `## Bugs found`)

---

## How to scan

1. For each file in scope, read the code with fresh eyes (wave 1 has already cleaned naming and removed dead code)
2. Scan for symmetry violations: compare sibling functions, adjacent blocks, similar patterns
3. Scan for conditional complexity: count nesting depth, look for complex booleans, negated conditions
4. Scan for cohesion issues: check reading order, proximity of related code, logical grouping
5. Record each finding with: file path, line range, category (symmetry/conditional/cohesion), description, suggested change
6. If a bug is discovered, add it to the bugs list — do not create a refactoring issue for it

---

## Ordering findings

Rank by: conditional simplification first (guard clauses are the safest rewrite), then symmetry normalization (makes patterns visible), then cohesion reordering (moving code within a file is low risk but changes diffs).
