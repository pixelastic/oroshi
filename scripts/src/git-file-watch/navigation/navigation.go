package navigation

import "sort"

// State tracks cursor position and viewport offset.
type State struct {
	Cursor         int
	ViewportOffset int
	ViewportHeight int
	RowCount       int
}

// MoveDown moves the cursor down one row, scrolling the viewport if needed.
func MoveDown(state State) State {
	if state.Cursor >= state.RowCount-1 {
		return state
	}
	state.Cursor++
	if state.Cursor >= state.ViewportOffset+state.ViewportHeight {
		state.ViewportOffset = state.Cursor - state.ViewportHeight + 1
	}
	return state
}

// MoveUp moves the cursor up one row, scrolling the viewport if needed.
func MoveUp(state State) State {
	if state.Cursor <= 0 {
		return state
	}
	state.Cursor--
	if state.Cursor < state.ViewportOffset {
		state.ViewportOffset = state.Cursor
	}
	return state
}

// NextFileHeader jumps the cursor to the next file header after the current position.
func NextFileHeader(state State, fileHeaderIndices []int, visibleIndices []int) State {
	for _, index := range fileHeaderIndices {
		if index > state.Cursor {
			state.Cursor = index
			return clampViewportForIndices(state, visibleIndices)
		}
	}
	return state
}

// PrevFileHeader jumps the cursor to the header of the file before the current one.
func PrevFileHeader(state State, fileHeaderIndices []int, visibleIndices []int) State {
	currentFileIndex := currentFile(state.Cursor, fileHeaderIndices)
	if currentFileIndex <= 0 {
		return state
	}
	state.Cursor = fileHeaderIndices[currentFileIndex-1]
	return clampViewportForIndices(state, visibleIndices)
}

func clampViewportForIndices(state State, visibleIndices []int) State {
	if len(visibleIndices) > 0 {
		return clampViewportVisible(state, visibleIndices)
	}
	return clampViewport(state)
}

func currentFile(cursor int, fileHeaderIndices []int) int {
	result := -1
	for i, index := range fileHeaderIndices {
		if index > cursor {
			break
		}
		result = i
	}
	return result
}

func clampViewport(state State) State {
	if state.Cursor < state.ViewportOffset {
		state.ViewportOffset = state.Cursor
	}
	if state.Cursor >= state.ViewportOffset+state.ViewportHeight {
		state.ViewportOffset = state.Cursor - state.ViewportHeight + 1
	}
	return state
}

// VisibleIndices returns sorted indices of rows not hidden by fold state.
// Folded files show only their header row; all content rows are hidden.
func VisibleIndices(rowCount int, fileHeaderIndices []int, filePaths []string, foldState map[string]bool) []int {
	hidden := make(map[int]bool)
	for i, headerIndex := range fileHeaderIndices {
		if !foldState[filePaths[i]] {
			continue
		}
		endIndex := rowCount
		if i+1 < len(fileHeaderIndices) {
			endIndex = fileHeaderIndices[i+1]
		}
		for row := headerIndex + 1; row < endIndex; row++ {
			hidden[row] = true
		}
	}

	visible := make([]int, 0, rowCount-len(hidden))
	for i := 0; i < rowCount; i++ {
		if !hidden[i] {
			visible = append(visible, i)
		}
	}
	return visible
}

// ToggleFold toggles the fold state for the file at the cursor position.
// When folding, the cursor moves to the file header.
func ToggleFold(state State, fileHeaderIndices []int, filePaths []string, foldState map[string]bool) (State, map[string]bool) {
	fileIndex := currentFile(state.Cursor, fileHeaderIndices)
	if fileIndex < 0 || fileIndex >= len(filePaths) {
		return state, foldState
	}

	path := filePaths[fileIndex]
	if foldState[path] {
		delete(foldState, path)
		return state, foldState
	}

	foldState[path] = true
	state.Cursor = fileHeaderIndices[fileIndex]
	state = clampViewport(state)
	return state, foldState
}

// MoveDownVisible moves the cursor to the next visible row, scrolling if needed.
func MoveDownVisible(state State, visibleIndices []int) State {
	if len(visibleIndices) == 0 {
		return state
	}

	pos := sort.SearchInts(visibleIndices, state.Cursor+1)
	if pos >= len(visibleIndices) {
		return state
	}

	state.Cursor = visibleIndices[pos]
	return clampViewportVisible(state, visibleIndices)
}

// MoveUpVisible moves the cursor to the previous visible row, scrolling if needed.
func MoveUpVisible(state State, visibleIndices []int) State {
	if len(visibleIndices) == 0 {
		return state
	}

	pos := sort.SearchInts(visibleIndices, state.Cursor) - 1
	if pos < 0 {
		return state
	}

	state.Cursor = visibleIndices[pos]
	return clampViewportVisible(state, visibleIndices)
}

func clampViewportVisible(state State, visibleIndices []int) State {
	if state.Cursor < state.ViewportOffset {
		state.ViewportOffset = state.Cursor
		return state
	}

	viewportStart := sort.SearchInts(visibleIndices, state.ViewportOffset)
	cursorPos := sort.SearchInts(visibleIndices, state.Cursor)
	if cursorPos >= len(visibleIndices) || visibleIndices[cursorPos] != state.Cursor {
		return state
	}

	count := cursorPos - viewportStart + 1
	if count > state.ViewportHeight {
		newStart := cursorPos - state.ViewportHeight + 1
		if newStart < 0 {
			newStart = 0
		}
		state.ViewportOffset = visibleIndices[newStart]
	}
	return state
}
