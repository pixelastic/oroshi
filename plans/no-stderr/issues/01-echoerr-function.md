## TLDR

Create `echoerr` autoloaded function that wraps `echo "$@" >&2`.

## What to build

An autoloaded ZSH function at `tools/term/zsh/config/functions/autoload/misc/echoerr` that forwards all arguments to `echo` with stderr redirection.

The function has a minimal header (usage comment only, no `setopt err_return` — nothing can fail in an echo). The body is a single line: `echo "$@" >&2`, preceded by a `# zsh-lint disable=useEchoerr` comment to exempt it from the lint rule added in issue 02.

The function must be fully transparent — any flag or argument that `echo` accepts must work identically through `echoerr`.

## Behavioral Tests

Test file: `tools/term/zsh/config/functions/autoload/misc/__tests__/echoerr.bats`

**stderr output:**
- "writes message to stderr"
- "writes nothing to stdout"

**argument passthrough:**
- "passes -n flag to suppress newline"
- "handles multiple arguments"

## Acceptance criteria

- [ ] `echoerr "msg"` writes "msg" to stderr
- [ ] `echoerr "msg"` writes nothing to stdout
- [ ] `echoerr -n "msg"` suppresses newline (flag passthrough)
- [ ] `echoerr` is autoloaded (zero cost until first call)
- [ ] `# zsh-lint disable=useEchoerr` on the `echo` line
- [ ] `zsh-lint --fix` passes on the file
