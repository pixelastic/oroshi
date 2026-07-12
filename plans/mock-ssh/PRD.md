## Problem Statement

Bats tests that exercise SSH-dependent code (deploy scripts, file sync, remote execution) currently have no way to test `ssh`, `scp`, and `rsync` calls against a real SSH stack without hitting actual remote servers. Mocking those binaries defeats the purpose — the test cannot verify that the actual command syntax, flags, and file transfer semantics work correctly.

## Solution

A persistent Docker container running an Alpine SSH server, reachable as `Host mock` from `~/.ssh/config`, with `/tmp/oroshi/` mounted symmetrically (same path inside and outside the container). Tests call real `ssh mock`, `scp`, and `rsync mock:` commands; after each call they assert what landed in `$BATS_TMP_DIR` on the local filesystem. A bats helper function `mock_ssh_host` starts the container idempotently — once running, it stays up across test runs for zero startup overhead.

## User Stories

1. As a test author, I want to call `ssh mock "some-command"` in a bats test so that I can verify remote command execution works end-to-end without hitting a real server.
2. As a test author, I want to call `scp file.txt mock:$BATS_TMP_DIR/file.txt` so that I can assert that file transfer logic produces the expected file at the expected path.
3. As a test author, I want to call `rsync -a dir/ mock:$BATS_TMP_DIR/` so that I can verify rsync sync logic works against a real SSH endpoint.
4. As a test author, I want tests using `mock` to run in parallel without interfering with each other, so that CI stays fast.
5. As a test author, I want `mock_ssh_host` in `setup_file` to be a no-op when the container is already running, so that repeated test runs do not pay Docker startup cost.
6. As a test author, I want `$BATS_TMP_DIR` to be the same path inside and outside the container, so that I can assert local files without any path translation.
7. As a developer, I want `Host mock` to be included automatically after running the existing SSH deploy script, so that no manual config step is needed.
8. As a developer, I want the dummy SSH keys to be committed to the repository alongside the mock tooling, so that the mock works immediately after checkout with no key generation step.
9. As a developer, I want the mock SSH container to use my host UID/GID (with a fixed `mock` username), so that files written by SSH operations are owned by my host user and can be cleaned up without permission issues.
10. As a developer, I want `ControlMaster no` set on `Host mock`, so that test connections are never multiplexed and do not share state between tests.
11. As a developer, I want a README in the mock directory explaining how the setup works and how to use it in tests, so that future contributors can onboard quickly.

## Implementation Decisions

### Mock SSH Docker server

- Base image: Alpine Linux with `openssh` installed.
- The SSH server runs on port 2222 on localhost.
- The container username is fixed: `mock`. The host user's UID and GID are passed as Docker build arguments (`USER_ID`, `GROUP_ID`) so file ownership matches the host user.
- The dummy public key is baked into the image at build time (`authorized_keys`).
- `/tmp/oroshi/` is mounted into the container at the same path, so `$BATS_TMP_DIR` is identical inside and outside.
- The container is started with a fixed name (`oroshi-mock-ssh`) so idempotency checks can use `docker ps`.
- The image is rebuilt on each `start` invocation; Docker layer caching makes this fast unless the Dockerfile changes.

### SSH key pair

- One ed25519 key pair, committed to the repository inside the mock directory, named `id_mock` and `id_mock.pub`.
- No passphrase. These keys are non-sensitive: the container only listens on localhost and the keys have no meaning outside a local test environment.
- The `IdentityFile` in the SSH config block points to the committed key path under `~/.oroshi/`.

### SSH config (`Host mock` block)

- Added directly to `config/default` (the file already concatenated by the existing SSH deploy script), before the `Host *` catch-all block.
- Settings: `HostName localhost`, `Port 2222`, `User mock`, `ControlMaster no`, `StrictHostKeyChecking no`, `UserKnownHostsFile /dev/null`.
- `StrictHostKeyChecking no` and `UserKnownHostsFile /dev/null` prevent host key verification failures when the container is rebuilt.
- `ControlMaster no` prevents connection multiplexing from leaking state between parallel tests.

### Bats helper — `mock_ssh_host`

- Added to the existing shared bats helper (`tools/term/bats/config/helper`), available to all tests without any extra `source` or `bats_load_library` call.
- Idempotent: checks whether the named container is already running; if yes, returns immediately; if no, builds the image and starts the container.
- Intended for `setup_file` — called once per test file, not per test.

### No teardown function

- No `mock_ssh_stop` or `mock_ssh_teardown` is provided. The container is persistent by design — it stays running between test files and between test runs.
- Developers who want to stop it do so manually with standard Docker commands.

## Testing Decisions

Good tests for this feature assert observable external behavior — files that land on the local filesystem and output from SSH commands — not Docker internals or implementation details of the helper function.

**Module with tests: Mock SSH Docker server (integration tests)**

Tests call real `ssh` and `scp` against `Host mock` and assert results in `$BATS_TMP_DIR`:

- Verify that `scp` correctly transfers a file from local to remote, and that the file appears at the expected local path (via the symmetric mount).
- Verify that `ssh mock "echo hello"` returns `hello` as output.

These tests exercise the full stack: SSH config, key auth, container networking, volume mount, and filesystem write — all in one pass.

**Prior art:** `tools/term/bats/config/__tests__/helper.bats` demonstrates the established pattern for testing bats helper functions. The git integration tests (e.g. `scripts/bin/git/commit/__tests__/`) show the pattern of using real external tools (git repos, commits) rather than mocks when the goal is end-to-end verification.

## Out of Scope

- SSH agent forwarding or host key persistence across container rebuilds.
- `rsync` tested directly (covered implicitly by the same SSH plumbing; not a separate test case).
- A `mock_ssh_stop` helper — the container is persistent by design.
- Dynamic port selection — port 2222 is fixed.
- Support for multiple simultaneous mock SSH containers (one is sufficient).
- Any CI-specific Docker setup — assumes Docker is available on the developer's machine.

## Further Notes

The symmetric `/tmp/oroshi/` mount is the key architectural decision: it means `$BATS_TMP_DIR` (already per-test isolated by the bats helper) serves as the assertion target without any path translation. Parallel tests write to distinct paths under `/tmp/oroshi/bats/<file>/<slug>/` and never collide.
