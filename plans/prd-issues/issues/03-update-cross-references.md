## TLDR

Update all cross-references to the renamed skills across grill-me, prd, and prd-end.

## What to build

Three text substitutions across three files:

1. `grill-me/SKILL.md` — change `/to-prd` → `/prd` in the "three options" list
2. `prd/SKILL.md` — change `/to-issues` → `/issues` in the Step 4 prompt
3. `scripts/bin/ai/prd/prd-end` — change `# Called by /to-prd` → `# Called by /prd` in the header comment

No logic or structure changes.

## Behavioral Tests

Skip — pure refactor.

## Scaffolding Tests

Skip — pure refactor.

## Acceptance criteria

- [ ] `grill-me/SKILL.md` references `/prd` (not `/to-prd`)
- [ ] `prd/SKILL.md` Step 4 references `/issues` (not `/to-issues`)
- [ ] `prd-end` header comment references `/prd` (not `/to-prd`)
