## TLDR

Clean up video and media conversion domain: rewrite Ruby/Bash to ZSH, migrate to autoloaded functions, rename, document.

## What to build

Scripts in scope:
- `video-has-sound` (Ruby → ZSH rewrite)
- `video-index-fix` — repair video file index
- `video-stream-remove` — remove streams from video
- `video-volume-increase` — increase audio volume
- `mp42avi` — convert MP4 to AVI
- `mp42mp3` — extract audio from MP4
- `mp4min` → `mp4-min` (rename)
- `bin2iso` — convert .bin to .iso
- `vcd2mpg` — convert VCD to MPG
- `dds2png` — convert DDS to PNG

For each script:
1. Rewrite from Ruby/Bash to ZSH if needed
2. Migrate to autoloaded function
3. Apply renames from rename map (issue 02)
4. If called from external context, update call site to `bin-zsh <function>`
5. Update aliases and references

## Acceptance criteria

- [ ] All Ruby/Bash scripts rewritten to ZSH
- [ ] All scripts migrated to autoloaded functions
- [ ] Renames applied per rename map
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
