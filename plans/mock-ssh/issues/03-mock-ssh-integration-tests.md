## TLDR

Write integration tests that verify `scp` and `ssh` work end-to-end against the mock host.

## What to build

Create `tools/basics/ssh/mock/__tests__/mock.bats` with two behavioral tests. The test file calls `mock_ssh_host` in `setup_file` and `bats_tmp_dir` in `setup`.

Both tests use `$BATS_TMP_DIR` as the remote path — because `/tmp/oroshi` is mounted symmetrically, the path is identical inside and outside the container, so no translation is needed for assertions.

## Behavioral Tests

**`scp transfers a file from local to the expected path on the mock host`**
Write a file to `$BATS_TMP_DIR/input.txt`, scp it to `mock:$BATS_TMP_DIR/output.txt`, assert that `$BATS_TMP_DIR/output.txt` exists locally with the correct content.

**`ssh executes a command on the mock host and returns its output`**
Run `ssh mock "echo hello"`, assert the output is `hello`.

## Acceptance criteria

- [ ] `bats tools/basics/ssh/mock/__tests__/mock.bats` passes
- [ ] The `scp` test asserts the file exists at `$BATS_TMP_DIR` on the local filesystem
- [ ] The `ssh` test asserts command output is captured correctly
- [ ] `bats-lint` passes on the test file
