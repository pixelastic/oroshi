package diff

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Parsing ---

func TestParsesSingleFileDiffWithOneHunk(t *testing.T) {
	raw := `diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
--- a/file.txt
+++ b/file.txt
@@ -1,3 +1,4 @@
 context line
+added line
 another context
 last context
`
	result := Parse(raw)
	require.Len(t, result, 1)
	assert.Equal(t, "file.txt", result[0].Path)
	require.Len(t, result[0].Hunks, 1)
	assert.Equal(t, 1, result[0].Hunks[0].OldStart)
	assert.Equal(t, 3, result[0].Hunks[0].OldCount)
	assert.Equal(t, 1, result[0].Hunks[0].NewStart)
	assert.Equal(t, 4, result[0].Hunks[0].NewCount)
	require.Len(t, result[0].Hunks[0].Lines, 4)
	assert.Equal(t, DiffLine{Content: "context line", Kind: KindContext}, result[0].Hunks[0].Lines[0])
	assert.Equal(t, DiffLine{Content: "added line", Kind: KindAdded}, result[0].Hunks[0].Lines[1])
	assert.Equal(t, DiffLine{Content: "another context", Kind: KindContext}, result[0].Hunks[0].Lines[2])
	assert.Equal(t, DiffLine{Content: "last context", Kind: KindContext}, result[0].Hunks[0].Lines[3])
}

func TestParsesSingleFileDiffWithMultipleHunks(t *testing.T) {
	raw := `diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
--- a/file.txt
+++ b/file.txt
@@ -1,3 +1,4 @@
 context
+added
 context
 context
@@ -10,3 +11,3 @@
 context
-removed
+replaced
 context
`
	result := Parse(raw)
	require.Len(t, result, 1)
	require.Len(t, result[0].Hunks, 2)
	assert.Equal(t, 1, result[0].Hunks[0].NewStart)
	assert.Equal(t, 11, result[0].Hunks[1].NewStart)
}

func TestParsesMultiFileDiff(t *testing.T) {
	raw := `diff --git a/foo.txt b/foo.txt
index 1234567..abcdefg 100644
--- a/foo.txt
+++ b/foo.txt
@@ -1,2 +1,3 @@
 context
+added
 context
diff --git a/bar.txt b/bar.txt
index 1234567..abcdefg 100644
--- a/bar.txt
+++ b/bar.txt
@@ -1,2 +1,2 @@
-old
+new
 context
`
	result := Parse(raw)
	require.Len(t, result, 2)
	assert.Equal(t, "foo.txt", result[0].Path)
	assert.Equal(t, "bar.txt", result[1].Path)
}

func TestParsesEmptyDiffAsEmptySlice(t *testing.T) {
	result := Parse("")
	assert.Empty(t, result)
}

func TestExtractsCorrectFilePaths(t *testing.T) {
	raw := `diff --git a/path/to/file.go b/path/to/file.go
index 1234567..abcdefg 100644
--- a/path/to/file.go
+++ b/path/to/file.go
@@ -1,1 +1,2 @@
 context
+added
`
	result := Parse(raw)
	require.Len(t, result, 1)
	assert.Equal(t, "path/to/file.go", result[0].Path)
}

func TestExtractsCorrectHunkRanges(t *testing.T) {
	raw := `diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
--- a/file.txt
+++ b/file.txt
@@ -5,7 +10,12 @@
 context
+added
 context
`
	result := Parse(raw)
	require.Len(t, result, 1)
	require.Len(t, result[0].Hunks, 1)
	hunk := result[0].Hunks[0]
	assert.Equal(t, 5, hunk.OldStart)
	assert.Equal(t, 7, hunk.OldCount)
	assert.Equal(t, 10, hunk.NewStart)
	assert.Equal(t, 12, hunk.NewCount)
}

// --- Classification ---

func TestMarksAddedLinesAsAdded(t *testing.T) {
	hunks := []Hunk{
		{
			NewStart: 1, NewCount: 3,
			OldStart: 1, OldCount: 2,
			Lines: []DiffLine{
				{Content: "context", Kind: KindContext},
				{Content: "new line", Kind: KindAdded},
				{Content: "context", Kind: KindContext},
			},
		},
	}
	markers := Classify(hunks)
	assert.Equal(t, MarkerAdded, markers[2])
}

func TestMarksAddedLinesAdjacentToRemovedAsModified(t *testing.T) {
	hunks := []Hunk{
		{
			NewStart: 1, NewCount: 2,
			OldStart: 1, OldCount: 2,
			Lines: []DiffLine{
				{Content: "old line", Kind: KindRemoved},
				{Content: "new line", Kind: KindAdded},
				{Content: "context", Kind: KindContext},
			},
		},
	}
	markers := Classify(hunks)
	assert.Equal(t, MarkerModified, markers[1])
}

func TestMarksOrphanedRemovedLinesAsDeletedOnNearestSurvivingLine(t *testing.T) {
	hunks := []Hunk{
		{
			NewStart: 1, NewCount: 2,
			OldStart: 1, OldCount: 3,
			Lines: []DiffLine{
				{Content: "context before", Kind: KindContext},
				{Content: "deleted line", Kind: KindRemoved},
				{Content: "context after", Kind: KindContext},
			},
		},
	}
	markers := Classify(hunks)
	// Orphaned removed line → Deleted marker on nearest surviving line (line 2)
	assert.Equal(t, MarkerDeleted, markers[2])
}

func TestHandlesHunkWithOnlyAdditions(t *testing.T) {
	hunks := []Hunk{
		{
			NewStart: 1, NewCount: 3,
			OldStart: 1, OldCount: 0,
			Lines: []DiffLine{
				{Content: "line one", Kind: KindAdded},
				{Content: "line two", Kind: KindAdded},
				{Content: "line three", Kind: KindAdded},
			},
		},
	}
	markers := Classify(hunks)
	assert.Equal(t, MarkerAdded, markers[1])
	assert.Equal(t, MarkerAdded, markers[2])
	assert.Equal(t, MarkerAdded, markers[3])
}

func TestHandlesHunkWithOnlyDeletions(t *testing.T) {
	hunks := []Hunk{
		{
			NewStart: 5, NewCount: 1,
			OldStart: 5, OldCount: 3,
			Lines: []DiffLine{
				{Content: "removed one", Kind: KindRemoved},
				{Content: "removed two", Kind: KindRemoved},
				{Content: "surviving", Kind: KindContext},
			},
		},
	}
	markers := Classify(hunks)
	assert.Equal(t, MarkerDeleted, markers[5])
}

func TestHandlesHunkWithMixedAdditionsAndDeletions(t *testing.T) {
	hunks := []Hunk{
		{
			NewStart: 1, NewCount: 4,
			OldStart: 1, OldCount: 3,
			Lines: []DiffLine{
				{Content: "context", Kind: KindContext},
				{Content: "old", Kind: KindRemoved},
				{Content: "new", Kind: KindAdded},
				{Content: "fresh", Kind: KindAdded},
				{Content: "context", Kind: KindContext},
			},
		},
	}
	markers := Classify(hunks)
	// "new" replaces "old" → Modified
	assert.Equal(t, MarkerModified, markers[2])
	// "fresh" is added with no adjacent removed → Added
	assert.Equal(t, MarkerAdded, markers[3])
}
