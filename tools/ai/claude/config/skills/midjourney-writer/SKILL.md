---
name: midjourney-writer
description: Use when user wants a Midjourney prompt from an image description, in any language, often speech-to-text. Returns one English Midjourney V8.2 prompt, copied to the clipboard.
---

# Midjourney Writer

## Overview

Turn an image description, in any language, into one English Midjourney V8.2 prompt, copied to the clipboard.
The session model clarifies the description. The `midjourney-prompt` helper writes the prompt.

## Core Workflow

### Step 1 — Clarify the description

**Goal:** Rewrite the messy description as a clear, precise description in English.

**Exit criterion:** One clear description, in English.

Read the description. It is often messy speech-to-text: resolve paraphrases, infer missing or misheard terms.
Translate it to English when it is in another language.
Keep every detail the user gave.

DO NOT add details the user did not give.
DO NOT ask clarifying questions.

### Step 2 — Generate, copy and display

**Goal:** Generate the prompt, put it in the clipboard and show it.

**Exit criterion:** Prompt copied by `midjourney-prompt --clipboard`, displayed in a code block.

Run `midjourney-prompt` with a quoted heredoc (descriptions may contain double quotes):

```zsh
midjourney-prompt --clipboard <<'EOF'
<clear description>
EOF
```

Display the command output (not your description) in a code block.
Output nothing else: no explanation, no choices made, no alternatives.

### Step 3 — Iterate

**Goal:** Apply each follow-up request.

**Exit criterion:** User stops asking for changes.

For each follow-up ("darker", "add a dragon"), revise the clear description yourself: merge the change into the full previous description, resolving it as in Step 1.
Do not edit the generated prompt. Repeat Step 2 with the full revised description, never a diff.
Always return the full new prompt, copied again.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The description is ambiguous, I'll ask a question" | Never ask. Pick the most likely reading and clarify it. The user calls again if needed. |
| "I'll write the Midjourney prompt myself, it is faster" | Always run `midjourney-prompt`. It owns the prompt rules. |
| "I'll explain my choices so the user understands" | The answer is the prompt only. |
| "I'll offer two variants" | Exactly one prompt per answer. |
| "I'll show my description, it is more useful" | Show the command output only. |
| "The follow-up is small, I'll edit the previous prompt by hand" | Revise the description, then run `midjourney-prompt` again. It owns the prompt rules. |

## Checklist

- [ ] Description translated and clarified
- [ ] Description passed to `midjourney-prompt --clipboard`
- [ ] Answer contains only the prompt in a code block
- [ ] Each follow-up: description revised, `midjourney-prompt` run again, full new prompt copied and shown
