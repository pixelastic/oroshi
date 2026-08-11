## Delete dead root-level scripts

Delete 10 scripts confirmed unused/obsolete during interactive audit.

### Scripts to delete

- `scripts/bin/foo` — test script (`echo $1`), 10 history hits
- `scripts/bin/utf8` — empty script (shebang + `set -e` only)
- `scripts/bin/jsclean` — uses deprecated `fixmyjs`/`js-beautify`, 1 history hit
- `scripts/bin/say` — TTS via `trans` (no longer installed), 0 history hits
- `scripts/bin/dire` — calls `say --fr`, dead with `say`
- `scripts/bin/kbl` — one-liner `gsettings` debug, 1 history hit
- `scripts/bin/randomstring` — 1 history hit, `openssl rand` alternative
- `scripts/bin/throttle` — buggy (mismatched parens), 5 history hits, 0 deps
- `scripts/bin/better-posting` — Posting no longer used, 2 history hits
- `scripts/bin/markdown/mk2html` — Perl Markdown original, replaced by `md2html`

### Also clean up

- Remove `better-posting` alias from `zsh/config/aliases/misc.zsh` (or equivalent)
- Remove any compdef entries for deleted scripts
- Check `rename-map.md` references if still present

### Verification

- `zsh-lint` passes
- No broken references (`grep` for deleted script names across repo)
