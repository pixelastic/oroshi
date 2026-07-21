## TLDR

New `mic2txt-paste` script that reads last transcription from file and pastes it via `focus-insert`.

## What to build

Create `scripts/bin/audio/mic2txt-paste` — a ZSH script that:

1. Checks if `/dev/shm/oroshi/mic2txt/transcription.txt` exists
2. If missing, exit 0 silently
3. Read file content
4. Call `focus-insert "$content"`

## Behavioral Tests

Tests in `scripts/bin/audio/__tests__/mic2txt-paste.bats`.
Prior art: `scripts/bin/audio/__tests__/mic2txt-cancel.bats`.

**File present with content:**
- calls focus-insert with file content
- exits with status 0

**File missing:**
- exits with status 0
- does not call focus-insert

## Acceptance criteria

- [ ] `mic2txt-paste` exists as executable in `scripts/bin/audio/`
- [ ] Reads from `/dev/shm/oroshi/mic2txt/transcription.txt`
- [ ] Calls `focus-insert` with file content when file exists
- [ ] Exits silently (status 0) when file is missing
- [ ] All bats tests pass
