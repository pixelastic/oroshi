## Migrate audio/mic2txt to autoloaded

### Scripts

| Script | Keybinding update? |
|--------|-------------------|
| `mic2txt` | `$BIN/audio/mic2txt` → `bin-zsh mic2txt` |
| `mic2txt-raw` | No |
| `mic2txt-cancel` | `$BIN/audio/mic2txt-cancel` → `bin-zsh mic2txt-cancel` |
| `mic2txt-paste` | `$BIN/audio/mic2txt-paste` → `bin-zsh mic2txt-paste` |
| `mic2txt-autosubmit-mode-is-enabled` | No |
| `mic2txt-language` | No |
| `mic2txt-model` | No |
| `mic2txt-model-toggle` | `$BIN/audio/mic2txt-model-toggle` → `bin-zsh mic2txt-model-toggle` |
| `mic2txt-slack-mode-is-enabled` | No |
| `mic2txt-slack-mode-toggle` | `$BIN/audio/mic2txt-slack-mode-toggle` → `bin-zsh mic2txt-slack-mode-toggle` |

### wav2txt backends → __lib/ of mic2txt

- `wav2txt-openai` → `__lib/wav2txt-openai` (not in PATH, internal dep)
- `wav2txt-parakeet` (Rust binary) → `__lib/wav2txt-parakeet`
- Rust sources `__src/wav2txt-parakeet/` → `__lib/__src/wav2txt-parakeet/`
- Update `mic2txt-raw` to call wav2txt via path instead of PATH lookup
