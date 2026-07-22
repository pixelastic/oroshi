## Guidance

- Single file to edit: `tools/ai/claude/config/skills/js-writer/references/testing.md`
- This is a skill reference document, not executable code — no tests to run
- Edit under the worktree path, never via the `~/.claude/skills/` symlink
- Use `getOrders(status)` as the example domain throughout: orders with `id`, `status` (pending/shipped), `customer` (Alice/Bob)
- The `__` private-method pattern must appear in examples (it's a project convention)
- Assertions section (toEqual/arrayContaining rules + try/catch error pattern) stays unchanged
- Common Rationalizations follows the same table format as `SKILL.md`'s rationalizations section

## Discoveries
