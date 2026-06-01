## TLDR

Update GLOSSARY.md to split `ask user` into `ask user` (default, 3 options) and `ask user — first time` (exception, 2 options + reason).

## What to build

Update `tools/ai/claude/config/hooks/GLOSSARY.md` (note: file is directly in `hooks/`, not in `__docs/`).

The existing `ask user` term is split into two distinct terms. Follow the established vocabulary-entry format with `_Avoid:` annotations.

**New terms to add:**

**ask user**:
The hook output when Solkan **reject**s a command that has already been seen in the current session. The user sees a 3-option dialog: Allow / Allow for session / Deny. No reason is shown — the user has already been informed. Maps to `permissionDecision: "defer"`.
_Avoid_: escalate, defer, session-ask

**ask user — first time**:
The hook output when Solkan **reject**s a command that has never been seen in the current session, or when multiple binaries are rejected at once. The user sees a 2-option dialog (Allow / Deny) with the rejected binary name(s) displayed. Maps to `permissionDecision: "ask"`.
_Avoid_: ask, first-ask, new-ask, warn-ask

The existing `ask user` entry is replaced by these two. Update the Relationships section and the 4-cases table to reflect that a reject now produces either `ask user` or `ask user — first time` depending on session state.

## Acceptance criteria

- [ ] GLOSSARY.md contains an `ask user` entry with `_Avoid:` list
- [ ] GLOSSARY.md contains an `ask user — first time` entry with `_Avoid:` list
- [ ] Each entry documents the `permissionDecision` value it maps to
- [ ] Each entry documents what the user sees in the dialog
- [ ] Each entry documents when it is triggered
- [ ] Old `ask user` entry (which mapped to both cases) is removed or replaced
- [ ] Relationships section updated: a reject now produces `ask user` or `ask user — first time`
- [ ] 4-cases table updated to reflect the two reject outcomes
