package navigation

import (
	"path/filepath"
	"sort"
	"strings"
)

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

// ViewContext bundles the indices that navigation functions need.
type ViewContext struct {
	Navigable   []int
	Visible     []int
	Headers     []int
	CommentRows map[int]bool
	WrapCosts   map[int]int
}

// NextFile jumps the cursor to the first navigable line of the next file.
// The viewport scrolls to show the file header at the top.
func NextFile(state State, index FileIndex, vc ViewContext) State {
	for i, headerIndex := range index.Headers {
		if headerIndex > state.Cursor {
			nextHeader := -1
			if i+1 < len(index.Headers) {
				nextHeader = index.Headers[i+1]
			}
			target := firstNavigableBetween(headerIndex, nextHeader, vc.Navigable)
			if target < 0 {
				continue
			}
			state.Cursor = target
			state.ViewportOffset = headerIndex
			return state
		}
	}
	return state
}

// PrevFile jumps the cursor to the first navigable line of the previous file.
// The viewport scrolls to show the file header at the top.
func PrevFile(state State, index FileIndex, vc ViewContext) State {
	fileIdx := currentFile(state.Cursor, index.Headers)
	for i := fileIdx - 1; i >= 0; i-- {
		nextHeader := -1
		if i+1 < len(index.Headers) {
			nextHeader = index.Headers[i+1]
		}
		target := firstNavigableBetween(index.Headers[i], nextHeader, vc.Navigable)
		if target < 0 {
			continue
		}
		state.Cursor = target
		state.ViewportOffset = index.Headers[i]
		return state
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
// When folding, the cursor moves to the file header and folded is true.
// When unfolding, the cursor stays on the header and folded is false.
func ToggleFold(state State, index FileIndex) (State, FileIndex, bool) {
	filePos := currentFile(state.Cursor, index.Headers)
	if filePos < 0 || filePos >= len(index.Paths) {
		return state, index, false
	}

	path := index.Paths[filePos]
	if index.FoldState[path] {
		delete(index.FoldState, path)
		return state, index, false
	}

	index.FoldState[path] = true
	state.Cursor = index.Headers[filePos]
	// After folding, fewer rows are visible. Scroll up to fill the viewport.
	visibleCount := len(VisibleIndices(state.RowCount, index))
	if visibleCount <= state.ViewportHeight {
		state.ViewportOffset = 0
	} else {
		state = clampViewport(state)
	}
	return state, index, true
}

// MoveDownVisible moves the cursor to the next navigable row, scrolling the viewport using visible indices.
func MoveDownVisible(state State, vc ViewContext) State {
	if len(vc.Navigable) == 0 {
		return state
	}

	pos := sort.SearchInts(vc.Navigable, state.Cursor+1)
	if pos >= len(vc.Navigable) {
		return state
	}

	state.Cursor = vc.Navigable[pos]
	return clampViewportVisible(state, vc)
}

// MoveUpVisible moves the cursor to the previous navigable row, scrolling the viewport using visible indices.
func MoveUpVisible(state State, vc ViewContext) State {
	if len(vc.Navigable) == 0 {
		return state
	}

	pos := sort.SearchInts(vc.Navigable, state.Cursor) - 1
	if pos < 0 {
		// Cursor can't move, but scroll viewport up if there's visible content above
		if len(vc.Visible) > 0 && state.ViewportOffset > vc.Visible[0] {
			state.ViewportOffset = vc.Visible[0]
		}
		return state
	}

	state.Cursor = vc.Navigable[pos]
	return clampViewportVisible(state, vc)
}

// GoToTop moves the cursor to the first navigable row and scrolls viewport to the top.
func GoToTop(state State, vc ViewContext) State {
	if len(vc.Navigable) == 0 {
		return state
	}
	state.Cursor = vc.Navigable[0]
	if len(vc.Visible) > 0 {
		state.ViewportOffset = vc.Visible[0]
	}
	return state
}

// GoToBottom moves the cursor to the last navigable row.
func GoToBottom(state State, vc ViewContext) State {
	if len(vc.Navigable) == 0 {
		return state
	}
	state.Cursor = vc.Navigable[len(vc.Navigable)-1]
	return clampViewportVisible(state, vc)
}

// PageDown moves the cursor down by half a viewport height within visible rows.
func PageDown(state State, vc ViewContext) State {
	if len(vc.Navigable) == 0 || len(vc.Visible) == 0 {
		return state
	}

	visPos := sort.SearchInts(vc.Visible, state.Cursor)
	targetVisPos := visPos + state.ViewportHeight/2
	if targetVisPos >= len(vc.Visible) {
		targetVisPos = len(vc.Visible) - 1
	}
	targetRow := vc.Visible[targetVisPos]

	navPos := sort.SearchInts(vc.Navigable, targetRow)
	if navPos >= len(vc.Navigable) {
		navPos = len(vc.Navigable) - 1
	}
	state.Cursor = vc.Navigable[navPos]
	return centerViewportOnCursor(state, vc)
}

// PageUp moves the cursor up by half a viewport height within visible rows.
func PageUp(state State, vc ViewContext) State {
	if len(vc.Navigable) == 0 || len(vc.Visible) == 0 {
		return state
	}

	visPos := sort.SearchInts(vc.Visible, state.Cursor)
	targetVisPos := visPos - state.ViewportHeight/2
	if targetVisPos < 0 {
		targetVisPos = 0
	}
	targetRow := vc.Visible[targetVisPos]

	navPos := sort.SearchInts(vc.Navigable, targetRow)
	if navPos >= len(vc.Navigable) {
		navPos = len(vc.Navigable) - 1
	}
	state.Cursor = vc.Navigable[navPos]
	return centerViewportOnCursor(state, vc)
}

// centerViewportOnCursor positions the viewport so the cursor is roughly centered.
func centerViewportOnCursor(state State, vc ViewContext) State {
	cursorPos := sort.SearchInts(vc.Visible, state.Cursor)
	if cursorPos >= len(vc.Visible) || vc.Visible[cursorPos] != state.Cursor {
		return clampViewportVisible(state, vc)
	}

	headerSet := makeHeaderSet(vc.Headers)
	halfHeight := state.ViewportHeight / 2

	// Walk backward from cursor, counting terminal lines until half viewport filled
	termLines := 0
	newStart := cursorPos
	for newStart > 0 {
		cost := rowTermCost(vc.Visible[newStart-1], headerSet, vc.CommentRows, vc.WrapCosts)
		if termLines+cost > halfHeight {
			break
		}
		termLines += cost
		newStart--
	}

	// Don't leave blank space at bottom: find latest start that fills viewport
	maxStart := len(vc.Visible) - 1
	termFromEnd := 0
	for maxStart > 0 {
		cost := rowTermCost(vc.Visible[maxStart], headerSet, vc.CommentRows, vc.WrapCosts)
		if termFromEnd+cost >= state.ViewportHeight {
			break
		}
		termFromEnd += cost
		maxStart--
	}
	if newStart > maxStart {
		newStart = maxStart
	}
	state.ViewportOffset = vc.Visible[newStart]
	return state
}

// DefaultFoldState returns a fold state map with noisy files pre-folded.
// Matches: test files, lock files, binary files.
func DefaultFoldState(paths []string, binaryPaths map[string]bool) map[string]bool {
	state := map[string]bool{}
	for _, path := range paths {
		if shouldAutoFold(path) || binaryPaths[path] {
			state[path] = true
		}
	}
	return state
}

// FoldNewFiles returns an updated fold state that preserves existing
// folds/unfolds and auto-folds noisy files not present in previousPaths.
func FoldNewFiles(foldState map[string]bool, previousPaths []string, currentPaths []string, binaryPaths map[string]bool) map[string]bool {
	known := make(map[string]bool, len(previousPaths))
	for _, path := range previousPaths {
		known[path] = true
	}

	result := make(map[string]bool, len(foldState))
	for k, v := range foldState {
		result[k] = v
	}

	for _, path := range currentPaths {
		if !known[path] && (shouldAutoFold(path) || binaryPaths[path]) {
			result[path] = true
		}
	}

	return result
}

var testSuffixes = []string{
	"_test.go",
	".test.js", ".test.ts", ".test.tsx",
	".spec.js", ".spec.ts", ".spec.tsx",
}

var lockFiles = map[string]bool{
	"yarn.lock": true,
	"go.sum":    true,
}

func shouldAutoFold(path string) bool {
	if strings.Contains(path, "__tests__/") {
		return true
	}
	base := filepath.Base(path)
	if lockFiles[base] {
		return true
	}
	for _, suffix := range testSuffixes {
		if strings.HasSuffix(base, suffix) {
			return true
		}
	}
	return false
}

func clampViewportVisible(state State, vc ViewContext) State {
	if state.Cursor < state.ViewportOffset {
		state.ViewportOffset = state.Cursor
		return state
	}

	headerSet := makeHeaderSet(vc.Headers)
	viewportStart := sort.SearchInts(vc.Visible, state.ViewportOffset)
	cursorPos := sort.SearchInts(vc.Visible, state.Cursor)
	if cursorPos >= len(vc.Visible) || vc.Visible[cursorPos] != state.Cursor {
		return state
	}

	// Count terminal lines (headers and comment rows take an extra line each)
	termLines := 0
	for i := viewportStart; i <= cursorPos; i++ {
		termLines += rowTermCost(vc.Visible[i], headerSet, vc.CommentRows, vc.WrapCosts)
	}

	if termLines > state.ViewportHeight {
		// Walk backwards from cursor to find viewport start that fits
		remaining := state.ViewportHeight
		newStart := cursorPos
		for newStart > 0 {
			cost := rowTermCost(vc.Visible[newStart], headerSet, vc.CommentRows, vc.WrapCosts)
			if remaining-cost < 0 {
				break
			}
			remaining -= cost
			if remaining <= 0 {
				break
			}
			newStart--
		}
		state.ViewportOffset = vc.Visible[newStart]
	}
	return state
}

// rowTermCost returns the number of terminal lines a row occupies.
func rowTermCost(rowIndex int, headerSet map[int]bool, commentRows map[int]bool, wrapCosts map[int]int) int {
	cost := 1
	if wc, ok := wrapCosts[rowIndex]; ok {
		cost = wc
	}
	if headerSet[rowIndex] {
		cost++
	}
	if commentRows[rowIndex] {
		cost++
	}
	return cost
}

func makeHeaderSet(headers []int) map[int]bool {
	set := make(map[int]bool, len(headers))
	for _, h := range headers {
		set[h] = true
	}
	return set
}
