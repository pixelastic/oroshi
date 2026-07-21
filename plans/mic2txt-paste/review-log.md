## Issue 01 — mic2txt-paste script
### File cleanup after paste
```zsh
content="$(<"$TRANSCRIPTION_FILE")"
focus-insert "$content"
```
**Problem:** Reviewer flagged that transcription.txt is never removed after paste, risking stale re-paste.
**Reason skipped:** Issue spec says nothing about removing the file; issue 02 may depend on file persisting. Cleanup belongs in a separate decision.

## Issue 02 — Wire mic2txt-raw and keybinding
### Test mock duplication
```bash
kill-pid() { :; }
audio-play-oroshi() { :; }
mic2txt-language() { echo "fr"; }
mic2txt-slack-mode-is-enabled() { return 1; }
mic2txt-autosubmit-mode-is-enabled() { return 1; }
mic2txt-paste() { :; }
focus-insert() { :; }
sleep() { :; }
bats_mock kill-pid audio-play-oroshi mic2txt-language mic2txt-slack-mode-is-enabled mic2txt-autosubmit-mode-is-enabled mic2txt-paste focus-insert sleep
```
**Problem:** 4 tests repeat identical 9-line mock setup block
**Reason skipped:** Pre-existing pattern — all mic2txt tests (including mic2txt-cancel.bats) define mocks per-test. Refactoring test helpers is out of scope.
