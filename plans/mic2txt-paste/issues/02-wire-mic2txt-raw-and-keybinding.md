## TLDR

Wire `mic2txt-raw` to write transcription file and call `mic2txt-paste`, add Ctrl+Alt+V keybinding.

## What to build

**`mic2txt-raw` changes:**
- After all transformations (autocorrect, translate, slack-format), write `$transcription` to `/dev/shm/oroshi/mic2txt/transcription.txt`
- Replace the `focus-insert "$transcription"` call with `mic2txt-paste`
- Keep autosubmit logic (Enter key) in `mic2txt-raw` after the `mic2txt-paste` call

**Keybinding:**
- Add `<Ctrl><Alt>V` → `mic2txt-paste` entry in `tools/ubuntu/24.04/keybindings/custom`

## Acceptance criteria

- [ ] `mic2txt-raw` writes transcription to `/dev/shm/oroshi/mic2txt/transcription.txt`
- [ ] `mic2txt-raw` calls `mic2txt-paste` instead of `focus-insert`
- [ ] Autosubmit Enter key stays in `mic2txt-raw`, runs after `mic2txt-paste`
- [ ] `<Ctrl><Alt>V` keybinding added to GNOME custom keybindings config
