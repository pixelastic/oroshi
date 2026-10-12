package git

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Helpers ---

func runGit(t *testing.T, directory string, args ...string) {
	t.Helper()
	cmd := exec.Command("git", args...)
	cmd.Dir = directory
	output, err := cmd.CombinedOutput()
	require.NoError(t, err, string(output))
}

func writeFile(t *testing.T, directory, name, content string) {
	t.Helper()
	require.NoError(t, os.WriteFile(filepath.Join(directory, name), []byte(content), 0o644))
}

// newRepo creates a repository with one commit containing base.txt.
func newRepo(t *testing.T) string {
	t.Helper()
	directory := t.TempDir()
	runGit(t, directory, "init", "--quiet", "--initial-branch=main")
	runGit(t, directory, "config", "user.email", "test@example.com")
	runGit(t, directory, "config", "user.name", "Test")
	runGit(t, directory, "config", "commit.gpgsign", "false")
	writeFile(t, directory, "base.txt", "base\n")
	runGit(t, directory, "add", ".")
	runGit(t, directory, "commit", "--quiet", "-m", "base")
	return directory
}

// --- VerifyRef ---

func TestVerifyRefAcceptsBranch(t *testing.T) {
	repo := newRepo(t)

	assert.NoError(t, VerifyRef(repo, "main"))
}

func TestVerifyRefAcceptsTag(t *testing.T) {
	repo := newRepo(t)
	runGit(t, repo, "tag", "v1")

	assert.NoError(t, VerifyRef(repo, "v1"))
}

func TestVerifyRefAcceptsCommitHash(t *testing.T) {
	repo := newRepo(t)
	hash, err := Head(repo)
	require.NoError(t, err)

	assert.NoError(t, VerifyRef(repo, hash))
}

func TestVerifyRefRejectsUnknownRef(t *testing.T) {
	repo := newRepo(t)

	err := VerifyRef(repo, "does-not-exist")

	require.Error(t, err)
	assert.Contains(t, err.Error(), "does-not-exist")
}

func TestVerifyRefRejectsEmptyRef(t *testing.T) {
	repo := newRepo(t)

	assert.Error(t, VerifyRef(repo, ""))
}

func TestSyntheticNewFileDiffGeneratesValidDiffHeader(t *testing.T) {
	result := SyntheticNewFileDiff("src/new.go", "package main\n")

	assert.Contains(t, result, "diff --git a/src/new.go b/src/new.go")
	assert.Contains(t, result, "--- /dev/null")
	assert.Contains(t, result, "+++ b/src/new.go")
}

func TestSyntheticNewFileDiffGeneratesCorrectHunkHeader(t *testing.T) {
	result := SyntheticNewFileDiff("file.txt", "line1\nline2\nline3\n")

	assert.Contains(t, result, "@@ -0,0 +1,3 @@")
}

func TestSyntheticNewFileDiffPrefixesEveryLineWithPlus(t *testing.T) {
	result := SyntheticNewFileDiff("file.txt", "aaa\nbbb\n")

	assert.Contains(t, result, "+aaa\n")
	assert.Contains(t, result, "+bbb\n")
}

func TestSyntheticNewFileDiffHandlesSingleLineFile(t *testing.T) {
	result := SyntheticNewFileDiff("file.txt", "only\n")

	assert.Contains(t, result, "@@ -0,0 +1,1 @@")
	assert.Contains(t, result, "+only\n")
}

func TestSyntheticNewFileDiffReturnsEmptyForEmptyContent(t *testing.T) {
	assert.Empty(t, SyntheticNewFileDiff("file.txt", ""))
	assert.Empty(t, SyntheticNewFileDiff("file.txt", "\n"))
}

func TestSyntheticNewFileDiffReturnsBinaryMarkerForBinaryContent(t *testing.T) {
	binaryContent := "PNG\x89\x00\x1a\x00"
	result := SyntheticNewFileDiff("image.png", binaryContent)

	assert.Contains(t, result, "Binary files")
	assert.NotContains(t, result, "@@")
}

func TestSyntheticNewFileDiffTreatsTextContentAsText(t *testing.T) {
	result := SyntheticNewFileDiff("file.txt", "hello world\n")

	assert.Contains(t, result, "+hello world")
	assert.NotContains(t, result, "Binary files")
}

// --- prefixDiffPaths ---

func TestPrefixDiffPathsRewritesDiffGitLine(t *testing.T) {
	input := "diff --git a/file.go b/file.go\n"

	result := prefixDiffPaths(input, "private")

	assert.Contains(t, result, "diff --git a/private/file.go b/private/file.go")
}

func TestPrefixDiffPathsRewritesMinusLine(t *testing.T) {
	input := "--- a/file.go\n"

	result := prefixDiffPaths(input, "sub")

	assert.Contains(t, result, "--- a/sub/file.go")
}

