## TLDR

Restructure `colors.jsonc` aliases into nested domain groups and update `colors-build` to flatten them with dashes.

## What to build

### `src/colors.jsonc` — nested grouping

Reorganize the flat alias list into nested objects by domain. Each domain becomes a top-level key containing its aliases as children. `colors-build` flattens nested keys with a dash separator.

Example structure (from prototype):
```jsonc
{
  // Code syntax
  "comment":   "gray",
  "error":     "red",

  // Git
  "git": {
    "branch":        "orange",
    "added":         "green",
    "dirty":         "red",
    "branch-main":   "blue"
  },

  // Docker
  "docker": {
    "container":         "yellow",
    "container-running": "green",
    "hash":              "purple"
  }
}
```

A nested key `git.branch` produces `COLORS[git-branch]`. A nested key `docker.container-running` produces `COLORS[docker-container-running]`. Nesting depth should be kept to one level (domain → alias name) — no deeper nesting needed.

Suggested domain groups (adapt to what makes sense for the full alias list):
- top-level (no group): general UI aliases like `comment`, `error`, `success`, `warning`, `info`
- `git`: all git-related aliases
- `docker`: all docker-related aliases
- `yarn`: all yarn-related aliases
- `youtube`: all youtube-related aliases
- `fly`: fly.io aliases
- `vim`: vim-related aliases
- `node`: node version aliases
- `language`: language-specific aliases
- `package`: package manager aliases
- `host`: host aliases
- Other domains as appropriate

### `colors-build` — recursive flattening

Add a recursive key-flattening step that processes the parsed `colors.jsonc` object before alias resolution: for each nested object, join parent key and child key with `-` to produce a flat alias map. Pure values (strings) are kept as-is.

Prior art: `tools/term/zsh/config/theming/colors-build`, `tools/term/zsh/config/theming/__tests__/colors-build.bats`.

## Behavioral Tests

**Nested alias flattening:**
- Nested `git: { branch: "orange" }` produces `COLORS[git-branch]` with the same value as `COLORS[orange]`
- Nested `docker: { "container-running": "green" }` produces `COLORS[docker-container-running]`
- Top-level `"comment": "gray"` still produces `COLORS[comment]` (no flattening needed)

**No regression:**
- All aliases that existed before the restructure still resolve to the same ANSI/hex values

## Acceptance criteria

- [ ] `src/colors.jsonc` aliases are organized into domain groups
- [ ] All existing alias keys (e.g. `git-branch`, `docker-container`) resolve to the same values as before
- [ ] `colors-build` flattens nested keys with `-` separator before alias resolution
- [ ] `dist/colors.json` contains the same alias entries as before the restructure (same keys, same values)
- [ ] All `colors-build.bats` tests pass
