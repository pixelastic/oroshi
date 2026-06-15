## TLDR

Add a `filetype-*` section to `icons.zsh` so filetype icons are in the shared icon registry.

## What to build

Add a new named section to `icons.zsh` under a `# Filetypes` comment. One entry per group
(`ICONS[filetype-text]`, `ICONS[filetype-script]`, `ICONS[filetype-config]`,
`ICONS[filetype-image]`, `ICONS[filetype-audio]`, `ICONS[filetype-video]`,
`ICONS[filetype-archive]`, `ICONS[filetype-document]`, `ICONS[filetype-ebook]`,
`ICONS[filetype-binary]`, `ICONS[filetype-minor]`), plus one entry per per-extension override
(`ICONS[filetype-js]`, `ICONS[filetype-vue]`, `ICONS[filetype-go]`, `ICONS[filetype-vim]`,
`ICONS[filetype-md]`, `ICONS[filetype-mkd]`).

Move the Unicode glyphs currently embedded in `src/filetypes-list.zsh` into these entries.

## Acceptance criteria

- [ ] `icons.zsh` has a `# Filetypes` section with one entry per group
- [ ] All per-extension icon overrides from `filetypes-list.zsh` have a corresponding `ICONS[filetype-*]` entry
- [ ] No new icon keys are invented — only glyphs extracted from the existing ZSH source
