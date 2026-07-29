## Problem Statement

When reviewing colleagues' blog posts, the user generates stream-of-consciousness feedback while reading. Some notes become irrelevant paragraphs later (e.g. "they should mention X" then X is mentioned two sentences later). There is no system to capture raw thoughts anchored to specific passages, triage them (some are stale, some critical), and synthesize them into structured, prioritized feedback the author can act on.

## Solution

A skill-driven workflow that uses Google Docs as the annotation layer and Claude as the synthesis engine:

1. User invokes `/review-article` with a Markdown file path or Google Docs URL
2. A deterministic script prepares a Google Doc in the shared `Automation/Docs/` folder on the professional Drive, and returns the URL
3. User opens the Google Doc, highlights passages, and dictates comments in French via speech-to-text
4. User tells the agent they're done annotating
5. The agent fetches the article content (as Markdown) and unresolved comments (as JSON) via CLI tools
6. The agent cross-references comments against the full article, auto-resolves notes invalidated by later content, translates French comments to the article's language, and produces structured feedback grouped by severity
7. The agent publishes the feedback as a new Google Doc in the same shared folder and returns the URL for sharing with the author

## User Stories

1. As a reviewer, I want to authenticate once with Google so that all Google tools work without re-authenticating
2. As a reviewer, I want to convert a local Markdown file to a Google Doc so that I can annotate it with Google Docs commenting UX
3. As a reviewer, I want the Google Doc created in my professional shared folder so that I don't have to move it manually
4. As a reviewer, I want to specify a custom title for the Google Doc so that it's identifiable in Drive
5. As a reviewer, I want to highlight text in Google Docs and dictate comments in French so that capturing feedback is fast and doesn't interrupt my reading flow
6. As a reviewer, I want to invoke `/review-article` with either a Markdown path or a Google Docs URL so that I can start fresh or resume an existing review
7. As a reviewer, I want the skill to detect whether my input is a file path or a URL and handle both transparently so that I don't need to think about it
8. As a reviewer, I want to be told "go annotate, tell me when done" so that I can take my time reviewing without the agent waiting in context
9. As a reviewer, I want the agent to fetch only unresolved comments so that already-handled feedback is excluded
10. As a reviewer, I want the agent to read the article content from the Google Doc (not the original Markdown) so that any edits made in Docs are reflected
11. As a reviewer, I want the agent to detect when a comment is invalidated by later content in the article so that stale notes are marked as resolved
12. As a reviewer, I want the agent to translate my French comments into the article's language so that the author receives feedback in their language
13. As a reviewer, I want the feedback language to match the article's language (default English) so that it's immediately usable by the author
14. As a reviewer, I want the feedback structured as TL;DR / Strengths / Improvements (grouped by axis) so that the author can prioritize
15. As a reviewer, I want each feedback item to include the relevant passage from the article so that the author knows exactly what I'm referring to
16. As a reviewer, I want the synthesized feedback published as a Google Doc in the same shared folder so that I can share it with a link
17. As a reviewer, I want the feedback Doc titled "<Article Name> (review)" so that it's identifiable alongside the original
18. As a reviewer, I want to extract the text content of a Google Doc as Markdown from the command line so that the agent can read the article
19. As a reviewer, I want to extract unresolved comments from a Google Doc as JSON from the command line so that the agent can process my annotations
20. As a reviewer, I want all Google tools to work as standalone CLI commands so that they're usable outside of Claude too

## Implementation Decisions

### Architecture: 6 modules

**Module 1 — `google-login` (Node.js + ZSH wrapper)**
- Lives in `scripts/bin/google/google-login/`
- Opens browser for OAuth 2.0 consent flow with Docs + Drive scopes
- Saves refresh token to `~/.oroshi/private/config/google/tokens.json`
- Refresh token is long-lived (never expires unless revoked), committed in private repo
- Uses a local HTTP server to catch the OAuth redirect callback

**Module 2 — `googleAuth.js` (shared Node.js helper)**
- Lives in `scripts/bin/google/googleAuth.js`
- Reads refresh token from disk, creates an authenticated `googleapis` client
- Access token refresh is handled automatically by the `googleapis` package (in memory, no disk writes)
- Imported by all Google-facing Node.js modules

**Module 3 — `md2gdocs` (Node.js + ZSH wrapper)**
- Lives in `scripts/bin/markdown/md2gdocs/`
- Reads a local Markdown file, creates a Google Doc in the hardcoded `Automation/Docs/` folder on the professional Drive
- Accepts `--title` flag (defaults to filename basename without extension)
- Outputs the Google Docs URL to stdout
- Always creates a new Doc (no update/dedup logic)
- Imports `googleAuth.js` from the google directory

