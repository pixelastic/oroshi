package comments

import (
	"encoding/json"
	"os"
	"path/filepath"
	"regexp"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var hexPattern = regexp.MustCompile(`^[0-9a-f]{8}$`)

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

	result, err := Upsert(comments, comment, "abc123")
	require.NoError(t, err)

	require.Len(t, result, 1)
	assert.Equal(t, "/a.go", result[0].Filepath)
	assert.Equal(t, "fix", result[0].Review)
}

func TestUpsertUpdatesExistingCommentAtSameFilepathAndLineNumber(t *testing.T) {
	comments := []Comment{
		{ID: "aabb0011", Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "old", CommitHash: "orig"},
	}
	updated := Comment{Filepath: "/a.go", LineNumber: 5, LineContent: "hello changed", Review: "new"}

	result, err := Upsert(comments, updated, "newhead")
	require.NoError(t, err)

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

// --- FindReview ---

func TestFindReviewReturnsMatchingReviewText(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 5, Review: "fix this"},
		{Filepath: "/b.go", LineNumber: 10, Review: "looks good"},
	}

	result := FindReview(comments, "/a.go", 5)

	assert.Equal(t, "fix this", result)
}

func TestFindReviewReturnsEmptyStringWhenNoMatch(t *testing.T) {
	comments := []Comment{
		{Filepath: "/a.go", LineNumber: 5, Review: "fix this"},
	}

	result := FindReview(comments, "/z.go", 99)

	assert.Equal(t, "", result)
}

// --- Reattach ---

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

// --- Upsert ID generation ---

func TestUpsertGeneratesEightCharHexIDForNewComment(t *testing.T) {
	comments := []Comment{}
	comment := Comment{Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "fix"}

	result, err := Upsert(comments, comment, "abc123")
	require.NoError(t, err)

	require.Len(t, result, 1)
	assert.Regexp(t, hexPattern, result[0].ID)
}

func TestUpsertPreservesExistingIDOnUpdate(t *testing.T) {
	comments := []Comment{
		{ID: "deadbeef", Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "old", CommitHash: "abc123"},
	}
	updated := Comment{Filepath: "/a.go", LineNumber: 5, LineContent: "changed", Review: "new"}

	result, err := Upsert(comments, updated, "def456")
	require.NoError(t, err)

	require.Len(t, result, 1)
	assert.Equal(t, "deadbeef", result[0].ID)
}

func TestUpsertProducesDifferentIDsForConsecutiveCalls(t *testing.T) {
	var err error
	comments := []Comment{}
	first := Comment{Filepath: "/a.go", LineNumber: 1, LineContent: "line1", Review: "r1"}
	second := Comment{Filepath: "/b.go", LineNumber: 2, LineContent: "line2", Review: "r2"}

	comments, err = Upsert(comments, first, "abc")
	require.NoError(t, err)
	comments, err = Upsert(comments, second, "abc")
	require.NoError(t, err)

	require.Len(t, comments, 2)
	assert.NotEqual(t, comments[0].ID, comments[1].ID)
}

// --- Upsert commit hash ---

func TestUpsertStoresCommitHashOnNewComment(t *testing.T) {
	comments := []Comment{}
	comment := Comment{Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "fix"}

	result, err := Upsert(comments, comment, "abc123def")
	require.NoError(t, err)

	require.Len(t, result, 1)
	assert.Equal(t, "abc123def", result[0].CommitHash)
}

func TestUpsertPreservesExistingCommitHashOnUpdate(t *testing.T) {
	comments := []Comment{
		{ID: "deadbeef", Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "old", CommitHash: "original"},
	}
	updated := Comment{Filepath: "/a.go", LineNumber: 5, LineContent: "changed", Review: "new"}

	result, err := Upsert(comments, updated, "newhead")
	require.NoError(t, err)

	require.Len(t, result, 1)
	assert.Equal(t, "original", result[0].CommitHash)
}

// --- Persistence with ID and CommitHash ---

func TestSaveWritesIDAndCommitHashToJSON(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "comments.json")
	input := []Comment{
		{ID: "aabbccdd", Filepath: "/a.go", LineNumber: 5, LineContent: "hello", Review: "fix", CommitHash: "abc123"},
	}

	err := Save(path, input)
	require.NoError(t, err)

	raw, err := os.ReadFile(path)
	require.NoError(t, err)

	var parsed []map[string]interface{}
	require.NoError(t, json.Unmarshal(raw, &parsed))
	require.Len(t, parsed, 1)
	assert.Equal(t, "aabbccdd", parsed[0]["id"])
	assert.Equal(t, "abc123", parsed[0]["commitHash"])
}

func TestLoadReadsIDAndCommitHashFromJSON(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "comments.json")
	data := `[{"id":"aabbccdd","filepath":"/a.go","lineNumber":5,"lineContent":"hello","review":"fix","commitHash":"abc123"}]`
	require.NoError(t, os.WriteFile(path, []byte(data), 0o644))

	comments, err := Load(path)
	require.NoError(t, err)
	require.Len(t, comments, 1)
	assert.Equal(t, "aabbccdd", comments[0].ID)
	assert.Equal(t, "abc123", comments[0].CommitHash)
}

func TestLoadHandlesJSONWithoutIDAndCommitHash(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "comments.json")
	data := `[{"filepath":"/a.go","lineNumber":5,"lineContent":"hello","review":"fix"}]`
	require.NoError(t, os.WriteFile(path, []byte(data), 0o644))

	comments, err := Load(path)
	require.NoError(t, err)
	require.Len(t, comments, 1)
	assert.Equal(t, "", comments[0].ID)
	assert.Equal(t, "", comments[0].CommitHash)
}
