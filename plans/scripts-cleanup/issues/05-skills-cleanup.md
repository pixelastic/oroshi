## Skills cleanup — remove npm dep, migrate external skills

### Remove skills npm package

- Delete symlink `scripts/bin/ai/skills`
- Remove `skills` from `package.json` dependencies
- Run `yarn install`

### Remove skills-install and skills-remove

- Delete autoloaded function `skills-install` (calls `skills add`)
- Delete autoloaded function `skills-remove` (calls `skills remove`)

### Migrate external skills to oroshi

4 skills in `~/.claude/skills/` are not symlinks (installed via `skills add`):
- `adhd-daily-planner/`
- `brainstorming/`
- `find-skills/`
- `systematic-debugging/`

Move them to `tools/ai/claude/config/skills/` and replace with symlinks in `~/.claude/skills/`.
