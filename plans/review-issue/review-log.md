## Issue 01 — review named params

### `spec:` vs `issue:` param name

```
| `spec:<path>` | Path to the spec file (issue, PRD, etc.); passed to the Spec agent |
```

**Problem:** Spec defines the param as `issue:<path>` throughout; implementation uses `spec:` everywhere.
**Reason skipped:** User explicitly agreed during pre-implementation discussion that `spec:` is the correct generic term — it can point to an issue, a PRD, or any reference document. The spec predates this decision.

### PRD fallback in specs-agent.md

```
Otherwise, fall back to looking for a PRD in the current worktree:
- Infer the branch from `git-branch-slug`
- Look for `plans/<branchName>/PRD.md`
```

**Problem:** Acceptance criterion states specs-agent "has no state.json or PRD.md lookup"; implementation adds a PRD fallback.
**Reason skipped:** User explicitly requested this fallback during pre-implementation discussion: when no `spec:` is passed, the agent should fall back to the worktree's PRD. The spec predates this decision.
