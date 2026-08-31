package theme

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"

	"github.com/charmbracelet/lipgloss"
)

// Theme holds resolved colors from oroshi theming.
type Theme struct {
	colors map[string]int
}

// colorEntry matches the shape of each value in colors.json.
type colorEntry struct {
	ANSI int    `json:"ansi"`
	Hex  string `json:"hex"`
}

// requiredTokens lists all color tokens that must be present.
var requiredTokens = []string{"git-added", "git-modified", "git-removed", "orange"}

// Load reads colors.json from oroshiRoot and returns a Theme.
// It validates that all required tokens are present.
func Load(oroshiRoot string) (*Theme, error) {
	colorsPath := filepath.Join(oroshiRoot, "tools", "term", "zsh", "config", "theming", "dist", "colors.json")

	colorsRaw, err := os.ReadFile(colorsPath)
	if err != nil {
		return nil, fmt.Errorf("reading colors.json: %w", err)
	}

	var colorEntries map[string]colorEntry
	if err := json.Unmarshal(colorsRaw, &colorEntries); err != nil {
		return nil, fmt.Errorf("parsing colors.json: %w", err)
	}

	colors := make(map[string]int, len(colorEntries))
	for name, entry := range colorEntries {
		colors[name] = entry.ANSI
	}

	for _, token := range requiredTokens {
		if _, ok := colors[token]; !ok {
			return nil, fmt.Errorf("missing required color token: %s", token)
		}
	}

	return &Theme{colors: colors}, nil
}

// Color returns the ANSI index for a named color.
func (t *Theme) Color(name string) (int, error) {
	ansi, ok := t.colors[name]
	if !ok {
		return 0, fmt.Errorf("unknown color: %s", name)
	}
	return ansi, nil
}

// ANSIToLipgloss converts an ANSI 256 index to a lipgloss Color.
func ANSIToLipgloss(ansi int) lipgloss.Color {
	return lipgloss.Color(strconv.Itoa(ansi))
}
