## TLDR

Remove `rtk` prefix from all skill and doc references to bats commands, and update the GLOSSARY to reflect the new RTK layer mechanism.

## What to build

In every file that currently instructs to run `rtk bats <filepath>`, change it to `bats <filepath>`. The hook now handles the RTK rewrite transparently.

Also update the GLOSSARY Relationships section: the "Determined via `rtk rewrite <cmd>`" line becomes "Determined via `rtk-can-rewrite <cmd>`".

Files to touch: project root CLAUDE.md, zsh-writer SKILL.md, zsh-writer testing reference, hooks GLOSSARY.

## Acceptance criteria

- [ ] No file in the repo instructs to run `rtk bats` explicitly
- [ ] CLAUDE.md testing command reads `bats <filepath>`
- [ ] zsh-writer SKILL.md step 2 reads `bats <test_filepath>`
- [ ] zsh-writer testing reference updated accordingly
- [ ] GLOSSARY Relationships section references `rtk-can-rewrite` instead of `rtk rewrite`
