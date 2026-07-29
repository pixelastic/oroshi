---
name: deprecate
description: Use when user says "/deprecate <project-name>" or wants to deprecate and archive a project. Orchestrates GitHub archival, npm deprecation, and projects.jsonc cleanup.
argument-hint: <project-name>
---

# Deprecate

## Overview

Deprecate and archive a project across GitHub, npm, and projects.jsonc in one go.

---

## Core Workflow

### Step 1 — Prepare

**Goal:** Gather project state from all registries.

**Exit criterion:** JSON state parsed, guards passed.

Run `deprecate-prepare $ARGUMENTS` and parse the JSON output.

**Guard — not found:** if `status` is `"not-found"`, tell user the project was not found on GitHub or in projects.jsonc, and stop.

**Guard — npm auth:** if `npmPackage` is not null and `npmIsLoggedIn` is false, tell user to run `npm-login` first, and stop.

---

### Step 2 — Ask reason

**Goal:** Get the deprecation reason from the user.

**Exit criterion:** Reason captured in proper English.

Ask the user why this project is being deprecated. Rewrite their rough or spoken input into a clean, concise English sentence.

---

### Step 3 — Show plan

**Goal:** Let the user see what will happen before any changes.

**Exit criterion:** Plan displayed, user informed.

Display what will happen based on the JSON state. Skip sections that don't apply.

**GitHub** (skip if `github` is null or `isArchived` is true):
- Read existing README from `clonedAt`, prepend deprecation banner
- Disable Renovate if `.github/renovate.json` exists
- Commit and push changes
- Update repo description to `[DEPRECATED] <original>`
- Archive the repository

**npm** (skip if `npmPackage` is null or `npmIsDeprecated` is true):
- Deprecate the package on npm

**projects.jsonc** (skip if `inProjectsJsonc` is false):
- Remove entry and rebuild

---

### Step 4 — Confirm

**Goal:** Get explicit user confirmation before making changes.

**Exit criterion:** User confirmed.

Ask the user to confirm the plan. If they decline, stop.

---

### Step 5 — Write README

**Goal:** Prepend the deprecation banner to the README.

**Exit criterion:** README updated on disk at `clonedAt`.

Skip if GitHub section doesn't apply (no `clonedAt`, or already archived).

Read the existing README at `clonedAt/README.md`. Prepend:

```
> **⚠️ ARCHIVED**: <reason>

---

<original README>
```

---

### Step 6 — Execute

**Goal:** Run all deprecation steps.

**Exit criterion:** `deprecate-end` returned `status: "ok"`.

Run `deprecate-end $ARGUMENTS`. Parse the JSON result.

If `status` is `"error"`, report the `step` and `message` to the user and stop.

---

### Step 7 — Report

**Goal:** Tell the user what was done.

**Exit criterion:** Summary displayed.

Display a summary of what happened:
- GitHub: archived `owner/repo`, description updated
- npm: deprecated `packageName`
- projects.jsonc: entry removed
- Skip lines for sections that didn't apply

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll skip the confirmation step, the user already said deprecate" | Always confirm. Archival and npm deprecation are hard to reverse. |

## Checklist

- [ ] `deprecate-prepare` called and JSON parsed
- [ ] Guard: not-found handled
- [ ] Guard: npm auth handled
- [ ] Deprecation reason obtained and cleaned up
- [ ] Plan displayed with applicable sections only
- [ ] User confirmed before any changes
- [ ] README updated with deprecation banner (if applicable)
- [ ] `deprecate-end` called and result parsed
- [ ] Summary displayed to user
