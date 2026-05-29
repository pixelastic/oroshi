## TLDR

Delete the `project-key` autoload function — its only purpose was converting project names to the old `PROJECT_<KEY>_*` env var format.

## What to build

Once issues 02, 03, and 04 are done, no code in the repo calls `project-key` anymore. Delete the function file. Verify no remaining references exist.

## Acceptance criteria

- [ ] Issues 02, 03, and 04 are complete
- [ ] The `project-key` autoload function file is deleted
- [ ] No file in the repo references `project-key`
