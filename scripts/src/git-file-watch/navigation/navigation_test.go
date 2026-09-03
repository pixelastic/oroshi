package navigation

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// --- Line scrolling ---

func TestMoveDownMovesOneRow(t *testing.T) {
	state := State{Cursor: 0, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	result := MoveDown(state)
	assert.Equal(t, 1, result.Cursor)
}

func TestMoveUpMovesOneRow(t *testing.T) {
	state := State{Cursor: 5, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	result := MoveUp(state)
	assert.Equal(t, 4, result.Cursor)
}

func TestMoveDownAtLastRowDoesNotMove(t *testing.T) {
	state := State{Cursor: 19, ViewportOffset: 10, ViewportHeight: 10, RowCount: 20}
	result := MoveDown(state)
	assert.Equal(t, 19, result.Cursor)
}

func TestMoveUpAtFirstRowDoesNotMove(t *testing.T) {
	state := State{Cursor: 0, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	result := MoveUp(state)
	assert.Equal(t, 0, result.Cursor)
}

func TestViewportScrollsWhenCursorPassesBottomEdge(t *testing.T) {
	state := State{Cursor: 9, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	result := MoveDown(state)
	assert.Equal(t, 10, result.Cursor)
	assert.Equal(t, 1, result.ViewportOffset)
}

func TestViewportScrollsWhenCursorPassesTopEdge(t *testing.T) {
	state := State{Cursor: 5, ViewportOffset: 5, ViewportHeight: 10, RowCount: 20}
	result := MoveUp(state)
	assert.Equal(t, 4, result.Cursor)
	assert.Equal(t, 4, result.ViewportOffset)
}

// --- File jumping ---

func TestNextFileHeaderJumpsToNextFile(t *testing.T) {
	state := State{Cursor: 0, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	result := NextFileHeader(state, index, nil)
	assert.Equal(t, 8, result.Cursor)
}

func TestPrevFileHeaderJumpsToPreviousFile(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	result := PrevFileHeader(state, index, nil)
	assert.Equal(t, 0, result.Cursor)
}

func TestNextFileHeaderAtLastFileDoesNotMove(t *testing.T) {
	state := State{Cursor: 16, ViewportOffset: 10, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	result := NextFileHeader(state, index, nil)
	assert.Equal(t, 16, result.Cursor)
}

func TestPrevFileHeaderAtFirstFileDoesNotMove(t *testing.T) {
	state := State{Cursor: 3, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	result := PrevFileHeader(state, index, nil)
	assert.Equal(t, 3, result.Cursor)
}

// --- Visible indices ---

func TestVisibleIndicesAllRowsVisibleWhenNothingFolded(t *testing.T) {
	index := FileIndex{
		Headers:   []int{0, 5, 10},
		Paths:     []string{"a.go", "b.go", "c.go"},
		FoldState: map[string]bool{},
	}

	result := VisibleIndices(15, index)

	expected := make([]int, 15)
	for i := range expected {
		expected[i] = i
	}
	assert.Equal(t, expected, result)
}

func TestVisibleIndicesFoldedFileShowsHeaderOnly(t *testing.T) {
	index := FileIndex{
		Headers:   []int{0, 5, 10},
		Paths:     []string{"a.go", "b.go", "c.go"},
		FoldState: map[string]bool{"b.go": true},
	}

	result := VisibleIndices(15, index)

	expected := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	assert.Equal(t, expected, result)
}

func TestVisibleIndicesUnfoldedFileShowsAllRows(t *testing.T) {
	index := FileIndex{
		Headers:   []int{0, 5, 10},
		Paths:     []string{"a.go", "b.go", "c.go"},
		FoldState: map[string]bool{"b.go": false},
	}

	result := VisibleIndices(15, index)

	expected := make([]int, 15)
	for i := range expected {
		expected[i] = i
	}
	assert.Equal(t, expected, result)
}

// --- Fold toggle ---

func TestToggleFoldOnUnfoldedFileFoldsIt(t *testing.T) {
	state := State{Cursor: 7, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{
		Headers:   []int{0, 5, 10},
		Paths:     []string{"a.go", "b.go", "c.go"},
		FoldState: map[string]bool{},
	}

	_, newIndex := ToggleFold(state, index)

	assert.True(t, newIndex.FoldState["b.go"])
}

func TestToggleFoldOnFoldedFileUnfoldsIt(t *testing.T) {
	state := State{Cursor: 5, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{
		Headers:   []int{0, 5, 10},
		Paths:     []string{"a.go", "b.go", "c.go"},
		FoldState: map[string]bool{"b.go": true},
	}

	_, newIndex := ToggleFold(state, index)

	assert.False(t, newIndex.FoldState["b.go"])
}

func TestFoldingMovesCursorToFileHeader(t *testing.T) {
	state := State{Cursor: 7, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{
		Headers:   []int{0, 5, 10},
		Paths:     []string{"a.go", "b.go", "c.go"},
		FoldState: map[string]bool{},
	}

	newState, _ := ToggleFold(state, index)

	assert.Equal(t, 5, newState.Cursor)
}

func TestUnfoldingKeepsCursorOnHeader(t *testing.T) {
	state := State{Cursor: 5, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{
		Headers:   []int{0, 5, 10},
		Paths:     []string{"a.go", "b.go", "c.go"},
		FoldState: map[string]bool{"b.go": true},
	}

	newState, _ := ToggleFold(state, index)

	assert.Equal(t, 5, newState.Cursor)
}

// --- Navigation with folds ---

func TestNextFileHeaderJumpsToFoldedFileHeader(t *testing.T) {
	state := State{Cursor: 3, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{Headers: []int{0, 5, 10}}
	// File b (header at 5) is folded — l should still jump there
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	result := NextFileHeader(state, index, visible)
	assert.Equal(t, 5, result.Cursor)
}

func TestPrevFileHeaderJumpsToFoldedFileHeader(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{Headers: []int{0, 5, 10}}
	// File b (header at 5) is folded — h should still jump there
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	result := PrevFileHeader(state, index, visible)
	assert.Equal(t, 5, result.Cursor)
}

func TestMoveDownVisibleSkipsFoldedContent(t *testing.T) {
	state := State{Cursor: 5, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}

	result := MoveDownVisible(state, visible)

	assert.Equal(t, 10, result.Cursor)
}

func TestMoveUpVisibleSkipsFoldedContent(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}

	result := MoveUpVisible(state, visible)

	assert.Equal(t, 5, result.Cursor)
}

func TestMoveDownVisibleAtLastRowDoesNotMove(t *testing.T) {
	state := State{Cursor: 14, ViewportOffset: 10, ViewportHeight: 10, RowCount: 15}
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}

	result := MoveDownVisible(state, visible)

	assert.Equal(t, 14, result.Cursor)
}

func TestMoveUpVisibleAtFirstRowDoesNotMove(t *testing.T) {
	state := State{Cursor: 0, ViewportOffset: 0, ViewportHeight: 10, RowCount: 15}
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}

	result := MoveUpVisible(state, visible)

	assert.Equal(t, 0, result.Cursor)
}

func TestMoveDownVisibleScrollsViewport(t *testing.T) {
	state := State{Cursor: 4, ViewportOffset: 2, ViewportHeight: 3, RowCount: 15}
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}

	result := MoveDownVisible(state, visible)

	assert.Equal(t, 5, result.Cursor)
	assert.Equal(t, 3, result.ViewportOffset)
}
