## Guidance

### Plan overview
Add unified STT autocorrection to the mic2txt pipeline. Both word corrections and Whisper hallucination suppression live in a single config file; the correction step is inlined in `mic2txt-raw`.

### Key files
- `scripts/bin/audio/mic2txt-raw` — main orchestration script; correction block goes here
- `scripts/bin/audio/wav2txt-openai` — removeArtifacts to be removed in issue 02
- `scripts/bin/audio/__data/autocorrect.txt` — new config file (created in issue 01)

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
