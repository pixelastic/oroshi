## TLDR

Create `sys-cpu`, `sys-ram`, `sys-swap` autoload functions in `system/`.

## What to build

Three autoload functions that read compute/memory metrics and return structured data.

**sys-cpu** — reads `/proc/stat`, calculates overall CPU usage percentage, returns single integer (e.g. `27`).

**sys-ram** — reads from `free`, returns `%▮current▮max` with human-readable sizes (e.g. `34▮8.2G▮30G`).

**sys-swap** — reads from `free`, returns `%▮current▮max` (e.g. `2▮128M▮2G`).

All three support dual mode:
- Default: echo result to stdout
- `--reply`: set `REPLY` silently, no echo

Flag parsing via `zparseopts -E -D -reply=flagReply`. Pattern matches `remove-ansi`.

Each uses `setopt local_options err_return` (autoload convention).

## Acceptance criteria

- [ ] `sys-cpu` returns integer CPU usage %
- [ ] `sys-ram` returns `%▮current▮max` with human sizes
- [ ] `sys-swap` returns `%▮current▮max` with human sizes
- [ ] All three support `--reply` flag (sets REPLY, no echo)
- [ ] All three echo by default (no flag)
- [ ] `▮` (U+25AE) used as field separator
