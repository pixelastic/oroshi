## Guidance

### Testing

- JS tests: `yarn run test <filepath>` (vitest)
- JS lint: `yarn run lint:fix <filepath>`
- Test files live in `__tests__` directories next to source

### File locations

- Extension source: `tools/git/hunk/extensions/added-only.js`
- Pure modules: `tools/git/hunk/extensions/lib/classify.js`, `tools/git/hunk/extensions/lib/layout.js`
- Tests: `tools/git/hunk/extensions/lib/__tests__/classify.test.js`, `tools/git/hunk/extensions/lib/__tests__/layout.test.js`
- Config template: `tools/git/hunk/config/src/config.toml`
- Deploy script: `tools/git/hunk/deploy`
- Color definitions: `tools/term/zsh/config/theming/dist/colors.json`
- hunkdiff types: `node_modules/hunkdiff/dist/npm/extension/extension-api/types.d.ts`

### Conventions

- Extension is ESM (`"type": "module"` in package.json)
- No shebang in .js files — they are imported, not executed
- Config.toml uses `{{color-name:hex}}` template variables processed by `colors-template-render`
- Deploy script symlinks config and extensions to `~/.config/hunk/`
- Use `return early` pattern
- Nerd font glyphs (U+E000–U+F8FF): never use Write tool on files containing them, use Edit only

### Prior art

- Existing hunkdiff config: `tools/git/hunk/config/src/config.toml` — shows theme setup and template variable usage
- Existing deploy: `tools/git/hunk/deploy` — shows symlink pattern
- JS test prior art: `scripts/bin/` modules with vitest

### Key API details

- `ExtensionFileViewSpan.tone` is validated against a hardcoded Set of 6 values — do not invent new tones
- `component.render` returns OpenTUI JSX — `<span fg="#hex">` and `<text fg="#hex">` accept hex colors
- `ExtensionFileViewInput.changes` provides `{ hunkIndex, kind, range }` arrays
- `readDocument("new")` returns the full new-side file content as a string
- `hunk.config` reads from `[extension.added-only]` in config.toml
- Always provide `spans` as fallback alongside `component` for graceful degradation
- Spread original file objects in transforms to preserve opaque `metadata`

## Discoveries

(append-only, updated by agents after each issue)
