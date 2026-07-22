## TLDR

Restructure testing.md from 4 to 8 sections with setup design philosophy, lifecycle hooks, it.each guidance, and Common Rationalizations. Unify all examples around `getOrders`.

## What to build

Rewrite `tools/ai/claude/config/skills/js-writer/references/testing.md` with this section order:

1. **Test file naming** — unchanged
2. **Test conventions** — extracted from old "Test structure": variable names (`input`, `actual`, `expected`), `describeName`/`testName`, `dedent`, `vi.spyOn(__, 'method').mockReturnValue(...)`. Remove setup/it.each bullets (they move to dedicated sections). Code example: short `getOrders` snippet showing spyOn + variable naming.
3. **Setup design** — new section. Lead with: "Prefer building a single rich context shared across tests that covers many edge cases rather than designing a specific context per test. Each test observes a different facet of that same context." Code example: `beforeEach` with `vi.spyOn(__, 'fetchOrders')` returning 3 orders (pending/Alice, shipped/Bob, shipped/Alice).
4. **Lifecycle hooks** — new section. Rules:
   - `beforeEach` by default — fresh context per test
   - `beforeAll` when setup is expensive and all tests are read-only
   - Always clean up in the symmetric hook (`afterEach`/`afterAll`)
   - Migrate hook rules currently in Filesystem tests section here
5. **`it.each` vs standalone `it`** — new section. Rules:
   - Use `it.each` when tests share the same structure (same sequence of operations), even if fixtures and expectations differ
   - Use `input`/`expected` keys; named keys if multiple inputs; `title` key if input is too long
   - Reserve standalone `it` for side effects, errors, or flows that genuinely differ in structure
   - Prefer one `it.each` with many rows over many standalone `it` blocks
   - Code example: `it.each` with `getOrders('shipped')`, `getOrders('pending')`, `getOrders('cancelled')` + standalone `it` for `saveHistory` side effect
6. **Filesystem tests** — trimmed. Keep `let testDirectory` at describe scope, `tmpDirectory('scope')` assignment, code example. Remove `beforeEach`/`afterEach` rules (migrated to Lifecycle hooks).
7. **Assertions** — unchanged. Keep `toEqual`/`arrayContaining` rules and try/catch error pattern.
8. **Common Rationalizations** — new section. Table with 2 entries:
   - "`arrayContaining` + `toHaveLength` is safer because order doesn't matter" → "If full content is known, use `toEqual` with the exact array. Sort if order is non-deterministic. `arrayContaining` is for genuine subset checks only."
   - "The shared mock should be minimal so tests are self-contained" → "If most tests override the setup, the setup is wrong."

All code examples use the `getOrders(status)` domain with `import { __, getOrders } from '../getOrders.js'`.

## Acceptance criteria

- [ ] File has 8 sections in the specified order
- [ ] "Test structure" renamed to "Test conventions" — contains only mechanical rules
- [ ] Setup design section present with rich-context philosophy and mock example
- [ ] Lifecycle hooks section present with beforeEach/beforeAll/cleanup rules
- [ ] `it.each` vs standalone `it` section present with structural-matching guidance
- [ ] Filesystem tests trimmed — hook rules removed, `let testDirectory` pattern kept
- [ ] Assertions section unchanged
- [ ] Common Rationalizations section present with 2 entries
- [ ] All code examples use `getOrders` domain consistently
- [ ] No duplicate guidance between sections (hooks live in Lifecycle hooks only, not in Filesystem tests)
