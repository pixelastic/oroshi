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

// Theme holds resolved colors, icons, and filetypes from oroshi theming.
type Theme struct {
	colors    map[string]int
	hexColors map[string]string
	icons     map[string]string
	filetypes map[string]filetypeEntry
}

// colorEntry matches the shape of each value in colors.json.
type colorEntry struct {
	ANSI int    `json:"ansi"`
	Hex  string `json:"hex"`
}

// filetypeEntry matches each value in filetypes.json.
type filetypeEntry struct {
	Bold  bool `json:"bold"`
	Color struct {
		ANSI int    `json:"ansi"`
		Hex  string `json:"hex"`
	} `json:"color"`
	Icon struct {
		Glyph string `json:"glyph"`
	} `json:"icon"`
	Pattern string `json:"pattern"`
}

// Load reads colors.json, icons.json, and filetypes.json from oroshiRoot.
func Load(oroshiRoot string) (*Theme, error) {
	distributionDir := filepath.Join(oroshiRoot, "tools", "term", "zsh", "config", "theming", "dist")

	colors, hexColors, err := loadColors(distributionDir)
	if err != nil {
		return nil, err
	}

	icons, err := loadIcons(distributionDir)
	if err != nil {
		return nil, err
	}

	filetypes, err := loadFiletypes(distributionDir)
	if err != nil {
		return nil, err
	}

	return &Theme{
		colors:    colors,
		hexColors: hexColors,
		icons:     icons,
		filetypes: filetypes,
	}, nil
}

// Color returns the ANSI index for a named color.
func (t *Theme) Color(name string) (int, error) {
	ansi, ok := t.colors[name]
	if !ok {
		return 0, fmt.Errorf("unknown color: %s", name)
	}
	return ansi, nil
}

// Icon returns the glyph for a named icon.
func (t *Theme) Icon(name string) (string, error) {
	icon, ok := t.icons[name]
	if !ok {
		return "", fmt.Errorf("unknown icon: %s", name)
	}
	return icon, nil
}

// pathPatterns maps path substrings to filetype keys for extensionless files.
var pathPatterns = []struct {
	contains    string
	filetypeKey string
}{
	{"tools/term/zsh/config/functions/autoload/", "zsh"},
}

// FiletypeColor returns the lipgloss color for a file path based on its extension,
// or path pattern for extensionless files.
// Returns empty color for unknown files.
func (t *Theme) FiletypeColor(path string) lipgloss.Color {
	ext := strings.TrimPrefix(filepath.Ext(path), ".")
	if ext == "" {
		for _, p := range pathPatterns {
			if strings.Contains(path, p.contains) {
				ext = p.filetypeKey
				break
			}
		}
	}
	if ext == "" {
		return lipgloss.Color("")
	}
	entry, ok := t.filetypes[ext]
	if !ok {
		return lipgloss.Color("")
	}
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

func loadColors(distributionDir string) (map[string]int, map[string]string, error) {
	raw, err := os.ReadFile(filepath.Join(distributionDir, "colors.json"))
	if err != nil {
		return nil, nil, fmt.Errorf("reading colors.json: %w", err)
	}
	var entries map[string]colorEntry
	if err := json.Unmarshal(raw, &entries); err != nil {
		return nil, nil, fmt.Errorf("parsing colors.json: %w", err)
	}
	colors := make(map[string]int, len(entries))
	hexColors := make(map[string]string, len(entries))
	for name, entry := range entries {
		colors[name] = entry.ANSI
		hexColors[name] = entry.Hex
	}
	return colors, hexColors, nil
}

func loadIcons(distributionDir string) (map[string]string, error) {
	raw, err := os.ReadFile(filepath.Join(distributionDir, "icons.json"))
	if err != nil {
		return nil, fmt.Errorf("reading icons.json: %w", err)
	}
	var icons map[string]string
	if err := json.Unmarshal(raw, &icons); err != nil {
		return nil, fmt.Errorf("parsing icons.json: %w", err)
	}
	return icons, nil
}

func loadFiletypes(distributionDir string) (map[string]filetypeEntry, error) {
	raw, err := os.ReadFile(filepath.Join(distributionDir, "filetypes.json"))
	if err != nil {
		return nil, fmt.Errorf("reading filetypes.json: %w", err)
	}
	var filetypes map[string]filetypeEntry
	if err := json.Unmarshal(raw, &filetypes); err != nil {
		return nil, fmt.Errorf("parsing filetypes.json: %w", err)
	}
	return filetypes, nil
}
