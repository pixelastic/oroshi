---
name: todo
description: Use when the user wants to add, list, pick, or manage items in their todo backlog.
---

# Todo

## Overview

Manage a todo.txt backlog via ZSH helpers. Add items, browse by domain/size, and pick items for sidequests.

---

## Core Workflow

### Step 1 — Read current state

**Goal:** Know what's already in the backlog.

**Exit criterion:** `todo-list` output reviewed.

Run `todo-list` to see existing items, domains, and dependencies.
This informs domain inference and avoids duplicate slugs.

---

### Step 2 — Map request to helpers

**Goal:** Determine which helpers to call based on the user's request.

**Exit criterion:** One or more helpers identified.

Available helpers:

| Helper | What it does | Usage |
|---|---|---|
| `todo-add` | Add an item | `todo-add --domain <Domain> --size <size> --slug <slug> [--blocked-by <slug>] "<description>"` |
| `todo-list` | List/filter items | `todo-list [--domain <Domain>] [--size <size>]` |
| `todo-remove` | Delete an item by slug | `todo-remove <slug>` |
| `todo-move` | Move item to another domain | `todo-move <slug> <NewDomain>` |
| `todo-find` | Get item number by slug | `todo-find <slug>` |

Match the user's request to the right helper(s). Use Step 1 output to understand context.

---

### Step 3 — Execute

**Goal:** Carry out the user's request using the helpers identified in Step 2.

**Exit criterion:** Action completed and confirmed to user.

Call the helper(s) from Step 2. Two behaviors require special handling:

#### Adding — one-shot inference

Never ask the user for confirmation. Infer everything from the description and Step 1 output:

- **Domain:** pick an existing domain. If none fits, use `Misc`.
- **Size:** estimate from description — see [format.md](references/format.md) for definitions.
- **Slug:** kebab-case, max 2 words. Avoid duplicates from Step 1.
- **Dependencies (optional):** add `--blocked-by` if the item logically depends on another.

#### Picking for a sidequest

Three consumption patterns:

1. **Spring Cleaning** — batch all unblocked small items into one sidequest.
2. **Domain deep-dive** — all items in a single domain.
3. **Specific problem** — find the matching item by description or slug.

Remove picked items with `todo-remove`, then hand off to the `/sidequest` skill.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I should ask the user which domain/size to use" | Infer it. One-shot. Never ask for confirmation when adding. |
| "I'll call topydo directly, it's simpler" | Use the ZSH helpers. They handle tag formatting and slug resolution. |
| "I'll skip reading the backlog first" | You need it to pick domains and avoid duplicate slugs. |

---

## Checklist

- [ ] `todo-list` run to read current state
- [ ] Request mapped to one or more helpers
- [ ] **If adding:** domain, size, slug inferred — no confirmation asked
- [ ] **If picking:** items removed via `todo-remove`, handed off to `/sidequest`
- [ ] Action confirmed to user
