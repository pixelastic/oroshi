---
name: code-writer
description: Use when writing or modifying code in any programming language. Apply when adding functions, fixing bugs, or implementing features.
---

# Code Writer

## Disclaimer

If a specific skill for a language exists, use that one instead:
- **JavaScript**: Use `js-writer` skill for JavaScript/Node.js code
- **ZSH**: Use `zsh-writer` skill for ZSH functions in .oroshi repository
- **Python**: Use `python-writer` skill for Python code

## Overview

Write code in any language in a consistent way, that matches my conventions and
standards.

**Core principle:** Minimize noise, maximize signal.

## When to Use

- Writing new functions or methods
- Modifying existing code
- Adding features or fixing bugs
- Refactoring code

## Style

- Keep comments concise (see `### Comments`)
- Limit output statement (see `### Output statements`)
- Avoid deep nesting, return early and often (see `./references/style.md`)
- Use descriptive names, avoid abbreviations (see `./references/style.md`)

### Comments

Comments explain **why**, not **what** (we rely on properly named functions and
variables for that).

Comments are appreciated when they:
- Document a function goal and parameters
- Give an overview of a complex piece of code
- Explain why a return early happens
- Delimit code in logical sections
- Give example of input data
- Explain complex use-cases or edge-cases
- Document hacks or known limitations

Comments are useless if:
- They duplicate what the code already says through variable and function names

**IMPORTANT:** If the user added a comment, don't remove it. User choice
supersedes those rules.

### Output statements

I don't need the code to output what it does, unless specifically asked to.

Output is allowed for:
- Display functions, whose purpose IS to output data
- Error messages, to help diagnose an error

Output is not allowed for:
- Progress messages (`"Processing..."`, `"Starting..."`, `"Done"`)
- Status summaries (`"Found X items"`, `"Total: Y"`)
- Empty lines (`console.log("")`)
- Debug traces (`"checkpoint 1"`, `"here"`)
