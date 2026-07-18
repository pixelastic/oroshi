## Guidance

- Testing: `bats <filepath>` for zsh tests
- Linting: `zsh-lint <filepath>` for zsh scripts, `bats-lint <filepath>` for bats tests
- Test directory: `scripts/bin/audio/__tests__/`
- Prior art for audio tests: `scripts/bin/audio/__tests__/wav2txt-openai.bats`
- Core script: `scripts/bin/audio/mic2txt-raw` — toggle start/stop via PID file in `/dev/shm/oroshi/mic2txt/`
- Sound config: `tools/audio/sounds/config/` — symlinks to actual sound files
- Keybindings: `tools/ubuntu/24.04/keybindings/custom` — GNOME custom shortcuts array
- Use `$EPOCHREALTIME` (zsh built-in, sub-second precision) for timestamp
- Use `bats_mock` to stub collaborators (`kill-pid`, `audio-play-oroshi`, `rec`, `mic2txt-cancel`)
- Use `zsh-writer` skill for script modifications

## Discoveries
