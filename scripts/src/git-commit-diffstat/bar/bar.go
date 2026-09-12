package bar

import (
	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/diff"
)

// Colors holds the theme colors needed for bar rendering.
type Colors struct {
	Added    lipgloss.Color
	Removed  lipgloss.Color
	Modified lipgloss.Color
}

// bars maps log-scale levels (0-5) to block characters.
// Capped at ▆ — ▇ touches the line above when bars are stacked vertically.
var bars = []string{"▁", "▂", "▃", "▄", "▅", "▆"}

// logScale maps a line count to a bar character index (0-5).
func logScale(lines int) int {
	switch {
	case lines <= 0:
		return 0
	case lines <= 5:
		return 0
	case lines <= 15:
		return 1
	case lines <= 50:
		return 2
	case lines <= 150:
		return 3
	case lines <= 500:
		return 4
	default:
		return 5
	}
}

func styledBar(character string, color lipgloss.Color) string {
	return lipgloss.NewStyle().Foreground(color).Render(character)
}

// Render returns a styled magnitude bar string.
func Render(additions, deletions int, status diff.Status, isBinary bool, colors Colors) string {
	if isBinary {
		return renderBinary(status, colors)
	}

	if additions == 0 && deletions == 0 {
		return ""
	}

	if additions == deletions {
		total := additions + deletions
		return styledBar(bars[logScale(total)], colors.Modified)
	}

	if additions == 0 {
		return styledBar(bars[logScale(deletions)], colors.Removed)
	}

	if deletions == 0 {
		return styledBar(bars[logScale(additions)], colors.Added)
	}

	return styledBar(bars[logScale(additions)], colors.Added) +
		styledBar(bars[logScale(deletions)], colors.Removed)
}

func renderBinary(status diff.Status, colors Colors) string {
	switch status {
	case diff.Added:
		return styledBar("▆", colors.Added)
	case diff.Deleted:
		return styledBar("▆", colors.Removed)
	default:
		return styledBar("▄", colors.Modified)
	}
}
