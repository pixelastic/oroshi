## TLDR

Delete the old env generation script and its generated files — `env-generate-projects`, `env/projects.zsh`, `env/projects.json`.

## What to build

Once issues 05, 07, and 08 are done, nothing in the codebase reads from `env/projects.zsh`, `env/projects.json`, or calls `env-generate-projects`. Delete all three.

Verify no remaining references to any of these files exist in the repo.

## Acceptance criteria

- [ ] Issues 05, 07, and 08 are complete
- [ ] `env-generate-projects` script is deleted
- [ ] `env/projects.zsh` is deleted
- [ ] `env/projects.json` is deleted
- [ ] No file in the repo references any of the deleted paths
