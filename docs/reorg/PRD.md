## Problem Statement

Install scripts, deploy scripts, and config files for the same tool live in three separate directory trees (`scripts/install/`, `scripts/deploy/`, `config/`), each mirroring the same `{domain}/{tool}` hierarchy. Every time a tool is added, modified, or removed, the same domain/subdomain decision must be made independently in each tree. Removing a tool requires hunting across three locations. Path references inside deploy scripts are hardcoded absolute paths that break if a tool is ever moved to a different domain.

## Solution

Collapse the three trees into a single `tools/{domain}/{tool}/` hierarchy where everything related to a tool lives together: an `install` script, a `deploy` script, and a `config/` directory. Scripts reference their own config via `$(dirname "$0")/config` (relocatable). Cross-tool references use `$OROSHI_ROOT/tools/...`. Install scripts call their deploy script at the end so that installing a tool also configures it.

`scripts/bin/`, `scripts/etc/`, `scripts/yarn/`, and `config/term/zsh/functions/autoload/` are out of scope and remain untouched.

## User Stories

1. As a developer adding a new tool, I want a single folder to create under `tools/{domain}/{tool}/`, so that I only decide the domain once.
2. As a developer removing a tool, I want to delete a single folder, so that no orphaned install/deploy/config fragments are left behind.
3. As a developer moving a tool to a different domain, I want its scripts to keep working without path updates, so that reorganization stays cheap.
4. As a developer installing a tool, I want the install script to automatically run the deploy step, so that the tool is configured immediately after installation.
5. As a developer refreshing a tool's config, I want to run the deploy script independently without reinstalling, so that I don't redo expensive install steps.
6. As a developer installing all tools in a domain at once, I want a single `install-all` script at the domain level, so that bootstrapping a new machine stays simple.

## Implementation Decisions

### New structure

```
tools/
  {domain}/
    install-all          # optional — replaces former index files
    {tool}/
      install            # optional
      deploy             # optional
      config/            # optional
```

Every tool that currently has at least one of install/deploy/config gets its own folder, even if only one file exists inside.

### Intra-tool path references

Deploy scripts that reference their own config replace hardcoded `~/.oroshi/config/{domain}/{tool}/` with:

```sh
CONFIG_DIR="$(dirname "$0")/config"
```

### Cross-tool path references

Files that reference another tool's config (ZSH aliases, env vars, etc.) replace `~/.oroshi/config/{domain}/{tool}/` with `$OROSHI_ROOT/tools/{domain}/{tool}/config/`.

### Install → deploy wiring

Every `install` script that has a sibling `deploy` script adds this at the end:

```sh
"$(dirname "$0")/deploy"
```

### install-all

Domain-level `index` files are converted to `install-all` and their internal calls updated from `~/.oroshi/scripts/install/{domain}/{tool}` to `"$(dirname "$0")/{tool}/install"`.

### Domain naming

- `img` is renamed to `image` everywhere (normalization)
- `_languages` keeps its underscore (intentional marker for the special language-specific domain)

### ubuntu structure

`ubuntu` uses a version as an intermediate level, then each OS feature as its own tool:

```
tools/ubuntu/
  {version}/
    {feature}/
      deploy
      config/
```

No `install` at any level (Ubuntu is pre-installed).

### Canonical tool names

- `claudecode` → `claude`

### Migration order

Domains are migrated one at a time. Each domain migration is one atomic commit covering all of: file moves, intra-tool path updates, cross-tool path updates, install→deploy wiring, and install-all conversion.

Domains (16): `ai`, `audio`, `basics`, `cli`, `docker`, `git`, `image`, `infrastructure`, `keybindings`, `_languages`, `misc`, `term`, `ubuntu`, `vim`, `windows`, `worktools`

### Cleanup

After all 16 domains are migrated:
- Delete `scripts/install/` (should be empty)
- Delete `scripts/deploy/` (should be empty)
- Delete `config/` (should be empty)
- Delete `config/__archive/` (archived tools, not migrated)

If any of these directories are not empty at cleanup time, the remaining content must be addressed before deletion.

## Testing Decisions

No automated tests. Migration is verified manually per domain by inspecting the resulting file tree and spot-checking that path references in moved scripts resolve correctly.

## Out of Scope

- `scripts/bin/` — executables on `$PATH`, separate lifecycle, not touched
- `scripts/etc/` — utility scripts outside the install/deploy/config pattern, not touched
- `scripts/yarn/` — workspace config, not touched
- `config/term/zsh/functions/autoload/` — moves naturally as part of the `term/zsh` domain migration (it lives inside `config/term/zsh/`), no special handling needed
- Automated migration scripts
- Any changes to `scripts/bin/` domain naming or organization
