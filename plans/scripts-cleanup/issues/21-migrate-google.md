## Migrate google/ to autoloaded

### Scripts (ZSH wrapper + __lib/ JS pattern)

| Script | New name | Notes |
|--------|----------|-------|
| `gdocs2md` | `gdoc2md` | Rename singular |
| `gdocs-comments-json` | `gdoc-comments-json` | Rename singular |
| `google-login` | `google-login` | No rename |

### Adapt __lib/ paths

- `__lib/googleAuth.js` (shared) → move with google/ domain
- Each script's `__lib/*.js` → move alongside

### Update callers

- `tools/ai/claude/config/hooks/allowlist.json`
- `tools/ai/claude/config/skills/review-blog/SKILL.md`
- `tools/term/zsh/config/functions/autoload/ai/review-blog-start`
