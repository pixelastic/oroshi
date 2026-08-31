package editing

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// --- Open ---

func TestOpenCreatesActiveState(t *testing.T) {
	state := Open("/a.go", 5, "hello", "", 3)

	assert.True(t, state.Active)
	assert.Equal(t, "/a.go", state.FilePath)
	assert.Equal(t, 5, state.LineNumber)
	assert.Equal(t, "hello", state.LineContent)
	assert.Equal(t, "", state.OriginalText)
	assert.Equal(t, 3, state.RowIndex)
}

func TestOpenPreFillsExistingReview(t *testing.T) {
	state := Open("/a.go", 5, "hello", "fix this", 3)

	assert.Equal(t, "fix this", state.OriginalText)
}

// --- Save ---

func TestSaveReturnsCommentData(t *testing.T) {
	state := Open("/a.go", 5, "hello", "", 3)

	result := Save(state, "needs refactoring")

	assert.Equal(t, "/a.go", result.FilePath)
	assert.Equal(t, 5, result.LineNumber)
	assert.Equal(t, "hello", result.LineContent)
	assert.Equal(t, "needs refactoring", result.Text)
	assert.False(t, result.IsEmpty)
}

func TestSaveWithEmptyTextSignalsDeletion(t *testing.T) {
	state := Open("/a.go", 5, "hello", "old review", 3)

	result := Save(state, "")

	assert.True(t, result.IsEmpty)
}

func TestSaveTrimsWhitespace(t *testing.T) {
	state := Open("/a.go", 5, "hello", "", 3)

	result := Save(state, "  text  \n  ")

	assert.Equal(t, "text", result.Text)
	assert.False(t, result.IsEmpty)
}

func TestSaveWithWhitespaceOnlySignalsDeletion(t *testing.T) {
	state := Open("/a.go", 5, "hello", "", 3)

	result := Save(state, "   \n  ")

	assert.True(t, result.IsEmpty)
}

// --- Inactive ---

func TestInactiveReturnsInactiveState(t *testing.T) {
	state := Inactive()

	assert.False(t, state.Active)
}
