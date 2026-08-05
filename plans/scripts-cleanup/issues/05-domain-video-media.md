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
2. Check if called from non-ZSH context
3. Migrate to autoloaded function or justify as script
4. Apply renames from rename map (issue 02)
5. Ensure doc comment present
6. Update aliases and references

## Acceptance criteria

- [ ] All Ruby/Bash scripts rewritten to ZSH
- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] Renames applied per rename map
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
