## TLDR

Validate that `kitty @ set-tab-color` triggers an immediate Tab Bar Redraw.

## What to build

Manually verify the Redraw hack: call `kitty @ set-tab-color --match "id:<tabId>" active_bg=NONE`
from a shell and confirm that the Tab Bar visually re-renders on the next frame.

If the hack works as expected, proceed with the architecture. If not, revise the
Glossary (`tools/term/kitty/config/GLOSSARY.md`) and the PRD to reflect what
is actually achievable, then determine an alternative mechanism.

This is a HITL issue — it requires a human to observe the Tab Bar in a live
Kitty instance and confirm the visual effect.

Steps:
1. Open two or more Kitty tabs
2. Find a Tab ID via `kitty-tab-id`
3. Run `kitty @ set-tab-color --match "id:<tabId>" active_bg=NONE` from another tab
4. Observe whether the Tab Bar redraws immediately (within one frame)
5. Confirm there is no unintended visual side effect (color change, flicker, etc.)

## Acceptance criteria

- [ ] Command triggers a visible Tab Bar re-render without perceptible delay
- [ ] No unintended visual side effect on any tab
- [ ] Finding recorded in Discoveries section of GUIDANCE.md
- [ ] If hack does not work: Glossary and PRD updated with corrected architecture