func TestPrefixDiffPathsRewritesPlusLine(t *testing.T) {
	input := "+++ b/file.go\n"

	result := prefixDiffPaths(input, "sub")

	assert.Contains(t, result, "+++ b/sub/file.go")
}

func TestPrefixDiffPathsPreservesDevNull(t *testing.T) {
	input := "--- /dev/null\n+++ b/new.go\n"

	result := prefixDiffPaths(input, "sub")

	assert.Contains(t, result, "--- /dev/null")
	assert.Contains(t, result, "+++ b/sub/new.go")
}

func TestPrefixDiffPathsPreservesContentLines(t *testing.T) {
	input := "+added line\n-removed line\n context line\n"

	result := prefixDiffPaths(input, "sub")

	assert.Contains(t, result, "+added line\n")
	assert.Contains(t, result, "-removed line\n")
	assert.Contains(t, result, " context line\n")
}

func TestPrefixDiffPathsReturnsEmptyForEmptyInput(t *testing.T) {
	assert.Empty(t, prefixDiffPaths("", "sub"))
}

func TestPrefixDiffPathsHandlesNestedPaths(t *testing.T) {
	input := "diff --git a/src/main.go b/src/main.go\n--- a/src/main.go\n+++ b/src/main.go\n"

	result := prefixDiffPaths(input, "tools/ansible")

	assert.Contains(t, result, "diff --git a/tools/ansible/src/main.go b/tools/ansible/src/main.go")
	assert.Contains(t, result, "--- a/tools/ansible/src/main.go")
	assert.Contains(t, result, "+++ b/tools/ansible/src/main.go")
}

func TestPrefixDiffPathsHandlesFullDiff(t *testing.T) {
	input := "diff --git a/file.go b/file.go\nindex abc..def 100644\n--- a/file.go\n+++ b/file.go\n@@ -1,3 +1,4 @@\n line1\n+new\n line2\n"

	result := prefixDiffPaths(input, "private")

	assert.Contains(t, result, "diff --git a/private/file.go b/private/file.go")
	assert.Contains(t, result, "--- a/private/file.go")
	assert.Contains(t, result, "+++ b/private/file.go")
	assert.Contains(t, result, "@@ -1,3 +1,4 @@")
	assert.Contains(t, result, "+new\n")
}

// --- Diff ---

func TestDiffWithRefIncludesCommittedChanges(t *testing.T) {
	repo := newRepo(t)
	runGit(t, repo, "tag", "start")
	writeFile(t, repo, "committed.txt", "committed\n")
	runGit(t, repo, "add", ".")
	runGit(t, repo, "commit", "--quiet", "-m", "later")

	result, err := Diff(repo, "start")

	require.NoError(t, err)
	assert.Contains(t, result, "diff --git a/committed.txt b/committed.txt")
}

func TestDiffWithRefIncludesStagedChanges(t *testing.T) {
	repo := newRepo(t)
	runGit(t, repo, "tag", "start")
	writeFile(t, repo, "staged.txt", "staged\n")
	runGit(t, repo, "add", "staged.txt")

	result, err := Diff(repo, "start")

	require.NoError(t, err)
	assert.Contains(t, result, "diff --git a/staged.txt b/staged.txt")
}

func TestDiffWithRefIncludesUnstagedChanges(t *testing.T) {
	repo := newRepo(t)
	runGit(t, repo, "tag", "start")
	writeFile(t, repo, "base.txt", "base\nmodified\n")

	result, err := Diff(repo, "start")

	require.NoError(t, err)
	assert.Contains(t, result, "diff --git a/base.txt b/base.txt")
	assert.Contains(t, result, "+modified")
}

func TestDiffWithRefIncludesUntrackedFilesAsNewFiles(t *testing.T) {
	repo := newRepo(t)
	runGit(t, repo, "tag", "start")
	writeFile(t, repo, "untracked.txt", "untracked\n")

	result, err := Diff(repo, "start")

	require.NoError(t, err)
	assert.Contains(t, result, "diff --git a/untracked.txt b/untracked.txt")
	assert.Contains(t, result, "new file mode")
}

func TestDiffWithoutRefIgnoresCommittedChanges(t *testing.T) {
	repo := newRepo(t)
	writeFile(t, repo, "committed.txt", "committed\n")
	runGit(t, repo, "add", ".")
	runGit(t, repo, "commit", "--quiet", "-m", "later")
	writeFile(t, repo, "base.txt", "base\nmodified\n")

	result, err := Diff(repo, "")

	require.NoError(t, err)
	assert.Contains(t, result, "diff --git a/base.txt b/base.txt")
	assert.NotContains(t, result, "committed.txt")
}
