package git

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

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
