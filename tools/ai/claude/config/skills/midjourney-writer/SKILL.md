---
name: midjourney-writer
description: Use when user wants a Midjourney prompt from an image description, in any language, often speech-to-text. Returns one English Midjourney V8.2 prompt, copied to the clipboard.
---

# Midjourney Writer

## Overview

Turn an image description, in any language, into one English Midjourney V8.2 prompt, copied to the clipboard.

## Core Workflow

### Step 1 — Write the prompt

**Goal:** Produce exactly one English prompt that matches the description.

**Exit criterion:** One prompt written, following both references.

Read the description. It is often messy speech-to-text: infer the intended words.
Do not ask clarifying questions. Do not run any network call or check.

Follow `references/prompting.md` for the text and `references/parameters.md` for the parameters.

### Step 2 — Copy and display

**Goal:** Put the prompt in the clipboard and show it.

**Exit criterion:** `clipboard-write` called, prompt displayed.

Copy the prompt with a quoted heredoc (prompts contain double quotes):

```zsh
clipboard-write <<'EOF'
<prompt>
EOF
```

Display the prompt in a code block. Output nothing else: no explanation, no choices made, no alternatives.

### Step 3 — Iterate

**Goal:** Apply each follow-up request.

**Exit criterion:** User stops asking for changes.

For each follow-up ("darker", "add a dragon"), revise the prompt and repeat Step 2.
Always return the full revised prompt, never a diff.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The description is ambiguous, I'll ask a question" | Never ask. Pick the most likely reading and write the prompt. The user iterates if needed. |
| "I'll explain my choices so the user understands" | The answer is the prompt only. |
| "I'll offer two variants" | Exactly one prompt per answer. |
| "The description is not in English, so the prompt keeps its language" | The prompt is always English. See `references/prompting.md`. |
| "The change is small, I'll only show the modified part" | Always the full prompt, copied again. |

## Checklist

- [ ] Exactly one English prompt, ending with parameters
- [ ] `clipboard-write` called with the final prompt
- [ ] Answer contains only the prompt
