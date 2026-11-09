package theme

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Color loading ---

func TestLoadsColorsFromColorsJSON(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root)
	require.NoError(t, err)
	_, err = loaded.Color("directory")
	assert.NoError(t, err)
}

func TestLoadsIconsFromIconsJSON(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root)
	require.NoError(t, err)
	icon, err := loaded.Icon("filetype-file")
	require.NoError(t, err)
	assert.Equal(t, "F", icon)
}

func TestLoadsFiletypesFromFiletypesJSON(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root)
	require.NoError(t, err)
	color := loaded.FiletypeColor("main.go")
	assert.NotEmpty(t, string(color))
}

// --- Color tokens ---

func TestResolvesColorTokens(t *testing.T) {
	tests := []struct {
		name     string
		token    string
		expected int
	}{
		{"directory", "directory", 35},
		{"git-added", "git-added", 40},
		{"git-removed", "git-removed", 196},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			root := setupTestFiles(t)
			loaded, err := Load(root)
			require.NoError(t, err)
			ansi, err := loaded.Color(tt.token)
			require.NoError(t, err)
			assert.Equal(t, tt.expected, ansi)
		})
	}
}

// --- Filetype colors ---

func TestResolvesFiletypeColorForKnownExtension(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root)
	require.NoError(t, err)
	color := loaded.FiletypeColor("main.go")
	assert.Equal(t, "#38a169", string(color))
}

func TestReturnsFallbackColorForUnknownExtension(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root)
	require.NoError(t, err)
	color := loaded.FiletypeColor("file.unknownext")
	assert.Empty(t, string(color))
}

func TestResolvesFiletypeColorForAutoloadPathWithoutExtension(t *testing.T) {
	root := setupTestFiles(t)
	loaded, err := Load(root)
	require.NoError(t, err)
	color := loaded.FiletypeColor("tools/term/zsh/config/functions/autoload/todo-add")
	assert.Equal(t, "#a78bfa", string(color))
}

// --- Icons ---

func TestResolvesIcons(t *testing.T) {
	tests := []struct {
		name     string
		key      string
		expected string
	}{
		{"filetype-file", "filetype-file", "F"},
		{"filetype-directory", "filetype-directory", "D"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			root := setupTestFiles(t)
			loaded, err := Load(root)
			require.NoError(t, err)
			icon, err := loaded.Icon(tt.key)
			require.NoError(t, err)
			assert.Equal(t, tt.expected, icon)
		})
	}
}

// --- Helpers ---

func setupTestFiles(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	require.NoError(t, os.MkdirAll(dir, 0o755))

	colorsJSON := `{
		"directory": {"ansi": 35, "hex": "#38a169"},
		"git-added": {"ansi": 40, "hex": "#00d700"},
		"git-removed": {"ansi": 196, "hex": "#ff0000"}
	}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), []byte(colorsJSON), 0o644))

	iconsJSON := `{
		"filetype-file": "F",
		"filetype-directory": "D",
		"separator-arrow": ">"
	}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "icons.json"), []byte(iconsJSON), 0o644))

	filetypesJSON := `{
		"go": {"bold": true, "color": {"ansi": 35, "hex": "#38a169"}, "icon": {"glyph": "G"}, "pattern": "*.go"},
		"js": {"bold": false, "color": {"ansi": 226, "hex": "#facc15"}, "icon": {"glyph": "J"}, "pattern": "*.js"},
		"zsh": {"bold": false, "color": {"ansi": 173, "hex": "#a78bfa"}, "icon": {"glyph": "S"}, "pattern": "*.zsh"}
	}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "filetypes.json"), []byte(filetypesJSON), 0o644))

	return root
}
