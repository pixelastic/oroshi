package comments

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Load ---

func TestLoadReadsValidJSONArray(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "comments.json")
	data := `[{"filepath":"/a.go","lineNumber":5,"lineContent":"hello","review":"fix this"}]`
	require.NoError(t, os.WriteFile(path, []byte(data), 0o644))

	comments, err := Load(path)
	require.NoError(t, err)
	require.Len(t, comments, 1)
	assert.Equal(t, "/a.go", comments[0].Filepath)
	assert.Equal(t, 5, comments[0].LineNumber)
	assert.Equal(t, "hello", comments[0].LineContent)
	assert.Equal(t, "fix this", comments[0].Review)
}

func TestLoadReturnsEmptySliceForMissingFile(t *testing.T) {
	comments, err := Load("/nonexistent/path/comments.json")
	require.NoError(t, err)
	assert.Empty(t, comments)
}

// --- Save ---

func TestSaveWritesJSONArrayToDisk(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "comments.json")
	input := []Comment{
		{Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "fix this"},
	}

	err := Save(path, input)
	require.NoError(t, err)

	raw, err := os.ReadFile(path)
	require.NoError(t, err)

	loaded, err := Load(path)
	require.NoError(t, err)
	require.Len(t, loaded, 1)
	assert.Equal(t, input[0], loaded[0])
	_ = raw
}

// --- Upsert ---

func TestUpsertAddsNewComment(t *testing.T) {
	comments := []Comment{}
	comment := Comment{Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "fix"}

	result := Upsert(comments, comment)

	require.Len(t, result, 1)
	assert.Equal(t, comment, result[0])
}

func TestUpsertUpdatesExistingCommentAtSameFilepathAndLineNumber(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "old"},
	}
	updated := Comment{Filepath: "/a.go", LineNumber: 5, LineContent: "hello changed", Review: "new"}

	result := Upsert(comments, updated)

	require.Len(t, result, 1)
	assert.Equal(t, "new", result[0].Review)
	assert.Equal(t, "hello changed", result[0].LineContent)
}

// --- Delete ---

func TestDeleteRemovesCommentByFilepathAndLineNumber(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "fix"},
		{Filepath: "/b.go", LineNumber: 10, LineContent: "world", Review: "ok"},
	}

	result := Delete(comments, "/a.go", 5)

	require.Len(t, result, 1)
	assert.Equal(t, "/b.go", result[0].Filepath)
}

func TestDeleteIsNoOpForNonExistentComment(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "fix"},
	}

	result := Delete(comments, "/z.go", 99)

	assert.Len(t, result, 1)
}

// --- Reattach ---

func TestReattachUpdatesLineNumberWhenContentFoundAtDifferentLine(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 3, LineContent: "target line", Review: "fix"},
	}
	fileLines := map[string][]string{
		"/a.go": {"first", "second", "third", "target line", "fifth"},
	}

	result := Reattach(comments, fileLines)

	require.Len(t, result, 1)
	assert.Equal(t, 4, result[0].LineNumber)
}

func TestReattachKeepsOriginalLineNumberWhenContentNotFoundButLineValid(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 2, LineContent: "gone", Review: "fix"},
	}
	fileLines := map[string][]string{
		"/a.go": {"first", "second", "third"},
	}

	result := Reattach(comments, fileLines)

	require.Len(t, result, 1)
	assert.Equal(t, 2, result[0].LineNumber)
}

func TestReattachDropsCommentWhenLineNumberOutOfBoundsAndContentNotFound(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 99, LineContent: "gone", Review: "fix"},
	}
	fileLines := map[string][]string{
		"/a.go": {"first", "second"},
	}

	result := Reattach(comments, fileLines)

	assert.Empty(t, result)
}

func TestReattachHandlesMultipleCommentsInSameFile(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 1, LineContent: "moved", Review: "r1"},
		{Filepath: "/a.go", LineNumber: 2, LineContent: "stays", Review: "r2"},
	}
	fileLines := map[string][]string{
		"/a.go": {"stays", "other", "moved"},
	}

	result := Reattach(comments, fileLines)

	require.Len(t, result, 2)
	// "moved" found at line 3
	assert.Equal(t, 3, result[0].LineNumber)
	// "stays" found at line 1
	assert.Equal(t, 1, result[1].LineNumber)
}
