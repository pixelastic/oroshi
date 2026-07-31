## Problem Statement

The user communicates primarily via speech-to-text but needs to send clear, concise Slack messages to colleagues. The current slack-writer skill has been rewritten with 5 communication principles, but lacks two things: (1) a deterministic lint step to catch filler words, passive voice, and weasel words before sending, and (2) a clipboard copy step so the draft is immediately ready to paste. Without these, the agent does all the quality work non-deterministically, and the user has to manually copy the output.

## Solution

Add prose linting infrastructure (Vale) and a clipboard-copy end script, then wire both into the slack-writer skill as new workflow steps. This follows the same write → lint → fix → end pattern used by zsh-writer and js-writer.

## User Stories

1. As a Slack message author, I want filler words automatically flagged, so that I don't send verbose messages
2. As a Slack message author, I want passive voice detected, so that my messages are direct
3. As a Slack message author, I want weasel words caught, so that my communication is precise
4. As a Slack message author, I want corporate jargon flagged, so that my messages sound natural
5. As a Slack message author, I want the draft copied to my clipboard after generation, so that I can paste it directly into Slack
6. As a Slack message author, I want the lint step to run automatically after the draft is written, so that the agent fixes issues before I see the final version
7. As a prose-lint user, I want to pipe text via stdin, so that I can lint without creating a file
8. As a prose-lint user, I want to pass a file path as argument, so that I can lint files directly
9. As a prose-lint user, I want JSON output with only the fields I need (line, rule, severity, match, message), so that agents consume minimal tokens
10. As a developer, I want Vale installed via a single install script, so that setup is one command on a new machine
11. As a skill author, I want prose-lint to be a standalone script in PATH, so that NeoVim can also call it for markdown linting in the future

## Implementation Decisions

### Module 1 — Vale installation & configuration

- Vale binary installed to `~/local/bin/vale` via an install script at `tools/prose/vale/install`
- Install script downloads the binary AND runs `vale sync` to fetch packages
- Single `vale.ini` config at `tools/prose/vale/vale.ini` — no per-profile configs for now
- Packages: write-good + proselint (cover filler words, passive voice, weasel words, corporate jargon, redundancy, hedging)
- No custom YAML rules for now — packages cover the needs. Custom rules can be added later in a `styles/` directory if needed

### Module 2 — prose-lint script

- Lives at `scripts/bin/prose/prose-lint` (must be in PATH for future NeoVim integration)
- No `--slack` or `--blog` flag for now — single default profile
- Two input modes: file path as argument, or text piped via stdin
- Stdin mode writes to a temp file, passes it to Vale, cleans up after
- Calls Vale with `--config $OROSHI_ROOT/tools/prose/vale/vale.ini --output=JSON`
- Reformats Vale JSON output to a flat array with only useful fields: `{line, rule, severity, match, message}` — strips Action, Description, Link, Span to save agent tokens
- Exit code: 0 if no violations, 1 if violations found

### Module 3 — slack-writer-end script

- Lives at `scripts/bin/ai/slack-writer/slack-writer-end` (consistent with ralph-end, sidequest-end, etc.)
- Takes draft text via stdin or as argument
- Passes it to `clipboard-write`
- Minimal script — the end script is a hook point for future extensions (e.g., posting directly via Slack API when CLI tooling is ready)

### Module 4 — Skill update

- Add Step 3 — Lint: run `prose-lint` on the draft, fix all violations, re-lint until clean
- Add Step 4 — End: run `slack-writer-end` to copy the final draft to clipboard
- The skill calls `prose-lint` directly (no `--slack` flag), and `slack-writer-end` at the end

### Migration included

- Selene config moved from `config/_languages/lua/selene/` to `tools/_languages/lua/selene/` (already done in this branch)
- Reference in `lua-lint-selene` updated to new path (already done)
- `config/` directory removed from repo root (already done)

## Testing Decisions

Good tests verify external behavior: given an input, assert the correct output or side effect. Do not test internal implementation details (temp file creation, jq transformations).

### Module 2 — prose-lint (bats tests)

- Test that passing a file with known violations produces the expected JSON output format
- Test that stdin input produces the same output as file input
- Test that clean text produces an empty array and exit code 0
- Test that violations produce exit code 1
- Test that output contains only the 5 expected fields (line, rule, severity, match, message)
- Prior art: `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats`

### Module 3 — slack-writer-end (bats tests)

- Test that argument text is passed to clipboard-write
- Test that stdin text is passed to clipboard-write
- Mock clipboard-write via bats_mock
- Prior art: `scripts/bin/ai/ralph/__tests__/`

### No tests for

- Module 1 (Vale config) — config files are the artifact
- Module 4 (Skill SKILL.md) — markdown skill file, no executable behavior to test

## Out of Scope

- Blog lint profile (`--blog` flag, `blog.ini`) — future work when blog-writer skill exists
- Custom Vale YAML rules — packages cover current needs, add later if gaps found
- Slack API integration in slack-writer-end — depends on separate slack-cli-tooling sidequest
- NeoVim integration for prose-lint — the script is in PATH and ready, but wiring it into code-quality.lua is separate work
- git-file-lint / lintstaged integration — prose-lint is agent-invoked only for now
- Tone analysis / "sounds like me" calibration — depends on Slack CLI tooling for reading user's own messages

## Further Notes

- The 5 communication principles in the skill (respect attention, natural warmth, important thing first, scannable, complete in one message) are based on research across Smart Brevity, Pyramid Principle, NVC, Basecamp, and Plain Language guidelines
- The skill was already rewritten earlier in this branch (212 → 68 lines). This PRD covers only the lint + end additions
- The `config/` directory migration (Selene files) was done as a cleanup during this session and is included in the branch
