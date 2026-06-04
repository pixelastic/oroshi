## TLDR

Wrap the main execution block of `wav2txt-openai` so the script can be sourced by tests without triggering a real API call.

## What to build

Add an execution guard around the bottom of `wav2txt-openai` using `ZSH_EVAL_CONTEXT`. When the script is run directly, behavior is unchanged. When sourced (e.g. in a bats test), the transcription logic does not execute — only function/constant definitions are loaded.

## Scaffolding Tests

Sourcing `wav2txt-openai` in a zsh subprocess (via `bats_run_script`) produces no output and exits cleanly, even without a valid audio file or API key.

## Acceptance criteria

- [ ] Sourcing `wav2txt-openai` does not call `transcribeFile`, `splitAndTranscribe`, or any external command
- [ ] Running `wav2txt-openai` directly preserves existing behavior
- [ ] Existing callers (`mic2txt-raw`) are unaffected
