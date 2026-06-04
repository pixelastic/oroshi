## Problem Statement

When using the `mic2txt` speech-to-text pipeline with the OpenAI Whisper backend, the transcription occasionally appends hallucinated phrases at the end of the output — most commonly sentences like "Merci d'avoir regardé cette vidéo !" which originate from Amara.org subtitle data in Whisper's training corpus. These artifacts corrupt the transcription and are inserted verbatim wherever the user is currently focused.

## Solution

Add an artifact-stripping step inside the OpenAI Whisper transcription script. A dedicated `removeArtifacts` function holds a static list of known hallucinated phrases and removes each one from the transcription before it is output. The list is easy to extend as new artifacts are discovered.

## User Stories

1. As a user of `mic2txt`, I want known Whisper hallucination phrases to be removed automatically, so that the transcription pasted into my focused window is clean.
2. As a user of `mic2txt`, I want clean text to pass through the artifact stripping unchanged, so that legitimate transcriptions are never corrupted.
3. As a developer, I want the list of artifact phrases to be defined in one obvious place, so that I can add new entries as I encounter them without touching any logic.
4. As a developer, I want the artifact-stripping function to be testable in isolation, so that I can verify its behavior without performing a real audio transcription.

## Implementation Decisions

- **`removeArtifacts` function** lives inside the OpenAI Whisper transcription script, defined before the main execution block. It accepts the transcription text as a single argument and echoes the cleaned text to stdout.
- **Artifact list** is a script-level constant array (`ARTIFACTS`) declared at the top of the file, containing exact phrases to strip. It starts with one entry and is extended over time.
- **Matching strategy** is exact string match (no regex). Each phrase in `ARTIFACTS` is escaped and removed verbatim via `sed`. This avoids fragile pattern maintenance.
- **Execution guard**: the main execution block of the transcription script is wrapped in a `ZSH_EVAL_CONTEXT == "toplevel"` guard so the file can be sourced by tests without triggering a real API call.
- **Updated main flow**: the transcription result is captured into a local variable, then `removeArtifacts` is called directly on it (not in a subshell), and its stdout becomes the script's output.

## Testing Decisions

Good tests verify observable output (the echoed text) given a controlled input — they do not test internal implementation details such as which `sed` expression is used.

**Modules tested:**
- `removeArtifacts` function, in isolation.

**Test scope:**
- One test with a transcription that ends with the first artifact phrase → the phrase is removed.
- One test with clean text → output is unchanged.
- The test assumes that if the function correctly strips the first `ARTIFACTS` entry, the array-based logic generalises to all future entries without needing additional test cases per entry.

**Prior art:** `bats_run_script` + mock of the `source` builtin (to bypass credential file loading) is the established pattern for testing scripts that source private config at load time. See existing bats tests under `scripts/bin/` for reference.

## Out of Scope

- Stripping artifacts from backends other than OpenAI Whisper (`wav2txt-parakeet` or future backends).
- Regex-based or fuzzy matching of artifact variants.
- Any UI or notification when an artifact is stripped.
- Automatic discovery of new artifact phrases.

## Further Notes

The `ARTIFACTS` array is the intended extension point. When a new hallucination phrase is observed in practice, it is added as a new entry — no logic changes required.
