## TLDR

New `project-remove` helper that removes a project entry from projects.jsonc preserving comments.

## What to build

A new helper `project-remove` in `tools/term/zsh/config/functions/autoload/project/` that removes a project entry from `tools/term/zsh/config/theming/src/projects.jsonc`.

Takes a project name, calls `jsonc-remove-key` on the projects.jsonc file. If the project doesn't exist in the file, exits silently (idempotent — inherited from `jsonc-remove-key`).

## Behavioral Tests

**Happy path:**
- removes the named project entry from a JSONC fixture
- preserves comments in surrounding entries
- file is valid JSONC after removal

**Idempotency:**
- exits successfully when project doesn't exist in the file

Mock `jsonc-remove-key` or use a real fixture file (since `jsonc-remove-key` is tested in issue 01, mocking is fine here — test the wiring, not the JSONC parsing again).

## Acceptance criteria

- [ ] `project-remove <name>` removes the entry from projects.jsonc
- [ ] Comments preserved (delegated to `jsonc-remove-key`)
- [ ] No-op when project not in file
- [ ] Tests pass
