package summary

import (
	"fmt"

	"github.com/charmbracelet/lipgloss"
)

// Theme holds the resolved theme values needed for summary rendering.
type Theme struct {
	FileIcon     string
	CreatedColor lipgloss.Color
	DeletedColor lipgloss.Color
}

// Render returns a styled summary line.
func Render(total, created, deleted int, theme Theme) string {
	if total == 0 {
		return ""
	}

	line := fmt.Sprintf("%s %d", theme.FileIcon, total)

	if created > 0 {
		styled := lipgloss.NewStyle().Foreground(theme.CreatedColor).Render(fmt.Sprintf("%d ✚", created))
		line += " " + styled
	}

	if deleted > 0 {
		styled := lipgloss.NewStyle().Foreground(theme.DeletedColor).Render(fmt.Sprintf("%d ✖", deleted))
		line += " " + styled
	}

	return line
}
