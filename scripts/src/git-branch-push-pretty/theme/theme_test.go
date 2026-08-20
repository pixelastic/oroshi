package theme

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/charmbracelet/lipgloss"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- JSON loading ---

func TestColorReturnsANSIIndex(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root, nil)
	require.NoError(t, err)
	ansi, err := loaded.Color("git-branch")
	require.NoError(t, err)
	assert.Equal(t, 73, ansi)
}

func TestIconReturnsGlyph(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root, nil)
	require.NoError(t, err)
	icon, err := loaded.Icon("git-branch-ahead")
	require.NoError(t, err)
	assert.Equal(t, "UP", icon)
}

func TestColorReturnsErrorForUnknownKey(t *testing.T) {
	root := setupTestFiles(t)
	loaded, _ := Load(root, nil)
	_, err := loaded.Color("nonexistent")
	assert.Error(t, err)
}

func TestIconReturnsErrorForUnknownKey(t *testing.T) {
	root := setupTestFiles(t)
	loaded, _ := Load(root, nil)
	_, err := loaded.Icon("nonexistent")
	assert.Error(t, err)
}

// --- Dynamic color resolution ---

func TestBranchColorCallsBinZsh(t *testing.T) {
	root := setupTestFiles(t)
	runner := func(name string, args ...string) (string, error) {
		assert.Equal(t, "bin-zsh", name)
		assert.Equal(t, "git-branch-color", args[0])
		assert.Equal(t, "main", args[1])
		return "73\n", nil
	}
	loaded, _ := Load(root, runner)
	ansi, err := loaded.BranchColor("main")
	require.NoError(t, err)
	assert.Equal(t, 73, ansi)
}

func TestRemoteColorCallsBinZsh(t *testing.T) {
	root := setupTestFiles(t)
	runner := func(name string, args ...string) (string, error) {
		assert.Equal(t, "bin-zsh", name)
		assert.Equal(t, "git-remote-color", args[0])
		assert.Equal(t, "origin", args[1])
		return "42\n", nil
	}
	loaded, _ := Load(root, runner)
	ansi, err := loaded.RemoteColor("origin")
	require.NoError(t, err)
	assert.Equal(t, 42, ansi)
}

// --- Lipgloss conversion ---

func TestLipglossColorConvertsANSIIndex(t *testing.T) {
	assert.Equal(t, lipgloss.Color("73"), ANSIToLipgloss(73))
}

// --- Helpers ---

func setupTestFiles(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	colorsJSON := `{"git-branch": {"ansi": 73, "hex": "#5fafaf"}, "git-remote": {"ansi": 42, "hex": "#00d787"}}`
	iconsJSON := `{"git-branch-ahead": "UP", "git-branch-behind": "DOWN"}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), []byte(colorsJSON), 0o644))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "icons.json"), []byte(iconsJSON), 0o644))
	return root
}
