## Problem Statement

The slack-writer skill has three issues:
1. It writes in French when the user's input is in French, despite the rule "default English." The guardrail is too soft — the model rationalizes around it.
2. After user-requested edits post-finalization, `slack-writer-end` (clipboard copy) is not re-called, leaving stale content in the clipboard.
3. It uses Markdown formatting (bold, links) that doesn't render correctly in non-Slack contexts (email, other tools).

## Solution

Strengthen the SKILL.md instructions:
1. Add a dedicated Language step (new Step 3) that forces a visible language decision before writing. Default English, French only on explicit user request.
2. Add a loop instruction on the Finalize step: after any edit, re-run lint + `slack-writer-end`.
3. Replace formatting guidance with an allowlist: bullets, numbered lists, `code` backticks only.

## User Stories

1. As a user who writes brain dumps in French, I want the skill to always draft in English by default, so that I don't have to manually re-request English every time.
2. As a user who requests edits after finalization, I want the clipboard to always contain the latest draft, so that I can paste without worrying about stale content.
3. As a user who uses the skill for email and other non-Slack contexts, I want plain text output (no bold, no link markup), so that the message renders correctly everywhere.
4. As a user, I want bullets and code backticks preserved, so that structured content stays scannable.
5. As a user, I want the language decision stated visibly before writing, so that I can catch a wrong choice before the draft is written.

## Implementation Decisions

- Single file change: SKILL.md only. No code changes to `slack-writer-start` or `slack-writer-end`.
- New Step 3 (Language) inserted between Assess context and Write draft. All subsequent steps renumbered.
- Language step exit criterion: model must state "Language: English" (or French if explicitly requested) before proceeding.
- Common Rationalizations table expanded with: "input language is not a valid signal for output language."
- Checklist updated with language verification item.
- Finalize step gets a loop instruction: "If user requests changes, edit draft, re-run Steps 5-6."
- Principle 3 (Scannable) rewritten with formatting allowlist: bullets, numbered lists, `code` backticks. Nothing else.

## Testing Decisions

- No automated tests. SKILL.md is a prompt, not executable code. Verification is manual: invoke the skill and check behavior.

## Out of Scope

- Code-level language enforcement (e.g., `--lang` flag on `slack-writer-start`).
- Changes to `slack-writer-start` or `slack-writer-end` commands.
- Changes to `prose-lint` rules.

## Further Notes

The step numbering after this change: 1-Setup, 2-Assess context, 3-Language, 4-Write draft, 5-Lint, 6-Finalize.
