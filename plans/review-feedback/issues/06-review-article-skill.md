## TLDR

The `/review-article` skill that orchestrates the full capture-triage-synthesize workflow.

## What to build

A Claude skill that takes a Markdown file or Google Docs URL, prepares a Google Doc for annotation, waits for the user to finish commenting, then synthesizes structured feedback and publishes it as a shareable Google Doc.

End-to-end: user says "review this article ./draft.md" → skill calls `review-article-start` → presents URL → user annotates → user says "done" → skill calls `gdocs2md` + `gdocs-comments-json` → synthesizes feedback → calls `md2gdocs --title "Draft (review)"` → returns shareable URL.

### Files to create

- `tools/ai/claude/config/skills/review-article/SKILL.md` — skill definition
- `tools/ai/claude/config/skills/review-article/references/output-format.md` — the validated feedback format (derived from `feedback-article-monolithic-agents.md`)

### Skill steps

**Step 1 — Prepare:** Extract file path or URL from user input. Call `review-article-start <input>`. Parse JSON output. Present the Google Docs URL to the user: "Here's the doc, go annotate. Tell me when you're done."

**Step 2 — Wait:** User comes back and says they're done (or indicates comments were already left).

**Step 3 — Fetch:** Call `gdocs2md <url>` to get article as Markdown. Call `gdocs-comments-json <url>` to get unresolved comments as JSON. Read both outputs.

**Step 4 — Synthesize:** Read article + comments. Cross-reference each comment against the full article. Auto-resolve comments invalidated by later content. Auto-detect article language (default English). Translate French comments to article language. Group feedback by severity following the reference output format.

**Step 5 — Publish:** Write synthesized feedback to a temp Markdown file. Call `md2gdocs --title "<Article Title> (review)"` to create a Google Doc. Return the shareable URL to the user.

### Output format (from validated example)

- `# Feedback — "<Article Title>"`
- `## TL;DR` — overall impression
- `## Strengths` — named highlights with why they work
- `## Improvements` — grouped by axis (axes adapt to the article: Narration, Content, Clarity/Style, Diagrams, etc.)
- Each item includes the anchor quote from the article + synthesized feedback
- Language matches the article's language

## Acceptance criteria

- [ ] Skill triggers on "review article", "review this article", or `/review-article`
- [ ] Accepts both Markdown file paths and Google Docs URLs
- [ ] Calls `review-article-start` and presents the URL to the user
- [ ] Waits for user confirmation before synthesizing
- [ ] Calls `gdocs2md` and `gdocs-comments-json` to fetch inputs
- [ ] Produces feedback in the validated format (TL;DR, Strengths, Improvements with grouped axes)
- [ ] Auto-detects article language, defaults to English
- [ ] Translates French comments to article language
- [ ] Resolves comments that are addressed by later content in the article
- [ ] Publishes feedback as a Google Doc via `md2gdocs --title`
- [ ] Returns the shareable Google Docs URL
