# PRD — claude-sandbox

## Problem Statement

Running Claude Code on a codebase carries risk: Claude can read and write
anywhere on the filesystem, install packages globally, and execute arbitrary
commands. When testing skills or running AFK bug-fixing loops, there is no way
to constrain what Claude touches. A broken skill or a bad prompt can cause
collateral damage far outside the intended project.

Additionally, running Claude interactively requires constant permission
approvals, which makes it impossible to use in automated or unattended
workflows.

## Solution

A `claude-sandbox` command that runs Claude Code inside an ephemeral Docker
container. The container has access to exactly one directory (the workspace),
Claude's config, and the network — nothing else. All permissions are granted
upfront so Claude never pauses to ask. The container is destroyed when Claude
finishes.

The caller passes a prompt and optionally a workspace path. All other arguments
are forwarded to Claude transparently. Output flows back to the terminal
unchanged.

## User Stories

1. As a developer, I want to run a Claude skill on a worktree without granting
   filesystem access to my entire home directory, so that a buggy skill cannot
   modify files outside the project.

2. As a developer, I want Claude to run without permission prompts inside the
   sandbox, so that I can use it in unattended scripts.

3. As a developer, I want the sandbox to default to my current directory as the
   workspace, so that I don't have to specify a path every time.

4. As a developer, I want to override the workspace with `--workspace`, so that
   I can target a specific worktree from any working directory.

5. As a developer, I want all Claude CLI arguments to be forwarded
   transparently, so that I can use `--output-format stream-json` or
   `--model` without any sandbox-specific wrappers.

6. As a developer, I want the sandbox image to be built automatically on first
   use, so that I don't have to remember a separate setup step.

7. As a developer, I want `--build` to force a rebuild of the image, so that I
   can upgrade Claude Code or change the Dockerfile without stale images.

8. As a developer, I want the image to be cached between invocations, so that
   launching a sandbox is fast (~1-2s) rather than re-downloading Claude each
   time.

9. As a developer, I want the Node version inside the sandbox to match my
   project's `.nvmrc`, so that test runners behave the same inside and outside
   the sandbox.

10. As a developer, I want a distinct image per Claude+Node version combination,
    so that upgrading Claude doesn't invalidate a working Node 18 image.

11. As a developer, I want files created by Claude inside the sandbox to belong
    to my user on the host, so that I don't need `sudo` to edit them after the
    session.

12. As a developer, I want git to work correctly inside the sandbox when the
    workspace is a worktree, so that Claude can commit, read history, and check
    status.

13. As a developer, I want Claude's config, MCP servers, and skills to be
    available inside the sandbox, so that it behaves like my regular Claude
    setup.

14. As a developer, I want a clear error message when `ANTHROPIC_API_KEY` is not
    set, so that I don't debug a cryptic Docker failure.

15. As a developer, I want the sandbox to have outbound network access, so that
    Claude can reach the Anthropic API and any external tools it needs.

16. As a developer, I want to test a skill by passing its prompt directly as an
    argument, so that I can iterate quickly without writing a wrapper script.

## Implementation Decisions

### Module 1 — `Dockerfile`

Single Dockerfile in `scripts/bin/claude/claude-sandbox/`. Parameterised with
four build-args: `NODE_VERSION`, `CLAUDE_VERSION`, `AGENT_UID`, `AGENT_GID`.

- Base image: `node:{NODE_VERSION}-bookworm`
- System packages: `git`, `curl`, `jq`, `gh`
- Claude Code installed via `npm install -g @anthropic-ai/claude-code@{CLAUDE_VERSION}`
- The base image's `node` user is renamed to `agent` and its UID/GID are
  overwritten to match the host user at build time
- Default working directory: `/home/agent/workspace`

`CLAUDE_VERSION` and `NODE_VERSION` are hardcoded as `ARG` defaults in the
Dockerfile. To upgrade, edit those defaults and run `claude-sandbox --build`.

### Module 2 — `claude-sandbox` ZSH script

Single executable at `scripts/bin/claude/claude-sandbox/claude-sandbox`.

