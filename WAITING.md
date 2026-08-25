# Waiting

Software upgrades blocked by missing features. Each entry stays until
manually removed after a successful upgrade.

**Agent protocol:** When asked to check this file, for each entry, fetch the
sources and look for releases newer than "Last checked version". Report
findings to the user. Do not modify this file.

## Claude Code CLI

Syntax highlighting in recent versions uses a hardcoded Monokai Extended
palette that's too vivid/aggressive — hurts the eyes after short use. The
color scheme change was silent (not in release notes). Dark themes get Monokai
Extended, light themes get GitHub Light — selected by substring match on the
theme name, not configurable. Custom themes can override UI element colors
(diffAdded, diffRemoved, etc.) but not syntax tokens (keyword, string,
comment, etc.). The only workaround is disabling syntax highlighting entirely
via `syntaxHighlightingDisabled: true`, which is too drastic. Waiting for
custom syntax highlighting theme support or a way to override the diff syntax
palette.

Upgrading would also unblock: using Fable, fixing terminal corruption when
closing Claude (which itself blocks ralph --auto).

- **Current version:** 2.1.84
- **Sources:**
  - https://github.com/anthropics/claude-code/releases
  - https://github.com/anthropics/claude-code/issues/48636
  - https://github.com/anthropics/claude-code/issues/85821
  - https://github.com/anthropics/claude-code/issues/85660
- **Last checked date:** 2026-08-25
- **Last checked version:** 2.1.245

## Hunkdiff

Diffs display as added/removed lines — too much visual noise for code review.
Need a new-side-only view with syntax highlighting: only show the final state
of changed lines, with added lines in purple, modified in violet, deletions
hidden, and context around changes. Built a working `added-only.js` extension
via `registerFileView` that achieves the layout, but it has no syntax
highlighting because the extension API replaces hunkdiff's built-in Shiki
renderer entirely. Explored 5 approaches (theme-only, filtered patch,
transformChangeset, auto-activate file views) — all blocked by API
limitations. Any one of these upstream features would unblock: built-in
`mode = "new-only"`, syntax highlighting in file view extensions, writable
metadata in `transformChangeset`, or auto-active file views. See
`tools/git/hunk/NEW_SIDE_ONLY_VIEW.md` for full exploration notes.

- **Current version:** 0.18.0-beta.0
- **Sources:**
  - https://github.com/modem-dev/hunk/releases
  - https://github.com/modem-dev/hunk/blob/main/CHANGELOG.md
- **Last checked date:** 2026-08-25
- **Last checked version:** 0.19.1
