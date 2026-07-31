## TLDR

Decide whether to disable `Google.Timeless` and `Google.Passive` in the default Vale profile or create a dedicated Slack profile, then implement the chosen approach.

## What to build

`Google.Timeless` and `Google.Passive` are suggestion-level rules designed for evergreen product documentation. They hurt Slack messages: "latest" has more semantic value than "new", and passive voice ("has this been discussed?") is natural in conversation.

The decision to make:
- (A) Disable in `default.ini`, re-enable in `blog.ini` only
- (B) Create a `slack.ini` profile that disables them, keep default as-is
- (C) Disable everywhere

Factors to evaluate:
- List all existing Vale profiles and their differences (`tools/prose/vale/dist/`)
- Which other rules are suggestion-level in default? Do they also cause issues for Slack?
- Does `prose-lint --profile <name>` already support arbitrary profile names?
- Maintenance cost: one more profile to keep in sync vs surgical override in blog
- If a Slack profile is created, the slack-writer SKILL.md must call `prose-lint --profile slack`

This is a HITL issue. Present the analysis and recommendation to the user before implementing.

## Acceptance criteria

- [ ] Analysis of existing profiles and suggestion-level rules presented to user
- [ ] User approved the chosen strategy
- [ ] Vale config updated (new profile or modified existing ones)
- [ ] `Google.Timeless` and `Google.Passive` no longer trigger on Slack messages
- [ ] If new profile created: slack-writer SKILL.md updated to use it
- [ ] Existing blog/default linting behavior unchanged (or intentionally changed per decision)
