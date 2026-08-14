## Guidance

- Testing ZSH: `bats <filepath>`
- Linting ZSH: `zsh-lint <filepath>`
- Test files live in `__tests__` directories
- All paths below are relative to repo root (`~/.oroshi/`)

### Key locations

- Providers: `tools/term/zsh/config/functions/autoload/audio/__lib/`
- Tests: `tools/term/zsh/config/functions/autoload/audio/__tests__/`
- Audio helpers: `tools/term/zsh/config/functions/autoload/audio/`
- API keys: `private/config/term/zsh/local/vorugal/`
- Argos icons: `tools/ubuntu/24.04/argos/config/icons/`

### Conventions

- Provider contract: 1 positional arg (WAV path), stdout = plain text transcription
- `ZSH_EVAL_CONTEXT` guard at the boundary between functions and main script for testability
- `set -e` / `setopt err_return` for error handling
- File-based state in `/dev/shm/oroshi/mic2txt/` (model, language, PID, etc.)
- Argos panel auto-discovers icon via `mic2txt-model-${modelName}.svg` pattern

### Prior art

- `wav2txt-openai` — reference provider implementation
- `audio-split` — current split-in-two logic to extend
- `wav2txt-openai.bats` — test pattern (currently minimal, but shows sourcing approach)

## Discoveries

(append-only, updated by agents after each issue)

### Issue 01 — audio-split --max-size
- `rg` outputs ANSI color codes even in pipelines when global config has colors enabled; always use `--color=never` in pipelines parsed by `bc`
- `bats run` merges stdout+stderr into `$output`; use `run --separate-stderr` or check for specific content, not emptiness
- `local var=$(cmd)` masks exit status in ZSH even with `err_return` — bc failures go unnoticed
