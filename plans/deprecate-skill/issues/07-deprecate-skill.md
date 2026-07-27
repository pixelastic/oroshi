## TLDR

The `/deprecate` skill definition that orchestrates the full deprecation flow.

## What to build

A skill at `tools/ai/claude/config/skills/deprecate/SKILL.md` following the standard skill format.

### Skill flow

1. **Prepare**: run `deprecate-prepare <project-name>`, parse JSON
2. **Guard — not found**: if `status: "not-found"`, tell user and stop
3. **Guard — npm auth**: if npm package exists but `npmIsLoggedIn` is false, warn user to run `npm-login` first, stop
4. **Ask reason**: ask user for deprecation reason. Rewrite their rough/spoken input into proper English.
5. **Show plan**: display what will happen based on the JSON state:
   - GitHub: update README, disable Renovate, commit, update description, archive
   - npm: deprecate package
   - projects.jsonc: remove entry, rebuild
   - Skip sections that don't apply (no GitHub, no npm, not in projects.jsonc)
6. **Confirm**: user confirms before any changes
7. **Write README**: read existing README from `clonedAt`, prepend:
   ```
   > **⚠️ ARCHIVED**: <reason>

   ---

   <original README>
   ```
8. **Execute**: run `deprecate-end <project-name>`
9. **Report**: tell user what was done based on the result

### Argument

The skill takes a project name as argument: `/deprecate <project-name>`

## Acceptance criteria

- [ ] SKILL.md follows the standard skill format (frontmatter, steps, common rationalizations, checklist)
- [ ] Calls `deprecate-prepare` and `deprecate-end` by name (on PATH)
- [ ] Handles all three guards: not-found, npm auth, user confirmation
- [ ] README format matches the established pattern (blockquote + separator + original)
- [ ] No tests (skill definition)
