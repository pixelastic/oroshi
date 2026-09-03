package flash

import (
	"fmt"
	"strings"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
)

// Snapshot holds per-file sets of marked line contents for flash detection.
type Snapshot struct {
	// Lines is keyed "file:line" → content
	Lines map[string]string
	// ContentSet is keyed "file" → set of content strings
	ContentSet map[string]map[string]bool
}

// NewSnapshot builds a snapshot from layout rows and raw file lines.
// Only rows with a non-nil Marker are included.
func NewSnapshot(rows []layout.Row, rawLines map[string][]string) Snapshot {
	s := Snapshot{
		Lines:      make(map[string]string),
		ContentSet: make(map[string]map[string]bool),
	}
	for _, row := range rows {
		r, ok := row.(layout.LineRow)
		if !ok || r.Marker == nil {
			continue
		}
		content := RawLineContent(rawLines, r.FilePath, r.LineNumber)
		key := fmt.Sprintf("%s:%d", r.FilePath, r.LineNumber)
		s.Lines[key] = content
		if s.ContentSet[r.FilePath] == nil {
			s.ContentSet[r.FilePath] = make(map[string]bool)
		}
		s.ContentSet[r.FilePath][content] = true
	}
	return s
}

// DetectChangedLines returns marked lines whose content is new to their file's diff.
func DetectChangedLines(prev *Snapshot, current Snapshot) map[string]bool {
	if prev == nil {
		return nil
	}
	flash := make(map[string]bool)
	for key, content := range current.Lines {
		file := key[:strings.LastIndex(key, ":")]
		prevSet := prev.ContentSet[file]
		if prevSet != nil && prevSet[content] {
			continue
		}
		flash[key] = true
	}
	if len(flash) == 0 {
		return nil
	}
	return flash
}

// RawLineContent looks up a line by number from a lines slice.
func RawLineContent(rawLines map[string][]string, relativePath string, lineNumber int) string {
	lines, ok := rawLines[relativePath]
	if !ok {
		return ""
	}
	index := lineNumber - 1
	if index < 0 || index >= len(lines) {
		return ""
	}
	return lines[index]
}
