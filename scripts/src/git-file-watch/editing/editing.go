package editing

import "strings"

// State tracks inline comment editing.
type State struct {
	Active       bool
	FilePath     string
	LineNumber   int
	LineContent  string
	OriginalText string
	RowIndex     int
}

// SaveResult holds the outcome of a save operation.
type SaveResult struct {
	FilePath    string
	LineNumber  int
	LineContent string
	Text        string
	IsEmpty     bool
}

// Open creates an active editing state for the given line.
func Open(filePath string, lineNumber int, lineContent string, existingReview string, rowIndex int) State {
	return State{
		Active:       true,
		FilePath:     filePath,
		LineNumber:   lineNumber,
		LineContent:  lineContent,
		OriginalText: existingReview,
		RowIndex:     rowIndex,
	}
}

// Save builds a save result from the current state and textarea content.
func Save(state State, text string) SaveResult {
	trimmed := strings.TrimSpace(text)
	return SaveResult{
		FilePath:    state.FilePath,
		LineNumber:  state.LineNumber,
		LineContent: state.LineContent,
		Text:        trimmed,
		IsEmpty:     trimmed == "",
	}
}

// Inactive returns a zero (inactive) editing state.
func Inactive() State {
	return State{}
}
