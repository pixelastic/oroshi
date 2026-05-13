## What to build

Check that `$ANTHROPIC_API_KEY` is set before attempting to start the
container. If it is missing, print a clear human-readable error and exit 1
immediately — before any Docker call.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] Running `claude-sandbox "prompt"` with `ANTHROPIC_API_KEY` unset prints an error message that names the missing variable
- [ ] Exit code is 1 when the key is missing
- [ ] No Docker process is started when the key is missing
- [ ] Normal execution is unaffected when the key is set
- [ ] Bats test passes

## Blocked by

- issue-02-basic-sandbox
