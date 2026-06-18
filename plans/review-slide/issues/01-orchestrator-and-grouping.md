## TLDR

Create the `review-slide` skill with SKILL.md orchestrator and the first reference file (grouping.md).

## What to build

A new skill at `tools/ai/claude/config/skills/review-slide/` that accepts a screenshot path and evaluates it against design principles.

**SKILL.md orchestrator:**
- Frontmatter: `name: review-slide`, description triggers on "review slide", "slide review", "review this slide"
- Accepts one argument: path to a screenshot image
- If no argument provided, asks the user for the image path
- For this slice: spawns 1 sub-agent using `general-purpose` subagent type
- The agent prompt tells it to: read the screenshot via the Read tool, read `references/grouping.md`, evaluate, return findings
- Presents the report under a `## Grouping` heading
- Ends with a one-line summary (total findings + worst severity)
- The orchestrator should be written with the 4-group structure in mind (Grouping, Readability, Colors, Spacing) so that adding the 3 remaining groups in issue 02 only requires adding reference files and agent calls, not restructuring

**references/grouping.md sub-agent brief:**
- Self-contained instructions (~30-50 lines)
- 3 principles to evaluate:
  - **Proximity:** related elements close together, unrelated elements far apart. Spacing between elements must reflect semantic relationships.
  - **Similarity:** elements with the same role have the same visual treatment (size, color, shape, font). Inconsistency without semantic reason is noise.
  - **Grid alignment:** element edges align on consistent vertical/horizontal lines. Small accidental offsets (15px) look like errors; large intentional offsets (200px) look like design choices.
- Output format: categorized findings with severity (blocking / improvement / nitpick)
- Per finding: which principle is violated, what specifically is wrong (cite the area of the slide), severity level
- Word limit: ~300 words
- Instruction to read the screenshot via the Read tool

Follow the existing `review` skill as prior art for structure and tone.

## Acceptance criteria

- [ ] `tools/ai/claude/config/skills/review-slide/SKILL.md` exists with correct frontmatter
- [ ] `tools/ai/claude/config/skills/review-slide/references/grouping.md` exists
- [ ] Running `/review-slide <image-path>` spawns a sub-agent that reads the image and returns grouping findings
- [ ] Findings use the severity format: blocking / improvement / nitpick
- [ ] Output is under a `## Grouping` heading
- [ ] Summary line at the end
