## Guidance

- Yarn wrapper scripts live in `scripts/yarn/`, global bins in `scripts/bin/`
- Lint-staged config is `lintstaged.config.js` at repo root
- The global `colors-reload` must not be modified — it's used for manual reload too
- No tests needed — this is a config/plumbing change
- Verify by committing a colors.jsonc change and checking that dist files are staged

## Discoveries
