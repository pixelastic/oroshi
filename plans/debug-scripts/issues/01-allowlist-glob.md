## TLDR

Add a glob entry to the hook allowlist so scripts in the dedicated folder are auto-approved.

## What to build

Add `/tmp/oroshi/claude/scripts/**` as the first entry in `allowlist.json` (the hook allowlist file in `tools/ai/claude/config/hooks/`).

This glob pattern matches any script executed directly from the dedicated throw-away scripts folder, including scripts called with arguments. It leverages the glob support recently added to solkan.

## Behavioral Tests

Skipped — `allowlist.json` is a config file and is the artifact itself.

## Scaffolding Tests

Skipped — no structural transformation.

## Acceptance criteria

- [ ] `/tmp/oroshi/claude/scripts/**` is present in `allowlist.json`
- [ ] `solkan --allow-list-file allowlist.json "/tmp/oroshi/claude/scripts/my-script"` exits 0
- [ ] `solkan --allow-list-file allowlist.json "/tmp/oroshi/claude/scripts/my-script --arg"` exits 0
- [ ] `solkan --allow-list-file allowlist.json "/tmp/oroshi/claude/scripts/foo | grep bar"` exits 0 (with `grep` also in allowlist)
- [ ] A script outside the folder (e.g. `/tmp/other/my-script`) is still rejected
