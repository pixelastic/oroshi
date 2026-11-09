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

// CommandRunner executes a command and returns its stdout.
type CommandRunner func(name string, args ...string) (string, error)

// Theme holds resolved colors and icons from oroshi theming.
type Theme struct {
	colors map[string]int
	icons  map[string]string
	runner CommandRunner
}

// colorEntry matches the shape of each value in colors.json.
type colorEntry struct {
	ANSI int    `json:"ansi"`
	Hex  string `json:"hex"`
}

// Load reads color/icon JSON files from oroshiRoot and returns a Theme.
func Load(oroshiRoot string, runner CommandRunner) (*Theme, error) {
	distributionDir := filepath.Join(oroshiRoot, "tools", "term", "zsh", "config", "theming", "dist")

	// Load colors
	colorsRaw, err := os.ReadFile(filepath.Join(distributionDir, "colors.json"))
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

	// Load icons
	iconsRaw, err := os.ReadFile(filepath.Join(distributionDir, "icons.json"))
	if err != nil {
		return nil, fmt.Errorf("reading icons.json: %w", err)
	}
	var icons map[string]string
	if err := json.Unmarshal(iconsRaw, &icons); err != nil {
		return nil, fmt.Errorf("parsing icons.json: %w", err)
	}

	return &Theme{
		colors: colors,
		icons:  icons,
		runner: runner,
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

// BranchColor returns the ANSI index for a branch's dynamic color.
func (t *Theme) BranchColor(branch string) (int, error) {
	return t.runColorCommand("git-branch-color", branch)
}

// RemoteColor returns the ANSI index for a remote's dynamic color.
func (t *Theme) RemoteColor(remote string) (int, error) {
	return t.runColorCommand("git-remote-color", remote)
}

func (t *Theme) runColorCommand(functionName, argument string) (int, error) {
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

// ANSIToLipgloss converts an ANSI 256 index to a lipgloss Color.
func ANSIToLipgloss(ansi int) lipgloss.Color {
	return lipgloss.Color(strconv.Itoa(ansi))
}
