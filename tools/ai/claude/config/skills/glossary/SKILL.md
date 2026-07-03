---
name: glossary
description: Use when the user wants to nail down domain terms, resolve terminology ambiguities, or build a shared language for a module or repo. Drills vocabulary one question at a time and writes to the project GLOSSARY.md.
---

# Glossary

## Overview

Drills domain vocabulary one question at a time, then writes to the project GLOSSARY.md.

## Core Workflow

### Step 1 — Locate the target file

**Goal:** Identify which GLOSSARY.md to write to.

**Exit criterion:** Target file path is known.

Infer from context:

- Conversation about a specific module → `<module>/GLOSSARY.md` (preferred) or `<module>/__docs/GLOSSARY.md` (if the module dir is in PATH and docs live there)
- Repo-wide → root `GLOSSARY.md`
- Unclear → ask once: *"Which module is this glossary for? Or is it repo-wide?"*

If the file already exists at either location, read it before drilling — don't duplicate or contradict existing terms.

---

### Step 2 — Drill

**Goal:** Resolve every term one at a time.

**Exit criterion:** All terms are settled and the user confirms the glossary is ready to write.

#### How to ask

Interview me relentlessly about every term of this plan until we reach a shared understanding.
Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.
For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

Wait for an answer before moving to the next question.

Once all terms are resolved, present a summary and ask: *"Ready to write the glossary?"*

#### What to ask

**Challenge against the glossary:**
When I uses a term that conflicts with the existing language in `GLOSSARY.md`, call it out immediately.
Example: "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

**Sharpen fuzzy language:**
When I uses vague or overloaded terms, propose a precise canonical term.
Example: "You're saying 'account' — do you mean the Customer or the User? Those are different things."

**Discuss concrete scenarios**:
When domain relationships are being discussed, stress-test them with specific scenarios.
Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

**Cross-reference with code:**
When I state how something works, check whether the code agrees.
If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right"

---

### Step 3 — Write

**Goal:** Write the complete glossary to the target file.

**Exit criterion:** File written and confirmed.

Update the glossary — all terms, relationships, flagged ambiguities, and example dialogue.

Use the format in [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md).

---

### Step 4 — Update root index

**Goal:** Keep the root `GLOSSARY.md` as an accurate index of all sub-module glossaries.

**Exit criterion:** Root file lists this sub-module glossary with a current one-line description.

**Skip if:** Skip this step if the target file IS the root `GLOSSARY.md`.

Update the root `GLOSSARY.md` to reference the updated sub-glossary.

Use the format in [GLOSSARY-INDEX-FORMAT.md](./GLOSSARY-INDEX-FORMAT.md).

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write each term as it's resolved" | Relationships need all terms. Write once, at the end. |
| "Target is obvious from context" | One question beats writing to the wrong file. |
| "I know this term from prior context" | Prior context isn't canonical. Drill it. |

## Checklist

- [ ] Target file identified; existing file read if present
- [ ] All terms drilled; relationships mapped; no contradictions between terms
- [ ] User confirmed glossary is ready to write
- [ ] Full glossary written in one pass using GLOSSARY-FORMAT.md
- [ ] Root index updated with GLOSSARY-INDEX-FORMAT.md (if sub-module glossary)
