## TLDR

Replace all existing `echo ... >&2` with `echoerr` across the codebase.

## What to build

Run the linter across all ZSH files to find every `echo ... >&2` violation. For each occurrence, apply the mechanical replacement:

- `echo "msg" >&2` becomes `echoerr "msg"`
- `echo >&2 "msg"` becomes `echoerr "msg"` (remove redirect from middle, swap echo for echoerr)
- `echo "msg" 1>&2` becomes `echoerr "msg"`

There are ~42 occurrences across `scripts/bin/` and `tools/term/zsh/config/functions/autoload/`. Each replacement must preserve the original arguments and flags exactly.

After all replacements, run `zsh-lint` on every modified file to confirm zero violations.

## Acceptance criteria

- [ ] All `echo ... >&2` replaced with `echoerr ...` in ZSH files
- [ ] `echo >&2 "msg"` variant handled (redirect removed from middle)
- [ ] No behavioral change — same messages, same destination (stderr)
- [ ] `zsh-lint` passes on all modified files
- [ ] The only remaining `>&2` after echo in the codebase is inside `echoerr` itself (with disable comment)
