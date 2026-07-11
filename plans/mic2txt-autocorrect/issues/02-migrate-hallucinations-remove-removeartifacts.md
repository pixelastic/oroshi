## TLDR

Move Whisper hallucination suppressions into autocorrect.txt and delete removeArtifacts from wav2txt-openai.

## What to build

Append all Whisper hallucination phrases currently hardcoded in `wav2txt-openai`'s `removeArtifacts` function to `__data/autocorrect.txt` as suppression entries (`wrong=`), under a `# Whisper hallucinations` comment section.

Remove the `removeArtifacts` function definition and its call site from `wav2txt-openai`. The script's final output becomes the raw transcription directly (already handled upstream by `mic2txt-raw`'s inline correction block from issue 01).

These two changes are atomic: merging them prevents a window where hallucinations are suppressed twice (once by `removeArtifacts`, once by the inline block) or not at all.

## Scaffolding Tests

Pure deletion — no scaffolding tests.

## Acceptance criteria

- [ ] All phrases previously in `removeArtifacts` appear in `autocorrect.txt` as `phrase=` entries
- [ ] `removeArtifacts` function is fully removed from `wav2txt-openai`
- [ ] The call to `removeArtifacts` at the end of `wav2txt-openai` is removed
- [ ] `wav2txt-openai` still produces correct output (raw transcription, no hallucinations)
- [ ] No phrase is suppressed twice
