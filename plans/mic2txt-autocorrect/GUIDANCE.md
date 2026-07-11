## Guidance

### Plan overview
Add unified STT autocorrection to the mic2txt pipeline. Both word corrections and Whisper hallucination suppression live in a single config file; the correction step is inlined in `mic2txt-raw`.

### Key files
- `scripts/bin/audio/mic2txt-raw` — main orchestration script; correction block goes here
- `scripts/bin/audio/wav2txt-openai` — removeArtifacts to be removed in issue 02
- `scripts/bin/audio/__data/autocorrect.conf` — new config file (created in issue 01)

### Config file format
```
# comment
wrong=right    # correction
phrase=        # suppression (empty right-hand side)
```
- One rule per line
- Case-insensitive, whole-word matching
- Replacement is literal (casing not adapted to input)

### Conventions
- ZSH scripts use `set -e` at the top
- Use `$OROSHI_ROOT` for all oroshi paths, never hardcoded `~/.oroshi`
- No `while IFS` loops — use ZSH-idiomatic iteration
- Lint: `zsh-lint <filepath>` / `bats-lint <filepath>`

### Testing
No tests for this plan (per PRD testing decisions).

### Prior art
- `wav2txt-openai` — `removeArtifacts` function shows the pattern being replaced
- `mic2txt-raw` — inline pipeline transformations (translate, txt2slack) show where the correction block fits

## Discoveries

### Issue 01 — Autocorrect data file and inline correction
- `\b` word boundaries in sed treat `-` as a non-word char, so `\borochi\b` matches inside `pseudo-orochi`. Use perl with negative lookahead/lookbehind `(?<![a-zA-Z0-9-])..(?![a-zA-Z0-9-])` to properly exclude hyphenated compounds.
- `zsh-lint --fix` silently reformats commented-out code blocks (re-indents continuation lines). Check git diff carefully after running it.
- `local wrong` / `local right` must each be on their own line (noGroupedLocals rule); declare before the loop, assign inside it.
- Empty `right` (suppression) works automatically — perl replaces with empty string, deleting the matched word.
