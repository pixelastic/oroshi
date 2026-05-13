## What to build

A `Dockerfile` in `scripts/bin/claude/claude-sandbox/` that produces an image
containing Claude Code, common dev tools, and a Linux user whose UID/GID match
the host user at build time.

The image is the foundation every other issue depends on. It must be buildable
with four build-args: `NODE_VERSION`, `CLAUDE_VERSION`, `AGENT_UID`,
`AGENT_GID`. Both `NODE_VERSION` and `CLAUDE_VERSION` have hardcoded defaults
in the `ARG` declarations — they are the source of truth for which versions are
active. To upgrade either, edit those defaults and rebuild.

The base image's `node` user is renamed to `agent` and its UID/GID are
replaced with the values passed at build time, so that files created inside the
container belong to the host user on the host filesystem.

Claude Code is installed via `npm install -g @anthropic-ai/claude-code@VERSION`
(not via the official install script, which does not support version pinning).

System packages to include: `git`, `curl`, `jq`, `gh`.

Default working directory: `/home/agent/workspace`.

Network access is the Docker default (bridge, outbound internet allowed) — no
special configuration needed.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins
- [ ] `docker build` succeeds with default build-args
- [ ] `docker build --build-arg NODE_VERSION=18 --build-arg CLAUDE_VERSION=x.y.z ...` succeeds
- [ ] `claude --version` runs inside the built container
- [ ] A file created inside the container at `/home/agent/workspace/` is owned by the host user on the host (UID/GID alignment verified)
- [ ] `git`, `curl`, `jq`, `gh` are available inside the container
- [ ] Bats test passes

## Blocked by

None — can start immediately.
