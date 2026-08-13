## Add pipe-rewrite rule to zsh-fix

### Problem

beautysh strips indentation when pipes are at end of line (`cmd | \n cmd2`), but preserves Google Shell Style (`cmd \` + `| cmd2`). Currently zsh-fix is a plain beautysh wrapper with no post-processing.

### Goal

Add a post-processing step to `zsh-fix` that rewrites trailing-pipe style to Google Shell Style **before** passing to beautysh, so all zsh code is automatically normalized.

### Transform

```zsh
# Before (trailing pipe — broken by beautysh)
cat foo |
  grep bar |
  sort

# After (Google Shell Style — preserved by beautysh)
cat foo \
  | grep bar \
  | sort
```

### Scope

- Only rewrite `|` at end of line (not `||`, `&&`, or pipes inside strings/comments)
- Preserve indentation of the continuation line
- Add tests covering: simple pipes, multi-line chains, pipes inside if/while bodies, heredocs (don't rewrite), strings (don't rewrite)

### Behavioral Tests

```
@test "rewrites trailing pipe to Google Shell Style"
@test "preserves pipes inside single-quoted strings"
@test "preserves pipes inside double-quoted strings"
@test "preserves pipes inside heredocs"
@test "handles multi-level pipe chains"
@test "does not rewrite || (logical or)"
```
