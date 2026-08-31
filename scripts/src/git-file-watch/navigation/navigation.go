package navigation

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
func NextFileHeader(state State, fileHeaderIndices []int) State {
	for _, index := range fileHeaderIndices {
		if index > state.Cursor {
			state.Cursor = index
			state = clampViewport(state)
			return state
		}
	}
	return state
}

// PrevFileHeader jumps the cursor to the header of the file before the current one.
func PrevFileHeader(state State, fileHeaderIndices []int) State {
	currentFileIndex := currentFile(state.Cursor, fileHeaderIndices)
	if currentFileIndex <= 0 {
		return state
	}
	state.Cursor = fileHeaderIndices[currentFileIndex-1]
	state = clampViewport(state)
	return state
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
