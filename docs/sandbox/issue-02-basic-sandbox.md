## What to build

The `claude-sandbox` executable at `scripts/bin/claude/claude-sandbox/claude-sandbox`.

This issue covers the minimal working sandbox: pass a prompt, get a response,
nothing outside the workspace is writable. The workspace defaults to `$PWD`.

The script must:
- Accept a prompt as its first positional argument
- Mount the workspace read-write at `/home/agent/workspace`
- Run `claude --print --dangerously-skip-permissions -p "$prompt"` inside the container
- Stream all output back to the caller's stdout unchanged
- Destroy the container on exit (`--rm`)

The prompt is passed via `-p` (Claude's stdin shorthand) to avoid the Linux
128KB argument size limit.

`--print` and `--dangerously-skip-permissions` are always injected — they are
not optional.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] `claude-sandbox "what files are in this directory?"` returns Claude's response
- [ ] Claude's output is streamed to stdout
- [ ] The container is gone after the command exits (`docker ps -a` shows nothing)
- [ ] Claude cannot write outside `/home/agent/workspace` (no other host paths are mounted)
- [ ] Bats test passes

## Blocked by

- issue-01-dockerfile
