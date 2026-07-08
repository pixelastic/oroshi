## TLDR

Rename `zshfix` → `zsh-fix` and refactor it to follow the established fix script pattern: stdout by default, `--in-place` flag, stdin support. Wire NeoVim to call `zsh-fix` instead of shfmt directly.

## What to build

### `scripts/bin/zsh/zsh-fix` (renamed from `zshfix`)

Refactor to match the pattern of `python-fix`, `json-fix`, `css-fix`:

```
$ zsh-fix ./file.zsh                  # Format and output to stdout
$ zsh-fix --in-place ./file.zsh       # Format in place
$ echo 'code' | zsh-fix               # Stdin → stdout
```

Implementation strategy (mirrors `python-fix`):
1. Parse `--in-place` flag
2. Detect stdin vs file argument
3. Copy input to a temp file (`$OROSHI_TMP_FOLDER/zsh-fix/zsh-fix-$RANDOM.zsh`)
4. Try `shfmt -ci -w tmpFile` — if it fails (ZSH-specific syntax), fallback to `beautysh --indent-size 2 tmpFile`
5. If `--in-place`: copy temp file back to original. Else: `cat tmpFile`
6. Clean up temp file

No `--filepath` flag needed (shfmt/beautysh have no per-project config to resolve).

Document the shfmt → beautysh fallback strategy in the header comment.

### `scripts/bin/zsh/zsh-lint/zsh-lint`

Update line calling `zshfix` → `zsh-fix --in-place`.
Update the comment in the header.

### `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats`

Update mock name from `zshfix` → `zsh-fix` in the three `--fix` test cases.

### `tools/vim/nvim/config/lua/oroshi/filetypes/zsh.lua`

Replace `shfmt_zsh` formatter with `oroshi_zsh_fix` that calls `zsh-fix`:

```lua
M.configureFormatter = function(conform)
  conform.formatters.oroshi_zsh_fix = {
    command = "zsh-fix",
    stdin = true,
    exit_codes = { 0, 1 },
  }
end
```

## Behavioral Tests

Write bats tests for `zsh-fix` in `scripts/bin/zsh/zsh-fix/__tests__/zsh-fix.bats`:

**When a file is passed:**
- Formatted content is output to stdout
- Original file is not modified

**When `--in-place` is passed:**
- File is modified in place
- Nothing output to stdout

**When input comes from stdin:**
- Formatted content is output to stdout

**When shfmt fails on ZSH-specific syntax:**
- `beautysh` is called as fallback

**When shfmt succeeds:**
- `beautysh` is not called

## Acceptance criteria

- [ ] `zsh-fix ./file.zsh` outputs formatted content to stdout, does not modify file
- [ ] `zsh-fix --in-place ./file.zsh` modifies file, no stdout
- [ ] `echo code | zsh-fix` reads from stdin, outputs to stdout
- [ ] shfmt failure triggers beautysh fallback
- [ ] shfmt success skips beautysh
- [ ] `zsh-lint --fix` calls `zsh-fix --in-place` (mock updated in tests)
- [ ] NeoVim `zsh.lua` uses `zsh-fix` via conform `stdin = true`
- [ ] Bats tests written for `zsh-fix` covering the above
