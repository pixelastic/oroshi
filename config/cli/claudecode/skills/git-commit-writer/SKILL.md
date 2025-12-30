---
name: git-commit-writer
description: Use when the user needs help writing commit messages, wants to
commit staged changes, has multiple unrelated changes they want to split into
logical commits, or asks to create/generate git commits.
---

# Git Commit Writer

## Overview

This skill analyzes your staged git changes and generates high-quality but
concise commit messages following the Conventional Commits format. It
automatically detects when staged files represent multiple logical concerns and
suggests separate commits for each, ensuring each commit is focused and
coherent.

## Workflow

### 1. Extract Staged Changes

Use git commands to understand what's staged:

```bash
git diff --cached --name-status  # List staged files with status
git diff --cached                # Show full diff of staged changes
```

### 2. Analyze Changes for Logical Grouping

Review the changes to identify logical concerns:

- **Same concern**: Files that work together toward a single goal (e.g., all files for a new feature)
- **Different concerns**: Unrelated changes that should be separate commits (e.g., bug fix + documentation + refactoring)

Consider:
- Do changes share the same purpose?
- Do they affect the same functional area?
- Would they make sense in the same changelog entry?
- Could one change be reverted without affecting the others?

If multiple concerns detected, group files accordingly.

### 3. Generate Commit Messages

For each logical group, create a Conventional Commit message:

**Format**: `type(scope): description`

Consult `references/conventionalCommits.md` for:
- Valid types (feat, fix, refactor, docs, etc.)
- Scope conventions
- Description guidelines
- Body structure

**Body requirements**:
- Focus on the core change and essential WHY
- Be concise: no more than 1-3 sentences by default.
- Only add detail if it's critical to understanding the change
- Avoid exhaustive lists of file changes (git shows that)
- Wrap at 72 characters per line

### 4. Present Suggestions

For each suggested commit:

1. **List the files** to be included
2. **Show the commit message** with body
3. **Explain the reasoning** for the grouping

If user has single concern:
- Present one commit message

If user has multiple concerns:
- Present multiple commits, numbered
- Group files logically for each
- Explain why they should be separate

### 5. Execute or Refine

User can then:
- Accept suggestions and create commits
- Request modifications to messages
- Adjust file groupings
- Commit selectively (some groups now, others later)

## Key Principles

- **Atomic commits**: Each commit should represent one logical change
- **Descriptive bodies**: Rich context helps future developers (and LLMs) understand changes
- **Conventional format**: Consistent structure enables automated tooling and changelog generation
- **User control**: Always present suggestions, never auto-commit without user confirmation

## Example Interaction

**User**: "I have 10 files staged touching authentication, documentation, and config. Help me commit."

**Claude**:
1. Runs `git diff --cached` to see staged changes
2. Analyzes the 10 files
3. Detects 3 concerns: auth feature (5 files), docs update (3 files), config fix (2 files)
4. Generates 3 commit messages:

```
Commit 1 (5 files: src/auth/*, tests/auth/*):
feat(auth): add password reset functionality

Users can request a reset link via email that expires after 1 hour.
Includes rate limiting (max 3 requests/hour) to prevent abuse.

---

Commit 2 (3 files: docs/*):
docs(auth): update authentication documentation

Add password reset instructions and API endpoint examples.

---

Commit 3 (2 files: config/*):
fix(config): correct email service timeout values

Increase SMTP timeout from 5s to 30s to fix intermittent
delivery failures on slower networks.
```

Would you like to create these commits, or adjust any messages?
