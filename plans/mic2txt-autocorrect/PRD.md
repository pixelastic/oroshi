## Problem Statement

Speech-to-text backends (OpenAI Whisper and local Parakeet) regularly mishear proper nouns and domain-specific terms. For example, "Oroshi" is frequently transcribed as "Orochi". There is no post-processing correction step — transcription errors reach the user verbatim. Additionally, Whisper hallucinations (phantom phrases appended to transcriptions) are handled inside `wav2txt-openai` in isolation, making corrections fragmented and backend-specific.

## Solution

Introduce a unified autocorrect data file and an inline correction step in `mic2txt-raw` that applies after transcription, regardless of backend. Both user-defined word corrections and Whisper hallucination suppression are consolidated into a single config file. The correction logic lives inline in the transcription pipeline, keeping the architecture flat.

## User Stories

1. As a mic2txt user, I want known STT mishearings corrected automatically, so that I do not have to manually fix them after each transcription.
2. As a mic2txt user, I want corrections to apply regardless of whether I am using the OpenAI or Parakeet backend, so that switching backends does not reintroduce errors.
3. As a mic2txt user, I want to maintain a personal corrections table without editing script internals, so that I can add new corrections as I discover them.
4. As a mic2txt user, I want to add comments to the corrections file, so that I can document why a correction exists.
5. As a mic2txt user, I want corrections to be case-insensitive, so that "Orochi", "orochi", and "OROCHI" are all caught.
6. As a mic2txt user, I want corrections to be whole-word only, so that substrings inside unrelated words are not accidentally modified.
7. As a mic2txt user, I want to suppress Whisper hallucination phrases using the same mechanism as word corrections, so that there is a single place to manage all post-processing rules.
8. As a mic2txt user, I want suppression entries (wrong phrase with empty replacement) to be expressed naturally in the corrections file, so that the format is consistent for both corrections and deletions.

## Implementation Decisions

- A single data file (`__data/autocorrect.txt`) stores all post-processing rules — both word corrections and hallucination suppressions.
- Format: one rule per line, `wrong=right`. Suppression entries use an empty right-hand side (`wrong=`). Lines starting with `#` are comments and are ignored. Blank lines are ignored.
- The file ships pre-seeded with the Orochi→Oroshi corrections and all Whisper hallucination phrases currently hardcoded in `wav2txt-openai`.
- The correction logic is inlined directly in `mic2txt-raw`, after the transcription is captured and before any downstream processing (translation, slack-mode rewrite). ZSH-idiomatic iteration is used — no `while IFS` loop.
- Matching is case-insensitive and whole-word (word boundary anchors).
- The replacement text is always the literal value from the config file; input casing is not preserved.
- `wav2txt-openai`'s `removeArtifacts` function and its call site are removed entirely. Its artifact list migrates to `autocorrect.txt`.
- No new script is introduced; the correction step is not independently testable as a module.

## Testing Decisions

No tests are written for this change. The correction logic is inline and the data file is plain text — both are verified by manual use.

## Out of Scope

- Fuzzy or phonetic matching (only exact whole-word string replacement).
- Preserving the original casing of the matched word in the replacement.
- A UI or command to manage the corrections file.
- Testing the correction logic as an isolated module.
- Corrections that apply only to a specific backend.
