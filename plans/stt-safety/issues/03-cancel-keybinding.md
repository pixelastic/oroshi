## TLDR

Add GNOME keybinding `<Shift><Ctrl>XF86Launch5` to call `mic2txt-cancel`.

## What to build

Add a new entry to `tools/ubuntu/24.04/keybindings/custom` in the shortcuts array:

- Name: `mic2text-cancel`
- Binding: `<Shift><Ctrl>XF86Launch5` (Shift+Ctrl+RightShift)
- Command: path to `mic2txt-cancel`

Place it next to the existing `mic2text` entry for discoverability.

## Acceptance criteria

- [ ] New keybinding entry added to the custom keybindings config
- [ ] Binding is `<Shift><Ctrl>XF86Launch5`
- [ ] Command points to `mic2txt-cancel`
