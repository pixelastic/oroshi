package theme

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// Theme holds resolved colors from oroshi theming.
type Theme struct {
	colors    map[string]int
	hexColors map[string]string
	filetypes map[string]filetypeEntry // keyed by extension (e.g. "go") or exact filename (e.g. ".envrc")
}

// colorEntry matches the shape of each value in colors.json.
type colorEntry struct {
	ANSI int    `json:"ansi"`
	Hex  string `json:"hex"`
}

// filetypeEntry matches each value in filetypes.json.
type filetypeEntry struct {
	Bold    bool `json:"bold"`
	Color   struct {
		ANSI int    `json:"ansi"`
		Hex  string `json:"hex"`
	} `json:"color"`
	Pattern string `json:"pattern"`
}

// requiredTokens lists all color tokens that must be present.
var requiredTokens = []string{"git-added", "git-modified", "git-removed", "orange", "gray", "gray-7", "directory"}

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
	hexColors := make(map[string]string, len(colorEntries))
	for name, entry := range colorEntries {
		colors[name] = entry.ANSI
		hexColors[name] = entry.Hex
	}

	for _, token := range requiredTokens {
		if _, ok := colors[token]; !ok {
			return nil, fmt.Errorf("missing required color token: %s", token)
		}
	}

	// Load filetypes
	filetypesPath := filepath.Join(oroshiRoot, "tools", "term", "zsh", "config", "theming", "dist", "filetypes.json")
	filetypesRaw, err := os.ReadFile(filetypesPath)
	if err != nil {
		return nil, fmt.Errorf("reading filetypes.json: %w", err)
	}
	var filetypes map[string]filetypeEntry
	if err := json.Unmarshal(filetypesRaw, &filetypes); err != nil {
		return nil, fmt.Errorf("parsing filetypes.json: %w", err)
	}

	return &Theme{colors: colors, hexColors: hexColors, filetypes: filetypes}, nil
}

// Color returns the ANSI index for a named color.
func (t *Theme) Color(name string) (int, error) {
	ansi, ok := t.colors[name]
	if !ok {
		return 0, fmt.Errorf("unknown color: %s", name)
	}
	return ansi, nil
}

// Hex returns the hex color string for a named color, or "" if not found.
func (t *Theme) Hex(name string) string {
	return t.hexColors[name]
}

// FilenameColor returns the lipgloss color and bold flag for a filename
// based on its extension or exact name match in filetypes.json.
func (t *Theme) FilenameColor(basename string) (lipgloss.Color, bool) {
	// Try extension match first (e.g. "main.go" → ext "go")
	ext := strings.TrimPrefix(filepath.Ext(basename), ".")
	if ext != "" {
		if entry, ok := t.filetypes[ext]; ok {
			return resolveFiletypeColor(entry), entry.Bold
		}
	}
	// Try exact filename match by scanning patterns
	for _, entry := range t.filetypes {
		if entry.Pattern == basename {
			return resolveFiletypeColor(entry), entry.Bold
		}
	}
	return lipgloss.Color(""), false
}

func resolveFiletypeColor(entry filetypeEntry) lipgloss.Color {
	if entry.Color.Hex != "" {
		return lipgloss.Color(entry.Color.Hex)
	}
	return lipgloss.Color(strconv.Itoa(entry.Color.ANSI))
}

// Lipgloss resolves a color token to a lipgloss.Color.
// Prefers hex (true-color), falls back to ANSI.
func (t *Theme) Lipgloss(name string) lipgloss.Color {
	if hex := t.hexColors[name]; hex != "" {
		return lipgloss.Color(hex)
	}
	ansi, ok := t.colors[name]
	if !ok {
		return lipgloss.Color("")
	}
	return lipgloss.Color(strconv.Itoa(ansi))
}
