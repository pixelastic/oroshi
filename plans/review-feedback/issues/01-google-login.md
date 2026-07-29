## TLDR

OAuth authentication for Google APIs — browser login flow, token storage, shared auth helper.

## What to build

A `google-login` CLI command that opens the browser for Google OAuth 2.0 consent, catches the redirect on a local HTTP server, and saves the refresh token to disk. Plus a shared `googleAuth.js` helper that all Google-facing tools import to get an authenticated client.

End-to-end: user runs `google-login` → browser opens → user consents → refresh token saved to `~/.oroshi/private/config/google/tokens.json` → all subsequent Google tools work without re-authenticating.

### Files to create

- `scripts/bin/google/google-login/google-login` — ZSH wrapper
- `scripts/bin/google/google-login/google-login.js` — OAuth flow: start local HTTP server, open browser to consent URL (Docs + Drive scopes), catch redirect, extract refresh token, write to disk
- `scripts/bin/google/googleAuth.js` — shared helper: reads refresh token from `~/.oroshi/private/config/google/tokens.json`, returns an authenticated `google.auth.OAuth2` client. Access token refresh is automatic via the `googleapis` package.

### Dependencies

- Add `googleapis` to `package.json`
- Google Cloud project with OAuth 2.0 credentials (client ID + secret) — stored as constants or env vars in the login script. The user will need to create this project manually in Google Cloud Console (HITL).

### Conventions

- ZSH wrapper pattern: `#!/usr/bin/env zsh` + `set -e` + `node ${0:A:h}/google-login.js "$@"`
- Node.js: ES modules (`import`/`export`)
- Token path: `~/.oroshi/private/config/google/tokens.json`
- Scopes: `https://www.googleapis.com/auth/documents`, `https://www.googleapis.com/auth/drive.file`

## Acceptance criteria

- [ ] `googleapis` added to `package.json` and installed
- [ ] `google-login` opens browser, completes OAuth consent, saves refresh token
- [ ] `googleAuth.js` reads token from disk and returns authenticated client
- [ ] `googleAuth.js` exits with clear error if token file is missing ("run google-login first")
- [ ] Token file path is `~/.oroshi/private/config/google/tokens.json`