**Arg parsing**
- `--build` flag: force image rebuild, then exit
- `--workspace PATH`: override workspace (default: `$PWD`)
- Everything else: collected verbatim as passthrough args for Claude

**Version resolution**
- `CLAUDE_VERSION`: read from the `ARG CLAUDE_VERSION=` line in the Dockerfile
- `NODE_VERSION`: read from `$workspace/.nvmrc` if present, otherwise `lts`

**Image tag**
- Format: `claude-sandbox:claude{CLAUDE_VERSION}-node{NODE_VERSION}`
- Example: `claude-sandbox:claude1.2.3-node18`, `claude-sandbox:claude1.2.3-nodelts`

**Auto-build**
- If the computed image tag does not exist locally (`docker image inspect` fails)
  or `--build` is passed: run `docker build` with all four build-args, passing
  `$(id -u)` and `$(id -g)` for UID/GID
- If `--build`: exit after build

**Worktree detection**
- If `$workspace/.git` is a regular file (not a directory): it is a worktree
- Parse the `gitdir:` line to extract the parent git path (strip `/worktrees/<name>`)
- Add a read-only bind mount: `$parent_git:$parent_git:ro`
- If `.git` is a directory: no extra mount needed

**Mount assembly**
- Workspace: `$workspace:/home/agent/workspace` (read-write)
- Parent git: `$parent_git:$parent_git:ro` (only if worktree detected)
- Claude config: `$HOME/.claude:/home/agent/.claude` (read-write)

**Docker invocation**
```
docker run --rm \
  -v <workspace>:/home/agent/workspace \
  [-v <parent_git>:<parent_git>:ro] \
  -v $HOME/.claude:/home/agent/.claude \
  -e ANTHROPIC_API_KEY \
  -w /home/agent/workspace \
  <image> \
  claude --print --dangerously-skip-permissions <passthrough_args> -p <prompt>
```

The prompt is the first positional argument and is passed via `-p` (stdin
shorthand) to avoid the Linux 128KB argument size limit.

**Error guards** (checked before `docker run`)
- `$ANTHROPIC_API_KEY` unset → print error, exit 1
- `$workspace` does not exist → print error, exit 1

### Worktree detection — deep module

The logic that detects a worktree and extracts the parent git path is pure and
has no side effects. It should be extracted as a testable unit:

Input: workspace path
Output: parent git path, or empty string if not a worktree

### Image existence check — inline

`docker image inspect <tag> > /dev/null 2>&1` — exit code 0 means image exists.

## Testing Decisions

A good test for this project verifies **observable behaviour** (does the right
`docker run` command get assembled? does worktree detection produce the right
parent git path?) rather than internal state.

**Modules to test:**

- **Worktree detection logic**: given a workspace path where `.git` is a file
  containing a known `gitdir:` line, assert the correct parent git path is
  extracted. Pure function, no Docker needed.

- **Image tag computation**: given a Claude version and a Node version (from
  `.nvmrc` or default), assert the correct tag string is produced.

- **Arg parsing**: assert that `--build` and `--workspace` are consumed and
  everything else is collected as passthrough.

Tests should use `bats` (existing test framework in the repo, see
`scripts/bin/__tests__`).

## Out of Scope

- Daemon/long-running containers — each invocation is ephemeral
- Per-repository Dockerfiles — one shared image for all projects
- Windows support — Linux host only
- Network isolation — outbound internet access is required for the Anthropic API
- Ruby/Go/other language version management — Node via `.nvmrc` is the only
  per-project version concern addressed here
- Passing MCP server credentials into the sandbox beyond what is in `~/.claude/`

## Further Notes

- Sandcastle (`github.com/colinmarc/sandcastle`) was studied as prior art. The
  worktree mount strategy (mount parent `.git` at its original absolute path) is
  validated by Sandcastle's Linux implementation.
- The `ralph` script (`scripts/bin/claude/ralph`) is the primary consumer of
  `claude-sandbox` for AFK iterative workflows.
- The `--build` flag should also accept an optional `--workspace` so that the
  Node version is resolved from the correct `.nvmrc` when building for a
  specific project.
