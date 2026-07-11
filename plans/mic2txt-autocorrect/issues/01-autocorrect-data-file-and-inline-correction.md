## TLDR

Create the autocorrect config file and wire inline correction into the transcription pipeline.

## What to build

Create `scripts/bin/audio/__data/autocorrect.txt` with `wrong=right` format. Lines starting with `#` are comments; blank lines are ignored; empty right-hand side (`wrong=`) means suppression.

Seed it with the Orochi→Oroshi corrections (both capitalisation variants).

Add an inline correction block in `mic2txt-raw` immediately after the transcription is captured from the wav2txt binary. The block reads `autocorrect.txt`, skips comments and blank lines, and applies each rule as a case-insensitive, whole-word substitution. ZSH-idiomatic iteration — no `while IFS` loop. The corrected transcription replaces the original before any downstream step (translation, slack-mode rewrite).

## Acceptance criteria

- [ ] `__data/autocorrect.txt` exists and contains Orochi→Oroshi seed entries with a comment header
- [ ] Comment lines (`#`) and blank lines in the config are silently ignored
- [ ] Substitution is case-insensitive: "Orochi", "orochi", "OROCHI" all become "oroshi"
- [ ] Substitution is whole-word only: "pseudo-orochi" is not modified
- [ ] Replacement text is the literal value from the config (casing not adapted)
- [ ] Correction is applied for both the OpenAI and Parakeet backends (handled transparently in `mic2txt-raw`)
- [ ] `wav2txt-openai` is not modified in this issue
