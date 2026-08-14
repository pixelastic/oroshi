## TLDR

New `wav2txt-groq` provider that transcribes WAV files via Groq's API with automatic file splitting for large recordings.

## What to build

Create `wav2txt-groq` in `__lib/` following the same contract as `wav2txt-openai`: takes a WAV file path as argument, outputs plain transcription text to stdout.

Implementation:
- Source API key from `private/config/term/zsh/local/vorugal/groq.zsh` (export `GROQ_API_KEY`, placeholder value)
- curl POST to `https://api.groq.com/openai/v1/audio/transcriptions` with model `whisper-large-v3`, language `fr`, response_format `text`
- `isFileTooBig` check at 25MB threshold
- If too big, use `audio-split --max-size 25M` to chunk, transcribe each chunk, concatenate results
- `ZSH_EVAL_CONTEXT` guard for testability (same pattern as wav2txt-openai)

Key files:
- `tools/term/zsh/config/functions/autoload/audio/__lib/wav2txt-groq` (new)
- `private/config/term/zsh/local/vorugal/groq.zsh` (new, placeholder)
- `tools/term/zsh/config/functions/autoload/audio/__tests__/wav2txt-groq.bats` (new)

## Behavioral Tests

**File size check:**
- `isFileTooBig` returns true for files >= 25MB
- `isFileTooBig` returns false for files < 25MB

**Transcription (stubbed curl):**
- small file triggers a single curl call
- large file triggers split + multiple curl calls + concatenation
- output is plain text on stdout

## Acceptance criteria

- [ ] `wav2txt-groq recording.wav` outputs transcription text to stdout
- [ ] Files >= 25MB are automatically split via `audio-split --max-size 25M`
- [ ] API key sourced from `vorugal/groq.zsh`
- [ ] `groq.zsh` created with placeholder key
- [ ] Language hardcoded to "fr"
- [ ] `ZSH_EVAL_CONTEXT` guard present for test sourcing
- [ ] All bats tests pass
