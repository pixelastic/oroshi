package render

import (
	"regexp"
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/charmbracelet/x/ansi"
)

var sgrPattern = regexp.MustCompile(`\x1b\[[0-9;]*m`)

// WrapLine splits an ANSI-styled string into display lines at word boundaries.
// If a single word exceeds the width, it is hard-wrapped.
// Returns a single-element slice for lines that fit.
func WrapLine(styledContent string, width int) []string {
	wrapped := ansi.Wrap(styledContent, width, "")
	lines := strings.Split(wrapped, "\n")
	return carryAnsiState(lines)
}

// WrapLineCount returns how many display rows a raw (non-ANSI) line will
// occupy at the given width. Uses lipgloss.Width for ANSI-aware measurement
// and ansi.Wrap for word-boundary splitting to guarantee agreement with
// len(WrapLine(...)).
func WrapLineCount(rawText string, width int) int {
	if lipgloss.Width(rawText) <= width {
		return 1
	}
	wrapped := ansi.Wrap(rawText, width, "")
	return len(strings.Split(wrapped, "\n"))
}

// carryAnsiState re-emits accumulated SGR escape sequences at the start of
// each continuation line so that styling is preserved across word-wrap breaks.
func carryAnsiState(lines []string) []string {
	if len(lines) <= 1 {
		return lines
	}

	result := make([]string, len(lines))
	var activeState string

	for i, line := range lines {
		if i > 0 && activeState != "" {
			line = activeState + line
		}

		matches := sgrPattern.FindAllString(line, -1)
		for _, match := range matches {
			if match == "\x1b[0m" {
				activeState = ""
			} else {
				activeState += match
			}
		}

		result[i] = line
	}

	return result
}
