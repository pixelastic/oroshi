## TLDR

Define a named-param interface for the review skill and wire ralph to use it, so the Spec agent reviews against the active issue instead of the full PRD.

## What to build

Update three skill instruction files end-to-end:

**`specs-agent.md` Step 2** — Remove all inference logic (state.json, PRD.md lookup). Use the `issue:` path passed by the caller directly. If no path provided, report "no spec available" and stop.

**`review SKILL.md` Step 1** — Replace the current natural-language arg table with a formal named-param contract:
- `issue:<path>` — the spec file to review against (passed to Spec agent)
- `ref:<git-ref>` — the diff base (passed to both sub-agents as `review-diff` args)
- `ref:dirty` is the explicit name for the WIP/dirty case (maps to no args for `review-diff`)
- `ref:worktree` continues to work as before
- Keep a table of example `ref:` values (branch, commit, range, worktree, dirty)
- If `issue:` or `ref:` is absent and cannot be inferred from context, ask the user — do not silently infer

**`ralph SKILL.md` Step 4** — Change the review skill call from "no args" to `issue:<absolute_path_from_ralph_start> ref:dirty`. The issue path is already in ralph's context from the `ralph-start` JSON output.

## Acceptance criteria

- [ ] `specs-agent.md` Step 2 uses the provided `issue:` path directly; has no state.json or PRD.md lookup
- [ ] `review SKILL.md` Step 1 defines `issue:` and `ref:` as named params with a clear contract
- [ ] `review SKILL.md` Step 1 includes `ref:dirty` as an explicit named value for the WIP case
- [ ] `review SKILL.md` Step 1 specifies: ask if args are absent
- [ ] `ralph SKILL.md` Step 4 calls review with `issue:<path> ref:dirty` using the path from `ralph-start` output
