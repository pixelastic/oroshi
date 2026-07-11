## Issue 02 — Migrate hallucinations / remove removeArtifacts

### Standards: mic2txt-raw violations (out of scope)

**Problem:** Standards reviewer flagged 3 hard violations in `mic2txt-raw` (return-early pattern, `local scriptDir` instead of `SCRIPT_DIR`, `shellcheck disable` in ZSH file).
**Reason skipped:** All violations are in `mic2txt-raw` which was modified in issue 01, not this issue. Only `autocorrect.conf` and `wav2txt-openai` were touched in issue 02.

### Spec: autocorrect.conf vs autocorrect.txt naming

**Problem:** Spec references `autocorrect.txt` throughout but the file is `autocorrect.conf`.
**Reason skipped:** Issue 01 established the `.conf` extension. The spec has a stale filename reference; the implementation is correct.

### Spec: out-of-scope dirty files flagged as atomic violation

**Problem:** Reviewer flagged `search-and-replace` and plan files as out-of-scope changes bundled with this issue's atomic pairing.
**Reason skipped:** `search-and-replace` is a pre-existing dirty change from another context; plan files (GUIDANCE.md, review-log.md) are expected ralph artifacts, not issue scope.

## Issue 01 — Autocorrect data file and inline correction

### No tests added

**Problem:** Standards reviewer flagged absence of `.bats` tests for the new correction loop.
**Reason skipped:** GUIDANCE.md explicitly states "No tests for this plan (per PRD testing decisions)."

### Spec: acceptance criterion casing ambiguity

**Problem:** Spec acceptance criterion says `'Orochi', 'orochi', 'OROCHI' all become 'oroshi'` (lowercase), but TLDR says `Orochi→Oroshi` (capital O). Contradiction in the spec.
**Reason skipped:** Implemented with capital `Oroshi` to match the TLDR and the actual project name. The lowercase in the acceptance criterion is a likely typo.

### Spec: comment stripping only handles space-prefixed `#`

**Problem:** Reviewer noted `right="${right/ #*/}"` only strips inline comments when preceded by a space; `value#comment` (no space) would not be stripped.
**Reason skipped:** The documented format explicitly shows `wrong=right    # correction` with a space before `#`. Format without space is not a valid config line per spec.
