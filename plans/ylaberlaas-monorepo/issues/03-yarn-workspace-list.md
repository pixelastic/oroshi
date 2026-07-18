## TLDR

Human-readable formatted workspace list, calling `yarn-workspace-list-raw`.

## What to build

Create `yarn-workspace-list` in the `yarn/workspace/` autoload directory. It:

1. Calls `yarn-workspace-list-raw` (forwarding any path argument)
2. Formats output as a human-readable table with colorized names (using `ICONS[node-monorepo]` icon), relative paths, and descriptions
3. Follows the existing `*-list` pattern (see `yarn-dependency-list`, `yarn-link-list`)

## Acceptance criteria

- [ ] Function exists at `tools/term/zsh/config/functions/autoload/yarn/workspace/yarn-workspace-list`
- [ ] Displays a formatted, colorized table of workspaces
- [ ] Shows name, relative path, and description columns
- [ ] Accepts optional path argument (forwarded to `yarn-workspace-list-raw`)
