## TLDR

Rename both review sub-agent briefs, add scope boundaries + reinforcement layers, fix step ordering, update SKILL.md references.

## What to build

Three files in `tools/ai/claude/config/skills/review/`:

**`references/spec-agent.md`** (rename from `specs-agent.md`):
- Header: "Spec Review Agent"
- Preamble: identity as the Spec axis
- Scope: behavioral conformance only — missing/partial requirements, implementation contradicting spec, spec requirements not addressed
- Out of scope: code style/naming/conventions, runtime correctness assumptions, implementation quality/patterns
- Steps: fix ordering to 1 (get diff), 2 (read spec), 3 (review)
- Common Rationalizations: one entry — "I found a flagrant code error, I should flag it" → "You only check behavioral conformance against the spec"
- Checklist: every finding cites a spec line, no finding is about code style or implementation quality

**`references/code-agent.md`** (rename from `standards-agent.md`):
- Header: "Code Review Agent"
- Preamble: identity as the Code Review axis
- Scope: code quality against documented standards — style, naming, conventions, patterns
- Out of scope: spec conformance, missing features, behavioral correctness vs spec
- Common Rationalizations: one entry — "The code doesn't do what was asked, I should flag it" → "You only check code quality against documented standards"
- Checklist: every finding cites a standard source, no finding is about spec conformance

**`SKILL.md`**:
- Update `references/standards-agent.md` → `references/code-agent.md`
- Update `references/specs-agent.md` → `references/spec-agent.md`
- Rename headings: "Standards" → "Code Review", keep "Spec Review"

## Acceptance criteria

- [ ] `specs-agent.md` renamed to `spec-agent.md`
- [ ] `standards-agent.md` renamed to `code-agent.md`
- [ ] Both briefs have Scope + Out of scope sections after preamble
- [ ] Both briefs have Common Rationalizations table (1 entry each)
- [ ] Both briefs have Checklist
- [ ] Spec agent steps correctly ordered (1, 2, 3)
- [ ] SKILL.md references and headings updated
- [ ] No old filenames remain referenced anywhere
