## Problem Statement

The SSH mock Docker container mounts `/tmp/oroshi` symmetrically (same path inside and outside). This path leaks the oroshi project identity into what should be a generic testing tool. Other projects (e.g. Emulation sync scripts) should be able to reuse the mock SSH host without referencing oroshi. The container name `oroshi-mock-ssh` has the same problem.

The bats test sandbox root (`bats_tmp_dir()`) also lives under `/tmp/oroshi`, coupling all 229 test files to an oroshi-specific path through the shared mount.

## Solution

Replace `/tmp/oroshi` with `/tmp/sandbox` as the shared root for the Docker symmetric mount and bats test sandboxes. Rename the container from `oroshi-mock-ssh` to `ssh-mock`. Both values are hardcoded — no new environment variables introduced.

## User Stories

1. As a developer working on a non-oroshi project, I want to call `ssh-mock-start` and get a generic mock SSH host, so that I can test SSH/SCP/rsync operations without depending on oroshi's namespace.
2. As a bats test author, I want `$BATS_TMP_DIR` to land inside the Docker mount automatically, so that SSH assertions remain symmetric without path translation.
3. As a developer reading the codebase, I want the container name to match the function naming convention (`ssh-mock-start` / `ssh-mock-stop`), so that the relationship is obvious.
4. As a developer grepping for the mount path, I want it hardcoded in exactly two places (`ssh-mock-start` and `bats_tmp_dir()`), so that discoverability is trivial.
5. As a developer running existing bats tests, I want zero behavioral changes after the rename, so that the 229 existing test files continue to pass without modification.

## Implementation Decisions

- **Mount path**: `/tmp/sandbox:/tmp/sandbox` — hardcoded in `ssh-mock-start`. Short, generic, not project-scoped.
- **Bats sandbox root**: `/tmp/sandbox/bats/<file>/<slug>` — hardcoded in `bats_tmp_dir()`. All 229 consumers use `$BATS_TMP_DIR` so the change propagates automatically.
- **Container name**: `ssh-mock` — mirrors the `ssh-mock-start`/`ssh-mock-stop` function names. Referenced in `ssh-mock-start`, `ssh-mock-stop`, and documentation.
- **No environment variable**: Two hardcoded references don't warrant an env var. Consumers already get the path via `$BATS_TMP_DIR`.
- **Scope limited to 5 files**: Only the SSH mock system and bats helper are touched. The ~20 other files referencing `/tmp/oroshi` (claude hooks, kitty, ebook, throttle, etc.) are unrelated concerns and stay as-is.

## Testing Decisions

No new tests. The existing test suite validates the change:

- `mock.bats` — exercises real SSH/SCP through the mock container, uses `bats_tmp_dir` and `bats_ssh_mock_start`. Will run against the new `/tmp/sandbox` path and `ssh-mock` container.
- `helper.bats` — tests `bats_tmp_dir`, `bats_mock`, `bats_mock_env`, `bats_cleanup`. Will verify sandboxes are created and cleaned under `/tmp/sandbox`.
- `helper-default-teardown.bats` — tests the default teardown cleanup. Has a hardcoded coordination file path that moves to `/tmp/sandbox`.

Prior art: these tests already exist and cover the exact surface area being changed.

## Out of Scope

- Renaming or moving other `/tmp/oroshi` references (claude hooks, kitty, ebook, throttle, fzf, etc.) — these are separate concerns with their own consumers.
- Introducing an `$SSH_MOCK_ROOT` or `$SANDBOX_ROOT` environment variable — not needed with only two hardcoded references.
- Changing the SSH config `Host mock` block or key paths — these are identity concerns, not path concerns.
- Mounting `/tmp:/tmp` broadly — rejected in favor of scoped mount to limit blast radius.
