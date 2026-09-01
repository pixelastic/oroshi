---
name: xml-writer
description: Use when writing or modifying XML files.
---

# XML Writer

## Overview

Write and lint XML files consistent with my conventions.

## Core Workflow

### Step 1 — Modify the file

**Goal:** Make the requested change.

**Exit criterion:** File has the intended content.

### Step 2 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `xml-lint --fix <file>` on any modified `.xml` files
- Fix **every** violation, including pre-existing ones.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The XML looks fine, no need to lint" | `xml-lint --fix` catches formatting and well-formedness issues you won't spot visually. Always lint. |
| "I'll fix the lint errors later" | Lint after every modification. Later never comes. |

## Checklist

- [ ] File is valid XML
- [ ] `xml-lint --fix <file>` run, all violations fixed
