## Guidance

### Testing

- Node.js tests: `yarn run test <filepath>`
- ZSH tests: `bats <filepath>`
- Node.js lint: `yarn run lint:fix <filepath>`
- ZSH lint: `zsh-lint <filepath>`
- Bats lint: `bats-lint <filepath>`

### File locations

- Google tools: `scripts/bin/google/`
- Shared auth helper: `scripts/bin/google/googleAuth.js`
- Markdown tools: `scripts/bin/markdown/`
- AI skill scripts: `scripts/bin/ai/review-article/`
- Skill definition: `tools/ai/claude/config/skills/review-article/`
- Token storage: `~/.oroshi/private/config/google/tokens.json`
- Feedback format reference: `/home/tim/local/www/projects/dashboard/data/feedback-article-monolithic-agents.md`

### Conventions

- ZSH wrapper pattern: `#!/usr/bin/env zsh` + `set -e` + `node ${0:A:h}/<name>.js "$@"`
- Node.js: ES modules, `package.json` has `"type": "module"`
- Each Node.js tool in its own subfolder with ZSH wrapper, .js files, `__tests__/`
- JSON output from ZSH scripts: use `jo` or `jq -n`
- Prior art for Node.js + ZSH wrapper: `scripts/bin/git/commit/git-commit-message/`
- Prior art for AI ZSH scripts: `scripts/bin/ai/deprecate/deprecate-prepare`
- Prior art for bats tests with mocks: `scripts/bin/ai/deprecate/__tests__/`
- Prior art for Node.js tests: `scripts/bin/git/commit/git-commit-message/__tests__/`

### Key decisions

- `googleapis` npm package for all Google API calls
- One professional Google account, one OAuth app, one refresh token
- Hardcoded `Automation/Docs/` folder on professional Drive
- `md2gdocs` is generic (not review-specific), lives in markdown domain
- Feedback output format validated on `feedback-article-monolithic-agents.md`

## Discoveries

### Issue 02 — md2gdocs
- HTML upload via Drive API (`media: { mimeType: 'text/html' }` + `mimeType: 'application/vnd.google-apps.document'`) is simpler than building Google Docs API batchUpdate requests — Google handles HTML-to-Doc conversion
- `splitBlocks` needs line-by-line reduce (not split on `\n\n`) because headings must be their own block even without blank line separators

### Issue 03 — gdocs2md
- Google Docs API paragraphs with `bullet` property reference `lists[listId].listProperties.nestingLevels[n].glyphType` — falsy glyphType means unordered, truthy (e.g. `DECIMAL`) means ordered
- Consecutive non-list paragraphs need explicit blank-line separation (`\n\n`) — joining `text\n` lines without it produces no visible paragraph breaks

### Issue 01 — Google Login
- OAuth2Client needs clientId+clientSecret for automatic token refresh — passing zero args creates a crippled client
- Token file stores full token object (access_token, refresh_token, expiry_date) but `googleAuth` should only set `refresh_token` as credential to avoid stale access tokens
- Token path must use `OROSHI_ROOT` env var, not `HOME/.oroshi`
