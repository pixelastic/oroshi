## Problem Statement

When creating presentation slides, there is no automated way to evaluate whether a slide follows established visual design principles. The author must rely on their own eye or ask a designer — both slow and inconsistent. Slides often pack multiple pieces of information into a single visible state (title, date, bullet points, images, call-to-action), and it's easy to break design rules without noticing.

## Solution

A Claude Code skill called `review-slide` that accepts a screenshot of a slide and evaluates it against 12 design principles organized in 4 independent groups. Four sub-agents run in parallel — one per group — and return categorized findings with severity levels. The output format matches the existing `review` skill pattern (findings under separate headings, not merged).

This is the **form axis only** (v1). The skill evaluates whether the slide is well-designed visually, not whether it communicates the right message.

## User Stories

1. As a slide author, I want to pass a screenshot to `/review-slide` and get design feedback, so that I can improve my slide without needing a designer
2. As a slide author, I want findings categorized by domain (grouping, readability, colors, spacing), so that I can focus on one area at a time
3. As a slide author, I want each finding to have a severity level, so that I can prioritize what to fix first
4. As a slide author, I want the review to work on any slide screenshot (Google Slides export, Keynote screenshot, PDF page, rendered frame), so that I'm not locked to one tool
5. As a slide author, I want the 4 groups evaluated in parallel, so that the review completes faster
6. As a slide author, I want each group's findings reported separately (not merged), so that I can see which design domain has issues
7. As a slide author using an agent workflow, I want the review output to be actionable by another agent, so that the agent can apply fixes without human interpretation
8. As a slide author, I want the design principles documented in reference files I can read and edit, so that I can adjust the rules over time
9. As a slide author, I want the skill to work without any prior spec or configuration, so that I can use it immediately on any slide

## Implementation Decisions

### Skill structure

The skill follows the existing pattern: `SKILL.md` orchestrator + `references/` sub-agent briefs.

```
tools/ai/claude/config/skills/review-slide/
  SKILL.md
  references/
    grouping.md
    readability.md
    colors.md
    spacing.md
```

### Orchestrator (SKILL.md)

- Accepts one argument: path to a screenshot image
- If no argument provided, asks the user for the image path
- Spawns 4 sub-agents in a single message with 4 `Agent` tool calls, using `general-purpose` subagent type
- Each agent prompt tells it to: read the screenshot, read its reference file, evaluate, return findings
- Aggregates the 4 reports under separate headings (`## Grouping`, `## Readability`, `## Colors`, `## Spacing`) without merging or reranking
- Ends with a one-line summary (total findings per group + worst severity)

### Sub-agent briefs (references/*.md)

Each brief is self-contained (~30-50 lines) and includes:
- The 3 principles to evaluate, with clear definitions and examples
- The output format: categorized findings with severity (blocking / improvement / nitpick)
- Word limit per report (~300 words)
- Instruction to read the screenshot via the Read tool

### The 4 groups and their 12 principles

**grouping.md** — Structure and groupement
- Proximity: related elements close together, unrelated elements far apart
- Similarity: elements with the same role have the same visual treatment
- Grid alignment: element edges align on consistent vertical/horizontal lines

**readability.md** — Hierarchy and reading flow
- Focal point: one element visually dominates as the entry point
- Reading flow: clear entry point (top/top-center), clear exit point (CTA), natural path between them
- Typographic hierarchy: max 4 size levels, ratio >= 1.25x between levels, max 2 font families

**colors.md** — Visual legibility
- Contrast: text readable on any background (solid, image, gradient); overlays/shadows where needed
- Figure-ground: content clearly separates from background, one layer wins
- Color palette: max 5 chosen colors with clear dominance hierarchy; consistent saturation; external assets (logos) exempt

**spacing.md** — Breathing and density
- Safe margins: no content in outer 5-10% of slide
- Whitespace: inter-group spacing >= 2x intra-group spacing; ~40-50% total whitespace on content slides
- Visual balance: weight distributed across the slide; preference for asymmetric balance

### Output format

Same pattern as the existing `review` skill. Per finding:
- Which principle is violated
- What specifically is wrong (cite the area of the slide)
- Severity: **blocking** (fundamentally hurts readability), **improvement** (noticeable but not critical), **nitpick** (minor polish)

## Testing Decisions

No automated tests. This is a pure prompt skill (no code to test). Quality is validated by running the skill on real slides and checking that findings are relevant and actionable.

Prior art: the existing `review` skill has no automated tests either — it's validated by usage.

## Out of Scope

- **Message/content axis (fond):** evaluating whether the slide communicates the right information — deferred to v2
- **Slide spec generation:** grill-me-style session to define what the slide should say — deferred
- **Deterministic lint script (slide-lint):** automated checks like WCAG contrast measurement — deferred
- **Font size measurement:** cannot be reliably measured from a flattened image — excluded
- **Animation/transition review:** only static frames are reviewed
- **Multi-slide deck review:** the skill reviews one slide at a time
- **Screenshot generation:** the skill does not generate screenshots from any tool; it receives a pre-existing image

## Further Notes

- The skill is designed to be consumed by agents as well as humans
- The 4 reference files are meant to evolve over time as the user discovers which feedback is useful vs. noise
- Future v2 will add a message axis (fond) that requires a spec file and covers signal-to-noise ratio, information retention, and spec compliance
