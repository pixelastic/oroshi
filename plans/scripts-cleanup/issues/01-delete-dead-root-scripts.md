## Delete dead root-level scripts

Delete 13 scripts confirmed unused/obsolete during interactive audit.

### Scripts to delete

- `scripts/bin/foo` — test script (`echo $1`)
- `scripts/bin/utf8` — empty script (shebang + `set -e` only)
- `scripts/bin/jsclean` — uses deprecated `fixmyjs`/`js-beautify`
- `scripts/bin/say` — TTS via `trans` (no longer installed)
- `scripts/bin/dire` — calls `say --fr`, dead with `say`
- `scripts/bin/kbl` — one-liner `gsettings` debug
- `scripts/bin/randomstring` — 1 history hit, `openssl rand` alternative
- `scripts/bin/throttle` — buggy, no dependencies
- `scripts/bin/better-posting` — Posting no longer used
- `scripts/bin/markdown/mk2html` — Perl Markdown original, replaced by `md2html`
- `scripts/bin/compress` — Ruby dependency (`etc/compress/`) deleted, script is dead
- `scripts/bin/record` — Ruby + X11 (byzanz-record/xprop/wmctrl), broken on Wayland
- `scripts/bin/help` — 0 real history hits (all false positives from `--help`)

### Also clean up

- Remove `better-posting` alias from zsh aliases
- Remove any compdef entries for deleted scripts

### Verification

- `zsh-lint` passes
- No broken references (`grep` for deleted script names across repo)
