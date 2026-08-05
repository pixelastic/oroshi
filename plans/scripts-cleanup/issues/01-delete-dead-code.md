## TLDR

Delete all 70+ dead scripts, `__pdf/` directory, dead aliases, and remark config.

## What to build

Bulk `git rm` of all scripts confirmed dead during the audit. The full list is in the audit decisions file at `/tmp/oroshi/claude/scripts/scripts-audit-decisions.md` under "Confirmed DELETE".

Deletions:
- 22 Ruby scripts (smartcase, slurp, mts2mp4, camera-extract, subtitle-*, html2txt, milkyway-mount-path, painting-inspiration, s3-push-public, serenity-backup-perso, trash-list, update-dir, sass2scss, scss2css)
- 20 Bash scripts (cmus-*, writer, agf, bats-echo, js-check-tests, json_reformat, npm-is-local, npm-which, nvm-version-current, python-version-debug, pip-install-version, calc, clean-boot, hexographer, mkdiralpha)
- 4 sh/node scripts (git-find-unclean-repos, remark-fix, remark-lint, meetup-attendee-list)
- 28 ZSH scripts (simplify, html2mkd, SELECT, argsf, argsp, convert-comics, copy-verbose, get-version-system, heroicmaps-extract, jvc-extract, jx, kbR, kba, kbz, michel-compress-video, move-verbose, path.*, peek, picture-sync, reload-tests, scrap, sync-comics, trash-exists, weather)
- `__pdf/` directory (17 scripts)

Also clean up:
- Dead aliases referencing deleted scripts (e.g. `trl` for trash-list)
- Remark config files (alongside remark-fix/remark-lint)
- Any `scripts/etc/` directories that only served deleted scripts (subtitle-download, subtitle-import-synchro, slurp, update-dir, trash-helper)

## Acceptance criteria

- [ ] All scripts listed in "Confirmed DELETE" are removed
- [ ] `__pdf/` directory is removed
- [ ] Dead aliases are removed from `tools/term/zsh/config/aliases/`
- [ ] Remark config is removed
- [ ] Orphaned `scripts/etc/` subdirectories are removed
- [ ] No broken references remain (grep for deleted script names finds nothing)
- [ ] Existing tests still pass
