## What to build

Two related behaviours that share the same build mechanism:

1. **Auto-build**: if the required image does not exist locally, build it
   automatically before running the sandbox. The caller sees a build log, then
   Claude's response — no separate setup step required.

2. **`--build` flag**: force a full image rebuild regardless of whether the
   image exists. After the build completes, exit without running Claude. Useful
   after upgrading `CLAUDE_VERSION` or changing the Dockerfile.

The image tag is `claude-sandbox:claude{CLAUDE_VERSION}-nodelts` at this stage
(Node version handling is added in issue-06). `CLAUDE_VERSION` is read from the
`ARG CLAUDE_VERSION=` default in the Dockerfile.

The build passes `AGENT_UID=$(id -u)` and `AGENT_GID=$(id -g)` so the agent
user is aligned to the host user.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] First invocation on a machine with no matching image triggers an automatic build
- [ ] Second invocation reuses the cached image (no rebuild, fast start)
- [ ] `claude-sandbox --build` rebuilds the image and exits 0
- [ ] `claude-sandbox --build` with a `--workspace` resolves the correct `.nvmrc` (prep for issue-06)
- [ ] Bats test passes

## Blocked by

- issue-01-dockerfile
- issue-02-basic-sandbox
