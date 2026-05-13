## What to build

Mount `~/.claude` from the host into the container at `/home/agent/.claude`
(read-write), so that Claude inside the sandbox has access to the same config,
MCP servers, skills, and session history as Claude on the host.

Sessions run inside the sandbox appear in the host's Claude history.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] Claude inside the sandbox can read `~/.claude/settings.json`
- [ ] MCP servers configured in `~/.claude` are available inside the sandbox
- [ ] A session run inside the sandbox is visible in `~/.claude/projects/` on the host after the run
- [ ] Bats test passes

## Blocked by

- issue-02-basic-sandbox