**Module 4 — `gdocs2md` (Node.js + ZSH wrapper)**
- Lives in `scripts/bin/google/gdocs/gdocs2md/`
- Takes a Google Docs URL or document ID as argument
- Fetches document content via Docs API, converts to Markdown
- Outputs Markdown to stdout

**Module 5 — `gdocs-comments-json` (Node.js + ZSH wrapper)**
- Lives in `scripts/bin/google/gdocs/gdocs-comments-json/`
- Takes a Google Docs URL or document ID as argument
- Fetches comments via Drive API, filters to unresolved only
- Outputs JSON array to stdout: `[{"anchor": "...", "comment": "..."}]`
- No author field, no resolved comments

**Module 6 — `review-article-start` (ZSH)**
- Lives in `scripts/bin/ai/review-article/`
- Takes one argument: a file path or Google Docs URL (as passed by the user in natural language, extracted by the skill)
- If file path: calls `md2gdocs` to create a Google Doc, returns JSON with URL
- If Google Docs URL: returns JSON with URL as-is
- Returns JSON: `{"url": "https://docs.google.com/..."}`

### Skill: `/review-article`

- Lives in `tools/ai/claude/config/skills/review-article/SKILL.md`
- Step 1: Extract file path or URL from user's natural language input. Call `review-article-start` with it. Present the Google Docs URL to the user.
- Step 2: Wait for user to say they're done annotating.
- Step 3: Call `gdocs2md <url>` to get article content. Call `gdocs-comments-json <url>` to get comments. Read both.
- Step 4: Synthesize feedback — cross-reference comments with article, auto-resolve stale notes, translate French to article language, group by severity. Follow the output format from the reference example.
- Step 5: Write feedback to a temp Markdown file. Call `md2gdocs --title "<Article Title> (review)"` to publish. Return the Google Docs URL to user.

### Output format

Follows the structure from the validated example:
- Title: `Feedback — "<Article Title>"`
- TL;DR: overall impression + positioning
- Strengths: named highlights with why they work
- Improvements: grouped by axis (e.g. Narration, Content, Clarity/Style, Diagrams — axes adapt to the article)
- Each item includes the anchor quote + synthesized feedback

### Dependencies

- Add `googleapis` to `package.json`
- One professional Google account (OAuth app with Docs + Drive scopes)

### Naming and conventions

- ZSH wrappers: `#!/usr/bin/env zsh` + `node ${0:A:h}/<name>.js "$@"`
- Node.js: ES modules (`import`/`export`), matching existing `git-commit-message` pattern
- Each Node.js tool in its own subfolder (wrapper + .js files + `__tests__/`)

## Testing Decisions

Tests should verify the transformation chain while mocking all Google API calls. Good tests here exercise the logic between "raw input" and "API call payload" (and vice versa for fetching).

**Modules with tests:**

- **`md2gdocs`**: Mock the `googleapis` Docs/Drive client. Test that a given Markdown input produces the correct API call structure (document body, title, folder ID). Test `--title` flag behavior and default title derivation.

- **`gdocs2md`**: Mock the API response (a Google Docs JSON document structure). Test that the conversion to Markdown is correct — headings, paragraphs, bold/italic, links, lists.

- **`review-article-start`**: ZSH script with deterministic logic. Test URL detection vs file path detection. Mock `md2gdocs` via `bats_mock`. Verify JSON output structure.

**Prior art:** `scripts/bin/git/commit/git-commit-message/__tests__/` for Node.js test patterns with mocked external calls; `scripts/bin/ai/deprecate/__tests__/` for ZSH script tests with `bats_mock`.

**No tests for:**
- `google-login` (interactive OAuth flow, no transformable logic)
- `gdocs-comments-json` (thin API wrapper with minimal transformation — just filtering resolved comments)
- `googleAuth.js` (reads a file and passes it to googleapis — trivial)
- The skill itself (non-deterministic LLM behavior)

## Out of Scope

- **Slides**: reviewing Google Slides or PDF slide decks (review-slide already handles design review)
- **Multiple Google accounts**: only one professional account for now
- **Configurable Drive folder**: hardcoded `Automation/Docs/` — configurable later via flag
- **`review-article-end`**: cleaning up raw comments after synthesis — future enhancement
- **Google Docs MCP server**: all tools are CLI-first, no MCP integration
- **Integration tests**: no real Google API calls in tests — unit tests with mocks only
- **Updating existing Docs**: `md2gdocs` always creates new, never updates

## Further Notes

- The refresh token saved by `google-login` is long-lived and stable — same treatment as API keys in `~/.oroshi/private/`
- `md2gdocs` is generic (not review-specific) — useful for any Markdown-to-Google-Docs conversion
- The feedback output format was validated by the user on a real review (`feedback-article-monolithic-agents.md`) — use it as the reference for the skill's synthesis step
- French-to-English translation happens in the synthesis step (LLM), not in any script
- The article language is auto-detected by the LLM; default is English, French if the article is in French
