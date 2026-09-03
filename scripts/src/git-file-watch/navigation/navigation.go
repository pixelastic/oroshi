package navigation

import "sort"

// State tracks cursor position and viewport offset.
type State struct {
	Cursor         int
	ViewportOffset int
	ViewportHeight int
	RowCount       int
}

// FileIndex groups file header positions, paths, and fold state for navigation.
type FileIndex struct {
	Headers   []int
	Paths     []string
	FoldState map[string]bool
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

// NextFile jumps the cursor to the first navigable line of the next file.
func NextFile(state State, index FileIndex, navigableIndices []int, visibleIndices []int) State {
	for i, headerIndex := range index.Headers {
		if headerIndex > state.Cursor {
			nextHeader := -1
			if i+1 < len(index.Headers) {
				nextHeader = index.Headers[i+1]
			}
			target := firstNavigableBetween(headerIndex, nextHeader, navigableIndices)
			if target < 0 {
				continue
			}
			state.Cursor = target
			return clampViewportForIndices(state, visibleIndices)
		}
	}
	return state
}

// PrevFile jumps the cursor to the first navigable line of the previous file.
func PrevFile(state State, index FileIndex, navigableIndices []int, visibleIndices []int) State {
	fileIdx := currentFile(state.Cursor, index.Headers)
	for i := fileIdx - 1; i >= 0; i-- {
		nextHeader := -1
		if i+1 < len(index.Headers) {
			nextHeader = index.Headers[i+1]
		}
		target := firstNavigableBetween(index.Headers[i], nextHeader, navigableIndices)
		if target < 0 {
			continue
		}
		state.Cursor = target
		return clampViewportForIndices(state, visibleIndices)
	}
	return state
}

// firstNavigableBetween returns the first navigable index after headerIndex
// and before endIndex (-1 means no upper bound).
func firstNavigableBetween(headerIndex int, endIndex int, navigableIndices []int) int {
	pos := sort.SearchInts(navigableIndices, headerIndex+1)
	if pos >= len(navigableIndices) {
		return -1
	}
	candidate := navigableIndices[pos]
	if endIndex >= 0 && candidate >= endIndex {
		return -1
	}
	return candidate
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
func VisibleIndices(rowCount int, index FileIndex) []int {
	hidden := make(map[int]bool)
	for i, headerIndex := range index.Headers {
		if !index.FoldState[index.Paths[i]] {
			continue
		}
		endIndex := rowCount
		if i+1 < len(index.Headers) {
			endIndex = index.Headers[i+1]
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
func ToggleFold(state State, index FileIndex) (State, FileIndex) {
	filePos := currentFile(state.Cursor, index.Headers)
	if filePos < 0 || filePos >= len(index.Paths) {
		return state, index
	}

	path := index.Paths[filePos]
	if index.FoldState[path] {
		delete(index.FoldState, path)
		return state, index
	}

	index.FoldState[path] = true
	state.Cursor = index.Headers[filePos]
	state = clampViewport(state)
	return state, index
}

// MoveDownVisible moves the cursor to the next navigable row, scrolling the viewport using visible indices.
func MoveDownVisible(state State, navigableIndices []int, visibleIndices []int) State {
	if len(navigableIndices) == 0 {
		return state
	}

	pos := sort.SearchInts(navigableIndices, state.Cursor+1)
	if pos >= len(navigableIndices) {
		return state
	}

	state.Cursor = navigableIndices[pos]
	return clampViewportVisible(state, visibleIndices)
}

// MoveUpVisible moves the cursor to the previous navigable row, scrolling the viewport using visible indices.
func MoveUpVisible(state State, navigableIndices []int, visibleIndices []int) State {
	if len(navigableIndices) == 0 {
		return state
	}

	pos := sort.SearchInts(navigableIndices, state.Cursor) - 1
	if pos < 0 {
		return state
	}

	state.Cursor = navigableIndices[pos]
	return clampViewportVisible(state, visibleIndices)
}

// GoToTop moves the cursor to the first navigable row and scrolls viewport to the top.
func GoToTop(state State, navigableIndices []int, visibleIndices []int) State {
	if len(navigableIndices) == 0 {
		return state
	}
	state.Cursor = navigableIndices[0]
	if len(visibleIndices) > 0 {
		state.ViewportOffset = visibleIndices[0]
	}
	return state
}

// GoToBottom moves the cursor to the last navigable row.
func GoToBottom(state State, navigableIndices []int, visibleIndices []int) State {
	if len(navigableIndices) == 0 {
		return state
	}
	state.Cursor = navigableIndices[len(navigableIndices)-1]
	return clampViewportVisible(state, visibleIndices)
}

// FirstMarkedRow returns the index of the first row that has a marker.
// Returns 0 if no marked rows exist.
func FirstMarkedRow(rowCount int, markedRows map[int]bool) int {
	for i := 0; i < rowCount; i++ {
		if markedRows[i] {
			return i
		}
	}
	return 0
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
