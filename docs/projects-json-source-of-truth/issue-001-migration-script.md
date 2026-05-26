## PRD

[projects-json-source-of-truth/PRD.md](./PRD.md)

## What to build

A one-shot ZSH migration script (`src/projects-migrate`) that reads the existing `src/projects-list.zsh` associative array and writes `src/projects.json` in the new nested source format.

The output must be sorted alphabetically by project name (via `jq --sort-keys`). Color values are written as their semantic name only (e.g. `"YELLOW_7"`). Icon characters must be copied verbatim from the ZSH array without any re-encoding — never pass them through string transformations that could corrupt private-use-area codepoints. Paths are written with tilde notation, trailing slash stripped (the build script normalises it). `hideNameInPrompt` is only written when its value is `1`.

The script is run once, verified, then left in place for reference.

## Acceptance criteria

- [ ] `src/projects.json` exists after running the migration script
- [ ] All projects from `projects-list.zsh` are present in `src/projects.json`
- [ ] Top-level keys are sorted alphabetically
- [ ] Each project object contains `background`, `foreground`, `icon` when defined in the source
- [ ] Each project object contains `path` with tilde notation and no trailing slash
- [ ] `hideNameInPrompt` is present and `true` only for projects that had it set to `1`
- [ ] Icon characters are identical to those in `projects-list.zsh` (no corruption)
- [ ] Projects that have only an icon (no path, no colors) are included with just the `icon` key

## Blocked by

None — can start immediately.
