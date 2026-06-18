## TLDR

Add the 3 remaining reference files and update the orchestrator to spawn 4 parallel sub-agents.

## What to build

Three new reference files following the same pattern established by `grouping.md` in issue 01.

**references/readability.md — Hierarchy and reading flow:**
- **Focal point:** one element visually dominates as the entry point. Without a focal point, the eye wanders with no starting position.
- **Reading flow:** clear entry point (top/top-center), clear exit point (CTA/bottom), natural path between them. The exact left/right placement is flexible as long as the hierarchy of importance is respected.
- **Typographic hierarchy:** max 4 distinct size levels, ratio >= 1.25x between adjacent levels, max 2 font families. Title weight must be >= body weight.

**references/colors.md — Visual legibility:**
- **Contrast:** text must be readable on any background (solid, image, gradient). When text sits over a non-uniform background, a mechanism must ensure legibility everywhere (overlay, text-shadow, solid band behind text).
- **Figure-ground:** content clearly separates from background. One layer must win — if text and background compete for attention, neither is readable.
- **Color palette:** max 5 chosen colors with clear dominance hierarchy. Consistent saturation across chosen colors. External assets (logos) are exempt but should not be adopted as accents without checking integration.

**references/spacing.md — Breathing and density:**
- **Safe margins:** no content in the outer 5-10% of the slide edges.
- **Whitespace:** inter-group spacing >= 2x intra-group spacing. Content slides should have ~40-50% total whitespace.
- **Visual balance:** visual weight distributed across the slide, not lopsided. Preference for asymmetric balance (more dynamic, more interesting) over symmetric.

**SKILL.md update:**
- Update to spawn 4 sub-agents in a single message with 4 `Agent` tool calls
- Each agent reads the screenshot + its own reference file
- Aggregate 4 reports under separate headings: `## Grouping`, `## Readability`, `## Colors`, `## Spacing`
- Do not merge or rerank findings across groups
- Summary line: total findings per group + worst severity across all groups

Each reference file: ~30-50 lines, self-contained, same output format as grouping.md (findings with severity, ~300 words max).

## Acceptance criteria

- [ ] `references/readability.md` exists and covers focal point, reading flow, typographic hierarchy
- [ ] `references/colors.md` exists and covers contrast, figure-ground, color palette
- [ ] `references/spacing.md` exists and covers safe margins, whitespace, visual balance
- [ ] SKILL.md spawns 4 sub-agents in parallel (single message with 4 Agent tool calls)
- [ ] Output has 4 separate headings (Grouping, Readability, Colors, Spacing)
- [ ] Reports are not merged or reranked
- [ ] Summary line at the end with per-group counts and worst severity
