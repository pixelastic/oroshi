## Issue 01 — mic2txt-paste script
### File cleanup after paste
```zsh
content="$(<"$TRANSCRIPTION_FILE")"
focus-insert "$content"
```
**Problem:** Reviewer flagged that transcription.txt is never removed after paste, risking stale re-paste.
**Reason skipped:** Issue spec says nothing about removing the file; issue 02 may depend on file persisting. Cleanup belongs in a separate decision.
