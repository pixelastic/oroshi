package editor

import (
	"fmt"
	"os/exec"
	"path/filepath"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
)

// NvimCommand builds an exec.Cmd to open nvim at the correct file and line
// for the given cursor position. Returns nil if no file is found.
func NvimCommand(rows []layout.Row, cursor int, repoRoot string) *exec.Cmd {
	filePath := CurrentFilePath(rows, cursor)
	if filePath == "" {
		return nil
	}

	absolutePath := filepath.Join(repoRoot, filePath)
	lineNumber := resolveLineNumber(rows, cursor)

	return exec.Command("nvim", fmt.Sprintf("+%d", lineNumber), absolutePath)
}

// CurrentFilePath scans backwards from cursor to find the nearest FileHeaderRow.
func CurrentFilePath(rows []layout.Row, cursor int) string {
	for i := cursor; i >= 0; i-- {
		if header, ok := rows[i].(layout.FileHeaderRow); ok {
			return header.Path
		}
	}
	return ""
}

// resolveLineNumber returns the line number for the cursor row.
// LineRow uses its own line number; all other row types default to 1.
func resolveLineNumber(rows []layout.Row, cursor int) int {
	if cursor < 0 || cursor >= len(rows) {
		return 1
	}
	if lineRow, ok := rows[cursor].(layout.LineRow); ok {
		return lineRow.LineNumber
	}
	return 1
}
