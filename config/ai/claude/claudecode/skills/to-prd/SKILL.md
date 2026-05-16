---
name: to-prd
description: Turn the current conversation context into a PRD and publish it to the project issue tracker. Use when user wants to create a PRD from the current context.
---

# To PRD

## Overview

This skill takes the current conversation context and codebase understanding and produces a PRD. Do NOT interview the user — just synthesize what you already know.

## Core Workflow

### Step 1 — Understand the codebase

Explore the repo to understand the current state of the codebase, if you haven't already.
Use the project's domain glossary vocabulary throughout the PRD, and respect any ADRs in the area you're touching.

### Step 2 — Sketch out

Sketch out the major modules you will need to build or modify to complete the implementation.
Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations.
Check with the user which modules they want tests written for.

### Step 3 — Write the PRD.md

Write [PRD.md](./references/prd-md.md) following the template.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I know this codebase, no need to explore" | Recent ADRs and domain terms may have changed. Explore first. |
| "The modules are obvious, no need to check with the user" | Module scope and test scope are separate decisions. Confirm both. |

## Checklist

- [ ] Codebase explored — domain glossary and ADRs identified
- [ ] Deep modules identified — each has a simple, testable interface
- [ ] User confirmed module list matches intent
- [ ] User confirmed which modules get tests
- [ ] PRD.md written — all 6 sections present (Problem, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope)
