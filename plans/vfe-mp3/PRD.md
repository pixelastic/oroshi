## Problem Statement

`vfe` (`git-file-edit`) opens all modified git files in nvim. Binary files like `.mp3` get opened as garbage text — useless and disruptive, especially after batch audio retagging. The current skip list is hardcoded by extension (`.woff2`) or path pattern, and doesn't scale when new binary formats appear.

## Solution

Replace the hardcoded extension-based skip logic with a filetype-group allowlist powered by the existing `filetypes-load-definitions` system. Only files belonging to editable groups (`text`, `script`, `config`) or with unknown extensions pass through. All binary groups (image, audio, video, archive, pdf, ebook, binary, font, minor) are excluded automatically.

Additionally, create a new `font` filetype group to properly classify font files (currently misclassified under `script`), and add `--reply` support to `filetypes-group` to avoid subprocess forks in loops.

## User Stories

1. As a developer, I want `vfe` to skip `.mp3` files, so that nvim doesn't open binary garbage after audio retagging
2. As a developer, I want `vfe` to skip all binary file types (images, video, archives, fonts, etc.), so that I never see non-text files in my editor
3. As a developer, I want new binary extensions added to `filetypes.jsonc` to be automatically excluded from `vfe`, so that I don't need to update skip logic in multiple places
4. As a developer, I want files with unknown extensions to still open in nvim, so that I don't accidentally miss editable files that aren't in the filetypes registry
5. As a developer, I want path-based exclusions (`plans/*/state.json`, `plans/*/scaffold/*`) to keep working, so that generated plan files are still skipped
6. As a developer, I want font files (`.ttf`, `.woff`, `.woff2`, `.otf`, `.eot`) classified in their own filetype group, so that they're correctly categorized across the tooling (ls colors, fzf previews, vfe filtering)
7. As a developer, I want `filetypes-group --reply` to write to `$REPLY` instead of echoing, so that callers in tight loops avoid subprocess overhead

## Implementation Decisions

- **Font filetype group**: New group in `filetypes.jsonc` with color `pink-6`, icon `filetype-font` (placeholder — doesn't exist yet in icon definitions), bold `false`. Extensions: `eot`, `otf`, `ttf`, `woff`, `woff2`. Move `eot`, `ttf`, `woff` out of `script` group.
- **`filetypes-group --reply`**: Use `zparseopts` for `--reply` flag, same pattern as `simplify-path`. When set, write result to `$REPLY` instead of `echo`. Backward-compatible — callers without `--reply` still get `echo`.
- **`git-file-edit` allowlist**: Call `filetypes-load-definitions` once before the loop. Inside the loop, use `filetypes-group --reply` to get the group, then check against an allowlist array `(text script config)`. Files with empty group (unknown extension) are accepted. Remove the `yarn.lock` and `*.woff2` explicit skips (now covered by the allowlist). Keep the two `plans/*/...` path-based skips.
- **Dist rebuild**: Run `filetypes-build` after editing `filetypes.jsonc` to regenerate `dist/filetypes.zsh`.

## Testing Decisions

Tests should verify external behavior only — what gets filtered, what gets through — not internal implementation details like which array is used.

### `filetypes-group` (bats)
- Prior art: existing `filetypes-group.bats` with mocked `filetypes-load-definitions`
- Add tests for `--reply` flag: verify `$REPLY` is set and no stdout output
- Verify backward compat: without `--reply`, output goes to stdout as before

### `git-file-edit` (bats)
- Prior art: existing `git-file-edit.bats` with `bats_git_dir` and mocked `nvim`
- Update "does not open useless files" test to use filetype-group-based exclusions (`.mp3`, `.woff2`)
- Add test that files with unknown extensions are still opened
- Mock `filetypes-load-definitions` with relevant group mappings

## Out of Scope

- Creating the actual `filetype-font` icon glyph — placeholder is sufficient
- Adding a `--reply` flag to other `echo`-based functions (only `filetypes-group` for now)
- Changing behavior of other `filetypes-group` consumers (fzf scripts, etc.)
- Allowlist configurability (hardcoded in `git-file-edit` is fine)
