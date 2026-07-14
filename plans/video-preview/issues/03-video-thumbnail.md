## TLDR

Create `video-thumbnail` autoload function that generates a 4x4 contact sheet from a video file.

## What to build

New autoload function at `tools/term/zsh/config/functions/autoload/video/video-thumbnail`.

Interface: `video-thumbnail <input-video> <output-png>`

1. Get video duration via `ffprobe`
2. Compute `interval = duration / 17`, floor at 1
3. Generate 4x4 contact sheet via ffmpeg: `fps=1/${interval},scale=240:-1,tile=4x4`
4. Uses `setopt local_options err_return` — failures propagate naturally

Follows same contract as `pdf-thumbnail`: takes input path and output path, creates a PNG.

## Behavioral Tests

**Contact sheet generation:**
- produces a PNG file at the output path given a valid video input
- works for very short videos (under 2 seconds)
- returns non-zero for missing input file

## Acceptance criteria

- [ ] `video-thumbnail` exists as autoload function in `video/` directory
- [ ] Generates a valid PNG contact sheet from a video file
- [ ] Handles short videos without error
- [ ] Tests pass
