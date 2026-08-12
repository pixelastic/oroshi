## Migrate markdown/ and vim/lua/ to _languages/

### markdown/

| Script | New name | Destination |
|--------|----------|------------|
| `md2gdocs` | `md2gdoc` | `_languages/markdown/` |
| `md2html` (root) | `md2html` | `_languages/markdown/` |

`md2gdoc` has `__lib/md2gdocs.js` + `__config/reference.docx` — move alongside.

### vim/lua/

| Script | Destination |
|--------|------------|
| `lua-lint-custom` | `_languages/lua/` (next to existing `lua-lint-selene`) |

Move `__rules/rule-no-vim-deepcopy.zsh` alongside.

### Update callers for md2gdoc

- `review-blog-start`
- `review-blog/SKILL.md`
- `allowlist.json`
