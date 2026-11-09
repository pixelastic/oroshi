package theme

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/filetype"
)

// CommandRunner executes a command and returns its stdout.
type CommandRunner func(name string, args ...string) (string, error)

// Theme holds resolved colors, icons, and filetypes from oroshi theming.
type Theme struct {
	colors    map[string]int
	hexColors map[string]string
	icons     map[string]string
	filetypes map[string]filetypeEntry // keyed by extension (e.g. "go") or exact filename (e.g. ".envrc")
	runner    CommandRunner
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
// runner resolves the dynamic branch and remote colors, so it can be nil when
// neither BranchColor nor RemoteColor is called.
func Load(oroshiRoot string, runner CommandRunner) (*Theme, error) {
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
		runner:    runner,
	}, nil
}

// Require returns an error naming the first color token missing from the theme.
func (t *Theme) Require(tokens ...string) error {
	for _, token := range tokens {
		if _, ok := t.colors[token]; !ok {
			return fmt.Errorf("missing required color token: %s", token)
		}
	}
	return nil
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

// Icon returns the glyph for a named icon.
func (t *Theme) Icon(name string) (string, error) {
	icon, ok := t.icons[name]
	if !ok {
		return "", fmt.Errorf("unknown icon: %s", name)
	}
	return icon, nil
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
	return ANSIToLipgloss(ansi)
}

// ANSIToLipgloss converts an ANSI 256 index to a lipgloss Color.
func ANSIToLipgloss(ansi int) lipgloss.Color {
	return lipgloss.Color(strconv.Itoa(ansi))
}

// BranchColor returns the ANSI index for a branch's dynamic color.
func (t *Theme) BranchColor(branch string) (int, error) {
	return t.runColorCommand("git-branch-color", branch)
}

// RemoteColor returns the ANSI index for a remote's dynamic color.
func (t *Theme) RemoteColor(remote string) (int, error) {
	return t.runColorCommand("git-remote-color", remote)
}

// FiletypeColor returns the color and bold flag for a file.
// The extension or exact filename decides first. Path rules and the shebang in
// firstLine decide for extensionless files. Returns an empty color for unknown files.
func (t *Theme) FiletypeColor(path string, firstLine string) (lipgloss.Color, bool) {
	entry, ok := t.resolveFiletype(path, firstLine)
	if !ok {
		return lipgloss.Color(""), false
	}
	if entry.Color.Hex != "" {
		return lipgloss.Color(entry.Color.Hex), entry.Bold
	}
	return ANSIToLipgloss(entry.Color.ANSI), entry.Bold
}

// FiletypeIcon returns the icon glyph for a file, or "" for unknown files.
// It resolves the filetype like FiletypeColor.
func (t *Theme) FiletypeIcon(path string, firstLine string) string {
	entry, ok := t.resolveFiletype(path, firstLine)
	if !ok {
		return ""
	}
	return entry.Icon.Glyph
}

func (t *Theme) resolveFiletype(path string, firstLine string) (filetypeEntry, bool) {
	basename := filepath.Base(path)
	if entry, ok := t.resolveFiletypeFromName(basename); ok {
		return entry, true
	}
	if filepath.Ext(basename) != "" {
		return filetypeEntry{}, false
	}
	key := filetype.Resolve(path, firstLine).FiletypeKey
	entry, ok := t.filetypes[key]
	return entry, ok
}

func (t *Theme) resolveFiletypeFromName(basename string) (filetypeEntry, bool) {
	ext := strings.TrimPrefix(filepath.Ext(basename), ".")
	if entry, ok := t.filetypes[ext]; ok && ext != "" {
		return entry, true
	}
	for _, entry := range t.filetypes {
		if entry.Pattern == basename {
			return entry, true
		}
	}
	return filetypeEntry{}, false
}

func (t *Theme) runColorCommand(functionName, argument string) (int, error) {
	if t.runner == nil {
		return 0, errors.New("no command runner configured")
	}
	output, err := t.runner("bin-zsh", functionName, argument)
	if err != nil {
		return 0, fmt.Errorf("%s %s: %w", functionName, argument, err)
	}
	ansi, err := strconv.Atoi(strings.TrimSpace(output))
	if err != nil {
		return 0, fmt.Errorf("parsing %s output %q: %w", functionName, output, err)
	}
	return ansi, nil
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
