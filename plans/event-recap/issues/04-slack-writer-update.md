## TLDR

Rename `slack-writer-end` → `slack-writer-tick`, add iteration loop and `--profile slack-writer` to slack-writer skill.

## What to build

**Rename script:**
- Rename `scripts/bin/ai/slack-writer/slack-writer-end` → `scripts/bin/ai/slack-writer/slack-writer-tick`
- Same behavior, new name (reflects it's called at every iteration, not just at the end)

**Update skill file** (`tools/ai/claude/config/skills/slack-writer/SKILL.md`):
- Step 5 (Lint): change `prose-lint <draftPath>` → `prose-lint --profile slack-writer <draftPath>`
- Step 6 (Finalize): replace `slack-writer-end` with `slack-writer-tick`. Add iteration loop: after showing the draft, ask user for confirmation. If edits requested, loop back to step 4 (Write draft). If approved, skill ends.
- Update checklist: `slack-writer-end` → `slack-writer-tick`

**Update existing tests:**
- Find and update any bats tests that reference `slack-writer-end` → `slack-writer-tick`

## Scaffolding Tests

- `slack-writer-end` no longer exists at old path
- `slack-writer-tick` exists at new path
- `slack-writer/SKILL.md` references `slack-writer-tick`, not `slack-writer-end`
- `slack-writer/SKILL.md` references `--profile slack-writer`

## Acceptance criteria

- [ ] `scripts/bin/ai/slack-writer/slack-writer-end` no longer exists
- [ ] `scripts/bin/ai/slack-writer/slack-writer-tick` exists with same behavior
- [ ] `slack-writer/SKILL.md` references `slack-writer-tick` everywhere
- [ ] `slack-writer/SKILL.md` uses `--profile slack-writer` in lint step
- [ ] `slack-writer/SKILL.md` has iteration loop (tick → show → confirm → loop or end)
- [ ] Existing bats tests updated and passing
- [ ] `slack-writer-tick` passes `zsh-lint`
