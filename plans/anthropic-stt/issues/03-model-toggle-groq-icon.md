## TLDR

Update model toggle to 3-way cycle (openai/parakeet/groq) and add Groq SVG icon for Argos panel.

## What to build

Two changes:

**1. Model toggle 3-way cycle**

Update `mic2txt-model-toggle` from binary toggle to cycle: openai -> parakeet -> groq -> openai.

Key file: `tools/term/zsh/config/functions/autoload/audio/mic2txt-model-toggle`

**2. Argos icon**

Add `mic2txt-model-groq.svg` to `tools/ubuntu/24.04/argos/config/icons/`. The Argos panel script already uses `mic2txt-model-${modelName}.svg` dynamically, so no panel code changes needed.

Use a simple, minimal SVG for the Groq logo (similar in weight to the parakeet icon).

Key files:
- `tools/term/zsh/config/functions/autoload/audio/mic2txt-model-toggle`
- `tools/ubuntu/24.04/argos/config/icons/mic2txt-model-groq.svg` (new)

## Behavioral Tests

**Toggle cycle:**
- openai toggles to parakeet
- parakeet toggles to groq
- groq toggles to openai
- toggle writes correct value to model file

## Acceptance criteria

- [ ] `mic2txt-model-toggle` cycles openai -> parakeet -> groq -> openai
- [ ] `mic2txt-model-groq.svg` exists and is valid SVG
- [ ] Argos panel displays Groq icon when model is "groq"
- [ ] All bats tests pass
