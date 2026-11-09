package theme

import (
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/charmbracelet/lipgloss"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Loading ---

func TestLoadsColorsAndIconsFromDistributionDirectory(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	ansi, err := theme.Color("git-branch")
	require.NoError(t, err)
	icon, err := theme.Icon("git-branch-ahead")
	require.NoError(t, err)

	assert.Equal(t, 73, ansi)
	assert.Equal(t, "UP", icon)
}

func TestReturnsErrorWhenDistributionFileIsMissing(t *testing.T) {
	_, err := Load(t.TempDir(), nil)
	assert.Error(t, err)
}

func TestReturnsErrorForUnknownColorOrIcon(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	_, colorErr := theme.Color("nonexistent")
	_, iconErr := theme.Icon("nonexistent")

	assert.Error(t, colorErr)
	assert.Error(t, iconErr)
}

// --- Required tokens ---

func TestRequireReturnsErrorForMissingColorToken(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	assert.NoError(t, theme.Require("git-branch", "git-remote"))
	assert.Error(t, theme.Require("git-branch", "nonexistent"))
}

// --- Lipgloss ---

func TestLipglossPrefersHexOverANSI(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	assert.Equal(t, lipgloss.Color("#5fafaf"), theme.Lipgloss("git-branch"))
	assert.Equal(t, "#5fafaf", theme.Hex("git-branch"))
}

func TestLipglossFallsBackToANSIWithoutHex(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	assert.Equal(t, lipgloss.Color("99"), theme.Lipgloss("plain"))
}

func TestLipglossReturnsEmptyForUnknownToken(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	assert.Empty(t, string(theme.Lipgloss("nonexistent")))
}

func TestConvertsANSIIndexToLipglossColor(t *testing.T) {
	assert.Equal(t, lipgloss.Color("73"), ANSIToLipgloss(73))
}

// --- Dynamic colors ---

func TestResolvesBranchColorThroughRunner(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		assert.Equal(t, "bin-zsh", name)
		assert.Equal(t, []string{"git-branch-color", "main"}, args)
		return "73\n", nil
	}
	theme, err := Load(setupTestFiles(t), runner)
	require.NoError(t, err)

	ansi, err := theme.BranchColor("main")

	require.NoError(t, err)
	assert.Equal(t, 73, ansi)
}

func TestResolvesRemoteColorThroughRunner(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		assert.Equal(t, "bin-zsh", name)
		assert.Equal(t, []string{"git-remote-color", "origin"}, args)
		return "42\n", nil
	}
	theme, err := Load(setupTestFiles(t), runner)
	require.NoError(t, err)

	ansi, err := theme.RemoteColor("origin")

	require.NoError(t, err)
	assert.Equal(t, 42, ansi)
}

func TestReturnsErrorWhenRunnerFails(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		return "", errors.New("boom")
	}
	theme, err := Load(setupTestFiles(t), runner)
	require.NoError(t, err)

	_, err = theme.BranchColor("main")

	assert.Error(t, err)
}

func TestReturnsErrorWhenRunnerOutputIsNotANumber(t *testing.T) {
	runner := func(name string, args ...string) (string, error) {
		return "not-a-number\n", nil
	}
	theme, err := Load(setupTestFiles(t), runner)
	require.NoError(t, err)

	_, err = theme.RemoteColor("origin")

	assert.Error(t, err)
}

// --- Filetypes ---

func TestResolvesFiletypeColorAndIconFromPath(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	color, bold := theme.FiletypeColor("src/main.go", "")
	icon := theme.FiletypeIcon("src/main.go", "")

	assert.Equal(t, lipgloss.Color("#38a169"), color)
	assert.True(t, bold)
	assert.Equal(t, "G", icon)
}

func TestFiletypeColorFallsBackToANSIWithoutHex(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	color, _ := theme.FiletypeColor("script.py", "")

	assert.Equal(t, lipgloss.Color("220"), color)
}

func TestResolvesFiletypeFromExactFilename(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	color, bold := theme.FiletypeColor(".envrc", "")

	assert.Equal(t, lipgloss.Color("#8b5cf6"), color)
	assert.False(t, bold)
}

func TestReturnsEmptyFiletypeForUnknownExtension(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	color, bold := theme.FiletypeColor("file.unknownext", "")
	icon := theme.FiletypeIcon("file.unknownext", "")

	assert.Empty(t, string(color))
	assert.False(t, bold)
	assert.Empty(t, icon)
}

func TestResolvesFiletypeFromAutoloadPathWithoutExtension(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	color, _ := theme.FiletypeColor("tools/term/zsh/config/functions/autoload/context/context-path", "")
	icon := theme.FiletypeIcon("tools/term/zsh/config/functions/autoload/context/context-path", "")

	assert.Equal(t, lipgloss.Color("#a78bfa"), color)
	assert.Equal(t, "Z", icon)
}

func TestKeepsExtensionOverAutoloadPath(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	// A .js file under autoload should still resolve as JS, not ZSH
	color, _ := theme.FiletypeColor("tools/term/zsh/config/functions/autoload/test/file.js", "")

	assert.Equal(t, lipgloss.Color("#facc15"), color)
}

func TestResolvesFiletypeFromShebangWhenPathIsAmbiguous(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	color, _ := theme.FiletypeColor("scripts/onStartup", "#!/bin/zsh")
	icon := theme.FiletypeIcon("scripts/onStartup", "#!/usr/bin/env bash")

	assert.Equal(t, lipgloss.Color("#a78bfa"), color)
	assert.Equal(t, "S", icon)
}

func TestPathPatternTakesPriorityOverShebang(t *testing.T) {
	theme, err := Load(setupTestFiles(t), nil)
	require.NoError(t, err)

	// Autoload path → zsh, even with a bash shebang
	color, _ := theme.FiletypeColor("tools/term/zsh/config/functions/autoload/git/git-foo", "#!/bin/bash")

	assert.Equal(t, lipgloss.Color("#a78bfa"), color)
}

// --- Helpers ---

func setupTestFiles(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	require.NoError(t, os.MkdirAll(dir, 0o755))

	colorsJSON := `{"git-branch": {"ansi": 73, "hex": "#5fafaf"}, "git-remote": {"ansi": 42, "hex": "#00d787"}, "plain": {"ansi": 99}}`
	iconsJSON := `{"git-branch-ahead": "UP", "git-branch-behind": "DOWN"}`
	filetypesJSON := `{
		"go": {"bold": true, "color": {"ansi": 35, "hex": "#38a169"}, "icon": {"glyph": "G"}, "pattern": "*.go"},
		"zsh": {"bold": false, "color": {"ansi": 173, "hex": "#a78bfa"}, "icon": {"glyph": "Z"}, "pattern": "*.zsh"},
		"sh": {"bold": false, "color": {"ansi": 173, "hex": "#a78bfa"}, "icon": {"glyph": "S"}, "pattern": "*.sh"},
		"_envrc": {"bold": false, "color": {"ansi": 174, "hex": "#8b5cf6"}, "pattern": ".envrc"},
		"js": {"bold": false, "color": {"ansi": 226, "hex": "#facc15"}, "icon": {"glyph": "J"}, "pattern": "*.js"},
		"py": {"bold": false, "color": {"ansi": 220}, "icon": {"glyph": "P"}, "pattern": "*.py"}
	}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), []byte(colorsJSON), 0o644))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "icons.json"), []byte(iconsJSON), 0o644))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "filetypes.json"), []byte(filetypesJSON), 0o644))
	return root
}
