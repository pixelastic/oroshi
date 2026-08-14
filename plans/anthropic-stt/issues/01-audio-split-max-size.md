## TLDR

Enhance `audio-split` to accept `--max-size` and produce N chunks instead of always splitting in two.

## What to build

Add a `--max-size <size>` flag to `audio-split`. When provided, the function calculates how many chunks are needed (`ceil(fileSize / maxSize)`), divides the audio duration into N equal segments, and snaps each cut point to the nearest silence detected by ffmpeg. Output files follow the existing naming pattern (`<basename>-part1.<ext>`, `-part2`, etc.) and are listed on stdout, one per line.

When called without `--max-size`, behavior is unchanged (split in two at the first silence after the midpoint).

The `<size>` argument accepts human-readable sizes: `25M`, `10M`, etc.

Key file: `tools/term/zsh/config/functions/autoload/audio/audio-split`
Test file: `tools/term/zsh/config/functions/autoload/audio/__tests__/audio-split.bats`

## Behavioral Tests

**Legacy mode (no flag):**
- splits a file into exactly 2 parts
- creates part1 and part2 files with correct naming
- does not produce output on stdout (preserves current behavior)

**Max-size mode:**
- splits a 50MB file with --max-size 25M into at least 2 parts
- splits a 75MB file with --max-size 25M into at least 3 parts
- each output chunk is smaller than the specified max size
- lists created files on stdout, one per line
- cuts happen at silence boundaries (not mid-audio)
- a file smaller than max-size produces a single part (just copies)

**Edge cases:**
- missing input file returns error
- --max-size with invalid size format returns error

## Acceptance criteria

- [ ] `audio-split input.wav` still splits in two at silence near midpoint (rétrocompat)
- [ ] `audio-split --max-size 25M input.wav` produces N chunks, each <= 25MB
- [ ] Cut points snap to detected silences
- [ ] Output files listed on stdout (one per line) in max-size mode
- [ ] All bats tests pass
