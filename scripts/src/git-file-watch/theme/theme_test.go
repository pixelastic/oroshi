package theme

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Color loading ---

func TestLoadsRequiredColors(t *testing.T) {
	tests := []struct {
		name     string
		token    string
		expected int
	}{
		{"git-added", "git-added", 40},
		{"git-modified", "git-modified", 135},
		{"git-removed", "git-removed", 196},
		{"orange", "orange", 208},
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

// --- Error cases ---

func TestReturnsErrorWhenColorsFileIsMissing(t *testing.T) {
	root := t.TempDir()
	_, err := Load(root)
	assert.Error(t, err)
}

func TestReturnsErrorWhenRequiredTokenIsMissing(t *testing.T) {
	root := setupTestFilesWithoutToken(t, "orange")
	_, err := Load(root)
	assert.Error(t, err)
}

// --- Helpers ---

func setupTestFiles(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	require.NoError(t, os.MkdirAll(dir, 0o755))
	colorsJSON := `{
		"git-added": {"ansi": 40, "hex": "#00d700"},
		"git-modified": {"ansi": 135, "hex": "#af5fff"},
		"git-removed": {"ansi": 196, "hex": "#ff0000"},
		"orange": {"ansi": 208, "hex": "#ff8700"},
		"gray": {"ansi": 245, "hex": "#6b7280"},
		"gray-7": {"ansi": 236, "hex": "#374151"}
	}`
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), []byte(colorsJSON), 0o644))
	return root
}

func setupTestFilesWithoutToken(t *testing.T, missingToken string) string {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	require.NoError(t, os.MkdirAll(dir, 0o755))

	allTokens := map[string]colorEntry{
		"git-added":    {ANSI: 40, Hex: "#00d700"},
		"git-modified": {ANSI: 135, Hex: "#af5fff"},
		"git-removed":  {ANSI: 196, Hex: "#ff0000"},
		"orange":       {ANSI: 208, Hex: "#ff8700"},
		"gray":         {ANSI: 245, Hex: "#6b7280"},
		"gray-7":       {ANSI: 236, Hex: "#374151"},
	}
	delete(allTokens, missingToken)

	colorsJSON, err := json.Marshal(allTokens)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), colorsJSON, 0o644))
	return root
}
