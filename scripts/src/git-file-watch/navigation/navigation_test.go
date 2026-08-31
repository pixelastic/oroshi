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
	headers := []int{0, 8, 15}
	result := NextFileHeader(state, headers)
	assert.Equal(t, 8, result.Cursor)
}

func TestPrevFileHeaderJumpsToPreviousFile(t *testing.T) {
	state := State{Cursor: 10, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	headers := []int{0, 8, 15}
	result := PrevFileHeader(state, headers)
	assert.Equal(t, 0, result.Cursor)
}

func TestNextFileHeaderAtLastFileDoesNotMove(t *testing.T) {
	state := State{Cursor: 16, ViewportOffset: 10, ViewportHeight: 10, RowCount: 20}
	headers := []int{0, 8, 15}
	result := NextFileHeader(state, headers)
	assert.Equal(t, 16, result.Cursor)
}

func TestPrevFileHeaderAtFirstFileDoesNotMove(t *testing.T) {
	state := State{Cursor: 3, ViewportOffset: 0, ViewportHeight: 10, RowCount: 20}
	headers := []int{0, 8, 15}
	result := PrevFileHeader(state, headers)
	assert.Equal(t, 3, result.Cursor)
}
