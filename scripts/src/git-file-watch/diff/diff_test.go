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
	assert.Equal(t, DiffLine{Content: "context line", Kind: "context"}, result[0].Hunks[0].Lines[0])
	assert.Equal(t, DiffLine{Content: "added line", Kind: "added"}, result[0].Hunks[0].Lines[1])
	assert.Equal(t, DiffLine{Content: "another context", Kind: "context"}, result[0].Hunks[0].Lines[2])
	assert.Equal(t, DiffLine{Content: "last context", Kind: "context"}, result[0].Hunks[0].Lines[3])
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
				{Content: "context", Kind: "context"},
				{Content: "new line", Kind: "added"},
				{Content: "context", Kind: "context"},
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
				{Content: "old line", Kind: "removed"},
				{Content: "new line", Kind: "added"},
				{Content: "context", Kind: "context"},
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
				{Content: "context before", Kind: "context"},
				{Content: "deleted line", Kind: "removed"},
				{Content: "context after", Kind: "context"},
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
				{Content: "line one", Kind: "added"},
				{Content: "line two", Kind: "added"},
				{Content: "line three", Kind: "added"},
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
				{Content: "removed one", Kind: "removed"},
				{Content: "removed two", Kind: "removed"},
				{Content: "surviving", Kind: "context"},
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
				{Content: "context", Kind: "context"},
				{Content: "old", Kind: "removed"},
				{Content: "new", Kind: "added"},
				{Content: "fresh", Kind: "added"},
				{Content: "context", Kind: "context"},
			},
		},
	}
	markers := Classify(hunks)
	// "new" replaces "old" → Modified
	assert.Equal(t, MarkerModified, markers[2])
	// "fresh" is added with no adjacent removed → Added
	assert.Equal(t, MarkerAdded, markers[3])
}
