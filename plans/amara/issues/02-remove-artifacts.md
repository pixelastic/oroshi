## TLDR

Add a `removeArtifacts` function to `wav2txt-openai` that strips known Whisper hallucination phrases before outputting the transcription.

## What to build

- Declare a script-level constant array `ARTIFACTS` containing the known hallucination phrases to strip. Start with one entry: `"Merci d'avoir regardé cette vidéo !"`.
- Implement `removeArtifacts <text>` — loops over `ARTIFACTS`, removes each phrase via exact `sed` match, echoes the cleaned text to stdout.
- Update the main flow: capture the transcription into a local variable, call `removeArtifacts` directly on it (not in a subshell), let its stdout become the script's output.
- Write a bats test that sources the script (using the source-safe guard from issue 01), mocks the `source` builtin to skip credential loading, and verifies `removeArtifacts` behavior in isolation.

## Behavioral Tests

**Artifact removal:**
- Given a transcription ending with a known artifact phrase, `removeArtifacts` returns the text without that phrase.

**Pass-through:**
- Given clean text with no artifact, `removeArtifacts` returns the text unchanged.

## Acceptance criteria

- [ ] `ARTIFACTS` array is declared at the top of the script, easy to extend
- [ ] `removeArtifacts` strips each phrase in `ARTIFACTS` via exact match
- [ ] `removeArtifacts` leaves text that contains no artifact unchanged
- [ ] Main flow uses `removeArtifacts` before writing to stdout
- [ ] Bats test covers both behavioral scenarios above
- [ ] Bats test does not require a real API key or audio file
