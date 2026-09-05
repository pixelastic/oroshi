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
