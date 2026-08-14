## Problem Statement

The mic2txt speech-to-text system currently uses OpenAI Whisper (good quality, but slow request-response latency). Groq offers an OpenAI-compatible transcription API running Whisper Large v3 at 228x real-time speed, making it functionally near-instant for short recordings. It's also 9x cheaper and has a generous free tier (2000 req/day). Adding Groq as a third provider would drastically reduce transcription latency while maintaining Whisper-level French quality.

Additionally, the existing `audio-split` utility only splits files in two, which fails for files larger than 2x the API size limit (25MB).

## Solution

Add Groq as a third mic2txt provider and improve `audio-split` to handle arbitrarily large files.

1. A new `wav2txt-groq` provider that sends WAV files to Groq's API and returns transcription text
2. An improved `audio-split` that accepts a `--max-size` flag to produce N chunks (not just 2)
3. Model toggle updated from binary (openai/parakeet) to a 3-way cycle (openai/parakeet/groq)
4. Argos panel updated with a Groq icon

## User Stories

1. As a mic2txt user, I want to select Groq as my transcription model, so that I get near-instant transcription
2. As a mic2txt user, I want to toggle between openai, parakeet, and groq via the existing keybinding/Argos panel, so that I can switch models without editing config
3. As a mic2txt user, I want Groq transcription to produce the same output format as OpenAI (plain text to stdout), so that the post-processing pipeline (autocorrect, translate, slack, paste) works unchanged
4. As a mic2txt user, I want large recordings (>25MB) to be automatically split and transcribed in parts when using Groq, so that API limits don't block transcription
5. As a mic2txt user, I want `audio-split --max-size 25M` to produce N chunks from arbitrarily large files, so that no chunk exceeds the API limit regardless of recording length
6. As a mic2txt user, I want `audio-split` without flags to keep working as before (split in two at the middle), so that existing behavior is preserved
7. As a mic2txt user, I want audio splits to happen at silence boundaries, so that words are never cut mid-sentence
8. As a mic2txt user, I want the Argos panel to show a Groq icon when Groq is the active model, so that I can see at a glance which provider is active

## Implementation Decisions

- `wav2txt-groq` lives in `__lib/` alongside `wav2txt-openai` — same contract (1 arg = WAV path, stdout = text)
- Groq API key stored in `private/config/term/zsh/local/vorugal/groq.zsh` as `GROQ_API_KEY` (placeholder for now)
- Groq API endpoint: `https://api.groq.com/openai/v1/audio/transcriptions` with model `whisper-large-v3`
- Language hardcoded to "fr" (input language is always French; language toggle controls output translation)
- File size limit logic duplicated in `wav2txt-groq` (same as openai) — no shared abstraction yet
- `audio-split` enhanced: `--max-size <size>` flag produces N chunks; no flag = legacy behavior (split in 2)
- `audio-split --max-size` calculates number of chunks from file size, divides duration evenly, snaps each cut point to the nearest silence
- Output files: `<basename>-part1.<ext>`, `<basename>-part2.<ext>`, etc. Listed on stdout (one per line)
- `mic2txt-model-toggle` cycles: openai -> parakeet -> groq -> openai
- `mic2txt-model` default remains "openai"
- Groq SVG icon added to Argos icons directory
- No `groq-api` abstraction — YAGNI for now, extract later if needed
- `wav2txt-groq` uses the same `ZSH_EVAL_CONTEXT` guard for testability

## Testing Decisions

- Tests use bats, following the existing pattern in `__tests__/`
- `audio-split` tests: test `--max-size` with mock WAV files of known sizes. Verify correct number of chunks, no overlap, files listed on stdout. Test legacy mode (no flag) still splits in 2.
- `wav2txt-groq` tests: test `isFileTooBig` threshold logic. API call tested via stubbed curl (same pattern as wav2txt-openai tests if expanded).
- `mic2txt-model-toggle` tests: verify 3-way cycle (openai->parakeet->groq->openai)
- Prior art: `__tests__/wav2txt-openai.bats`, `__tests__/mic2txt-raw.bats`

## Out of Scope

- Groq as a general-purpose API helper (`groq-api` abstraction) — deferred until a second use case emerges
- Factoring shared split logic between openai and groq providers
- Dynamic language selection in providers (hardcoded "fr")
- Streaming/realtime STT (Groq is batch, just very fast)
- Replacing OpenAI or Parakeet as default model

## Further Notes

- Groq free tier: 2000 req/day, 28800 audio seconds/day. User averages ~214 mic2txt launches/day (peak 364), well within limits.
- Groq pricing if free tier exceeded: $0.04/hr (whisper-large-v3-turbo) or $0.111/hr (whisper-large-v3) — still 9x cheaper than OpenAI.
- The `audio-split` improvement benefits both openai and groq providers, though only groq will use it initially via the duplicated logic.
