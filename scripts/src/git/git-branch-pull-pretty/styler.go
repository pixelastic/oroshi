package main

import (
	"strconv"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/theme"
)

// fallbackColor is the ANSI white, used when a branch color cannot be resolved.
const fallbackColor = 7

// themeStyler renders branch and tag names with the oroshi theme.
type themeStyler struct {
	theme *theme.Theme
}

// Branch renders the branch icon and name in the color of the branch.
func (s themeStyler) Branch(name string) string {
	color, err := s.theme.BranchColor(name)
	if err != nil {
		color = fallbackColor
	}
	return s.render("git-branch", name, lipgloss.Color(strconv.Itoa(color)))
}

// Tag renders the tag icon and name in the color of tags.
func (s themeStyler) Tag(name string) string {
	return s.render("git-tag", name, s.theme.Lipgloss("git-tag"))
}

func (s themeStyler) render(iconName string, text string, color lipgloss.Color) string {
	if icon, err := s.theme.Icon(iconName); err == nil {
		text = icon + " " + text
	}
	return lipgloss.NewStyle().Foreground(color).Render(text)
}
