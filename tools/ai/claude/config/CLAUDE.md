## Commands

- **Testing go:** Run `go-test <filepath>`
- **Testing js:** Run `js-test <filepath>`
- **Testing python:** Run `python-test <filepath>`
- **Testing zsh:** Run `zsh-test <filepath>`
- Tests files live in `__tests__` directories

- **Linting bats:** Run `bats-lint <filepath>`
- **Linting go:** Run `go-lint <filepath>`
- **Linting json:** Run `json-lint <filepath>`
- **Linting js:** Run `js-lint <filepath>`
- **Linting python:** Run `python-lint <filepath>`
- **Linting svg:** Run `svg-lint <filepath>`
- **Linting toml:** Run `toml-lint <filepath>`
- **Linting xml:** Run `xml-lint <filepath>`
- **Linting zsh:** Run `zsh-lint <filepath>`

## Code

- DO: Prefer ZSH or JS for scripts; use Python only when there is no other choice.
- DO: Use `jq`/`jo` for JSON parsing in shell, never Python
- DO: Use dedicated `/{lang}-writer` skill if one exists
- DO: Fetch up-to-date documentation (using Context7 MCP) before writing code
- DO: When editing code, preserve its comments. When deleting code, delete its comments with it.

## Plan

- Run `plan-directory` to find the PRD and issues for a given worktree

## Clipboard

- DO: When asked to put something in the clipboard, use the `clipboard-write` command.
- DO NOT: use `xclip`, `xsel`, `pbcopy`, or `wl-copy` directly.

## Helpers

Prefer dedicated CLI helpers, over raw calls or MCP servers:

| Instead of…                | Use helpers from domain… |
|----------------------------|--------------------------|
| `git` complex pipelines    | `git`                    |
| `convert`, `imagemagick`   | `img`                    |
| `yarn` multi-step commands | `yarn`                   |
| `ffmpeg` pipelines         | `audio`, `video`         |
| `docker` commands          | `docker`                 |
| MCP Google                 | `gmail`                 |
| MCP Atlassian               | `confluence`                 |


Discover helpers with `helper-list <domain> [action]` — all returned helpers are in PATH and callable directly:
- `helper-list git branch` — find git branch helpers
- `helper-list img` — list all image helpers

Use matching helpers over raw commands; if none match, fall back to standard tools.

## Throw-away scripts

Use the `/debug-script` skill when writing complex or multi-step Bash commands.
