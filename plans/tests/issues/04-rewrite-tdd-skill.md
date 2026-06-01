## TLDR

Rewrite `tdd/SKILL.md` to match the skill-writer format and replace the current testing philosophy with one that allows testing private methods and mocking immediate internal collaborators.

## What to build

Two distinct changes to `tdd/SKILL.md`:

### 1. Form — skill-writer format

Rewrite to follow `references/skill-template.md`. The current file has no Overview, steps lack Goal/Exit criterion, and there is no Common Rationalizations table. Apply the canonical structure:

- **Overview** — 1–2 sentences on what the skill enforces
- **Core Workflow** — each step has a `**Goal:**` and `**Exit criterion:**` line before the instructions
- **Common Rationalizations** table — at least the rationalization rows below
- **Checklist** — verifiable exit criteria with required evidence

### 2. Content — testing philosophy

Replace the current "Good tests / Bad tests" section. The current framing is too restrictive:

> "Bad tests mock internal collaborators, test private methods, or verify through external means."

Replace with a philosophy that reflects two legitimate testing levels and the rule that governs them:

**Legitimate testing levels:**
- **Unit (fine-grained)**: test a private method or helper directly when it contains complex logic. `private` is an API-visibility decision, not a testability decision. If the logic is complex enough to get wrong, it deserves its own test.
- **Integration (coarse-grained)**: test a public function that calls private helpers by mocking those helpers. This isolates the caller's branching logic from the helper's implementation.

**The rule:** mock your **immediate** collaborators, not their descendants.

Example:
```
isGitRepo()    — test directly (unit)
isWorktree()   — test directly (unit)
detectContext() calls both — test detectContext() by mocking isGitRepo and isWorktree
```

Why: if `detectContext()` tests set up a real git repo and worktree, the test is now coupled to the *implementation* of `isGitRepo` and `isWorktree`. A refactor to those helpers breaks `detectContext()` tests even if `detectContext()` behavior is unchanged. That is the actual coupling anti-pattern.

**What remains a bad test:** mocking collaborators *two levels down* (mocking the thing your collaborator calls). That couples to the collaborator's implementation, which defeats the purpose.

**Named approach:** this is the **London School of TDD** (Freeman & Pryce, *Growing Object-Oriented Software, Guided by Tests*). Test each unit in isolation by mocking its immediate collaborators. Apply recursively at every level of the call stack, including private methods.

### Common Rationalizations to add

| Rationalization | Reality |
|---|---|
| "Private methods shouldn't be tested directly" | `private` controls API visibility, not testability. Complex logic deserves a test regardless of exposure. |
| "Mocking internal collaborators couples tests to implementation" | Mocking *immediate* collaborators is isolation, not coupling. Coupling is reaching *inside* your collaborator. |
| "Testing at the public interface is always enough" | The public test must then set up all internal state — coupling it to descendants it doesn't own. |

## Acceptance criteria

- [ ] `tdd/SKILL.md` follows the skill-writer template: Overview, Steps with Goal/Exit criterion, Common Rationalizations table, Checklist
- [ ] "Bad tests" definition no longer lists testing private methods or mocking internal collaborators as anti-patterns
- [ ] Skill explicitly allows direct unit tests for private/helper methods when they contain complex logic
- [ ] Skill explicitly allows mocking immediate internal collaborators in the caller's test
- [ ] Skill names the rule: "mock your immediate collaborators, not their descendants"
- [ ] Common Rationalizations table includes at least the three rows above
- [ ] Checklist is updated to reflect the new philosophy (e.g. "Test strategy: unit / integration / both declared before writing")
