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

func TestNextFileLandsOnFirstCodeLineOfNextFile(t *testing.T) {
	state := State{Cursor: 1, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	// navigable: all except headers 0, 8, 15
	navigable := []int{1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19}
	result := NextFile(state, index, navigable, nil)
	// Should land on 9 (first code line after header at 8)
	assert.Equal(t, 9, result.Cursor)
}

func TestPrevFileLandsOnFirstCodeLineOfPrevFile(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	navigable := []int{1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19}
	result := PrevFile(state, index, navigable, nil)
	// Should land on 1 (first code line after header at 0)
	assert.Equal(t, 1, result.Cursor)
}

func TestNextFileScrollsViewportToShowFileHeader(t *testing.T) {
	state := State{Cursor: 1, ViewportOffset: 0, ViewportHeight: 5, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	navigable := []int{1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}

	result := NextFile(state, index, navigable, visible)

	assert.Equal(t, 9, result.Cursor)
	// Viewport should start at the file header (8), not the cursor (9)
	assert.Equal(t, 8, result.ViewportOffset)
}

func TestPrevFileScrollsViewportToShowFileHeader(t *testing.T) {
	state := State{Cursor: 16, ViewportOffset: 15, ViewportHeight: 5, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	navigable := []int{1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}

	result := PrevFile(state, index, navigable, visible)

	// From file c (header 15), should go to file b (header 8, first code line 9)
	assert.Equal(t, 9, result.Cursor)
	assert.Equal(t, 8, result.ViewportOffset)
}

func TestNextFileAtLastFileDoesNotMove(t *testing.T) {
	state := State{Cursor: 16, ViewportOffset: 10, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	navigable := []int{1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19}
	result := NextFile(state, index, navigable, nil)
	assert.Equal(t, 16, result.Cursor)
}

func TestPrevFileAtFirstFileDoesNotMove(t *testing.T) {
	state := State{Cursor: 3, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	index := FileIndex{Headers: []int{0, 8, 15}}
	navigable := []int{1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19}
	result := PrevFile(state, index, navigable, nil)
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

func TestFoldingDoesNotScrollViewportWhenHeaderAlreadyVisible(t *testing.T) {
	// Two files: a (header 0, folded) and b (header 5, open)
	// Viewport starts at 0 with height 10 → shows rows 0..9
	// Cursor on line 8 of file b, header at 5 is visible
	// Folding file b should move cursor to header 5, viewport stays at 0
	state := State{Cursor: 8, ViewportOffset: 0, ViewportHeight: 10, RowCount: 10}
	index := FileIndex{
		Headers:   []int{0, 5},
		Paths:     []string{"a.go", "b.go"},
		FoldState: map[string]bool{"a.go": true},
	}

	newState, _ := ToggleFold(state, index)

	assert.Equal(t, 5, newState.Cursor)
	assert.Equal(t, 0, newState.ViewportOffset)
}

func TestFoldingScrollsViewportWhenHeaderAboveViewport(t *testing.T) {
	// Cursor on line 8 in file b, but viewport scrolled down past file b's header
	state := State{Cursor: 8, ViewportOffset: 7, ViewportHeight: 3, RowCount: 10}
	index := FileIndex{
		Headers:   []int{0, 5},
		Paths:     []string{"a.go", "b.go"},
		FoldState: map[string]bool{},
	}

	newState, _ := ToggleFold(state, index)

	// Cursor moves to header 5, viewport must scroll to show it
	assert.Equal(t, 5, newState.Cursor)
	assert.True(t, newState.ViewportOffset <= 5)
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

func TestNextFileJumpsToFirstCodeLineOfFoldedFile(t *testing.T) {
	state := State{Cursor: 3, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{Headers: []int{0, 5, 10}}
	// File b (header at 5) is folded — only header visible, no code lines for file b
	// navigable: code lines only (no headers, no folded content)
	navigable := []int{1, 2, 3, 4, 11, 12, 13, 14}
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	result := NextFile(state, index, navigable, visible)
	// File b is folded so no navigable lines — should skip to file c's first code line (11)
	assert.Equal(t, 11, result.Cursor)
}

func TestPrevFileJumpsToFirstCodeLineOfPrevFile(t *testing.T) {
	state := State{Cursor: 11, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	index := FileIndex{Headers: []int{0, 5, 10}}
	// File b is folded
	navigable := []int{1, 2, 3, 4, 11, 12, 13, 14}
	visible := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	result := PrevFile(state, index, navigable, visible)
	// Should skip folded file b and land on first code line of file a (1)
	assert.Equal(t, 1, result.Cursor)
}

func TestMoveDownVisibleSkipsFoldedContent(t *testing.T) {
	state := State{Cursor: 5, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	navigable := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	visible := navigable

	result := MoveDownVisible(state, navigable, visible)

	assert.Equal(t, 10, result.Cursor)
}

func TestMoveUpVisibleSkipsFoldedContent(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 0, ViewportHeight: 20, RowCount: 15}
	navigable := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	visible := navigable

	result := MoveUpVisible(state, navigable, visible)

	assert.Equal(t, 5, result.Cursor)
}

func TestMoveDownVisibleAtLastRowDoesNotMove(t *testing.T) {
	state := State{Cursor: 14, ViewportOffset: 10, ViewportHeight: 10, RowCount: 15}
	navigable := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	visible := navigable

	result := MoveDownVisible(state, navigable, visible)

	assert.Equal(t, 14, result.Cursor)
}

func TestMoveUpVisibleAtFirstRowDoesNotMove(t *testing.T) {
	state := State{Cursor: 0, ViewportOffset: 0, ViewportHeight: 10, RowCount: 15}
	navigable := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	visible := navigable

	result := MoveUpVisible(state, navigable, visible)

	assert.Equal(t, 0, result.Cursor)
}

func TestMoveDownVisibleScrollsViewport(t *testing.T) {
	state := State{Cursor: 4, ViewportOffset: 2, ViewportHeight: 3, RowCount: 15}
	navigable := []int{0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14}
	visible := navigable

	result := MoveDownVisible(state, navigable, visible)

	assert.Equal(t, 5, result.Cursor)
	assert.Equal(t, 3, result.ViewportOffset)
}

func TestMoveDownVisibleSkipsHeaderRow(t *testing.T) {
	state := State{Cursor: 1, ViewportOffset: 0, ViewportHeight: 20, RowCount: 6}
	// rows: header(0), line(1), header(2), line(3), line(4), line(5)
	navigable := []int{1, 3, 4, 5}
	visible := []int{0, 1, 2, 3, 4, 5}

	result := MoveDownVisible(state, navigable, visible)

	assert.Equal(t, 3, result.Cursor)
}

func TestMoveUpVisibleSkipsHeaderRow(t *testing.T) {
	state := State{Cursor: 3, ViewportOffset: 0, ViewportHeight: 20, RowCount: 6}
	navigable := []int{1, 3, 4, 5}
	visible := []int{0, 1, 2, 3, 4, 5}

	result := MoveUpVisible(state, navigable, visible)

	assert.Equal(t, 1, result.Cursor)
}

// --- GoToTop / GoToBottom ---

func TestGoToTopMovesCursorToFirstNavigableRow(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 5, ViewportHeight: 10, RowCount: 20}
	navigable := []int{1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}

	result := GoToTop(state, navigable, visible)

	assert.Equal(t, 1, result.Cursor)
	assert.Equal(t, 0, result.ViewportOffset)
}

func TestGoToTopAtTopDoesNotMove(t *testing.T) {
	state := State{Cursor: 1, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	navigable := []int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

	result := GoToTop(state, navigable, visible)

	assert.Equal(t, 1, result.Cursor)
}

func TestGoToTopScrollsViewportToShowFileHeader(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 8, ViewportHeight: 5, RowCount: 15}
	navigable := []int{1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}

	result := GoToTop(state, navigable, visible)

	assert.Equal(t, 1, result.Cursor)
	assert.Equal(t, 0, result.ViewportOffset)
}

func TestGoToBottomMovesCursorToLastNavigableRow(t *testing.T) {
	state := State{Cursor: 1, ViewportOffset: 0, ViewportHeight: 10, RowCount: 15}
	navigable := []int{1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}

	result := GoToBottom(state, navigable, visible)

	assert.Equal(t, 14, result.Cursor)
}

func TestGoToBottomAtBottomDoesNotMove(t *testing.T) {
	state := State{Cursor: 14, ViewportOffset: 5, ViewportHeight: 10, RowCount: 15}
	navigable := []int{1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}

	result := GoToBottom(state, navigable, visible)

	assert.Equal(t, 14, result.Cursor)
}

func TestGoToBottomScrollsViewport(t *testing.T) {
	state := State{Cursor: 1, ViewportOffset: 0, ViewportHeight: 5, RowCount: 15}
	navigable := []int{1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14}
	visible := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}

	result := GoToBottom(state, navigable, visible)

	assert.Equal(t, 14, result.Cursor)
	assert.True(t, result.ViewportOffset > 0)
}

// --- FirstMarkedRow ---

func TestFirstMarkedRowReturnsFirstMarkedIndex(t *testing.T) {
	marked := map[int]bool{2: true, 4: true}

	result := FirstMarkedRow(5, marked)

	assert.Equal(t, 2, result)
}

func TestFirstMarkedRowReturnsZeroWhenNoMarks(t *testing.T) {
	result := FirstMarkedRow(5, map[int]bool{})

	assert.Equal(t, 0, result)
}

func TestFirstMarkedRowReturnsZeroWhenNilMap(t *testing.T) {
	result := FirstMarkedRow(5, nil)

	assert.Equal(t, 0, result)
}
