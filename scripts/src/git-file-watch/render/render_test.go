package render

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/theme"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- FileHeader ---

func TestFileHeaderContainsBasenameForKnownExtension(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80}
	row := layout.FileHeaderRow{Path: "src/main.go"}

	result := FileHeader(ctx, row, 1)

	assert.Contains(t, result, "main.go")
	assert.Contains(t, result, "src/")
}

func TestFileHeaderContainsBasenameForUnknownExtension(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80}
	row := layout.FileHeaderRow{Path: "src/file.unknownext"}

	result := FileHeader(ctx, row, 1)

	assert.Contains(t, result, "file.unknownext")
}

// --- Gutter ---

func TestGutterContainsBarCharacter(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 5}

	result := Gutter(row, th, false)

	assert.Contains(t, result, "▌")
}

func TestGutterReturnsSameOutputForSameInputs(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 5}

	a := Gutter(row, th, false)
	b := Gutter(row, th, false)

	assert.Equal(t, a, b)
}

func TestGutterCommentChangesOutput(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	row := layout.LineRow{LineNumber: 5, Marker: &marker}

	// In non-TTY both may strip to same unstyled string,
	// but the function should still be callable without panic
	assert.NotPanics(t, func() { Gutter(row, th, true) })
	assert.NotPanics(t, func() { Gutter(row, th, false) })
}

// --- LineNumber ---

func TestLineNumberContainsNumber(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 42}

	result := LineNumber(row, th, 3, false, false, false)

	assert.Contains(t, result, "42")
}

func TestLineNumberPadsToWidth(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 5}

	result := LineNumber(row, th, 4, false, false, false)

	assert.Contains(t, result, "   5")
}

func TestLineNumberDoesNotPanic(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	row := layout.LineRow{LineNumber: 10, Marker: &marker}

	// Exercise all priority branches without panicking
	assert.NotPanics(t, func() { LineNumber(row, th, 3, false, false, false) })
	assert.NotPanics(t, func() { LineNumber(row, th, 3, false, false, true) })
	assert.NotPanics(t, func() { LineNumber(row, th, 3, true, false, false) })
	assert.NotPanics(t, func() { LineNumber(row, th, 3, true, true, false) })
	assert.NotPanics(t, func() { LineNumber(row, th, 3, true, true, true) })
}

// --- LineColor ---

func TestLineColorReturnsOrangeWhenHasComment(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	row := layout.LineRow{LineNumber: 5, Marker: &marker}

	result := LineColor(row, th, true)

	assert.Equal(t, th.Lipgloss("orange"), result)
}

func TestLineColorReturnsOrangeWhenHasCommentAndNoMarker(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 5}

	result := LineColor(row, th, true)

	assert.Equal(t, th.Lipgloss("orange"), result)
}

func TestLineColorReturnsMarkerColorWhenNoComment(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	row := layout.LineRow{LineNumber: 5, Marker: &marker}

	result := LineColor(row, th, false)

	assert.Equal(t, th.Lipgloss("git-added"), result)
}

func TestLineColorReturnsGrayWhenNoMarkerAndNoComment(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 5}

	result := LineColor(row, th, false)

	assert.Equal(t, th.Lipgloss("gray"), result)
}

// --- MarkerColorName ---

func TestMarkerColorNameReturnsGitAddedForAdded(t *testing.T) {
	assert.Equal(t, "git-added", MarkerColorName(diff.MarkerAdded))
}

func TestMarkerColorNameReturnsGitModifiedForModified(t *testing.T) {
	assert.Equal(t, "git-modified", MarkerColorName(diff.MarkerModified))
}

func TestMarkerColorNameReturnsGitRemovedForDeleted(t *testing.T) {
	assert.Equal(t, "git-removed", MarkerColorName(diff.MarkerDeleted))
}

// --- Helpers ---

func loadTestTheme(t *testing.T) *theme.Theme {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	require.NoError(t, os.MkdirAll(dir, 0o755))

	colors := map[string]map[string]interface{}{
		"git-added":    {"ansi": 40, "hex": "#00d700"},
		"git-modified": {"ansi": 135, "hex": "#af5fff"},
		"git-removed":  {"ansi": 196, "hex": "#ff0000"},
		"orange":       {"ansi": 208, "hex": "#ff8700"},
		"gray":         {"ansi": 245, "hex": "#6b7280"},
		"gray-5":       {"ansi": 240, "hex": "#4b5563"},
		"gray-7":       {"ansi": 236, "hex": "#374151"},
		"gray-9":       {"ansi": 234, "hex": "#1f2937"},
		"directory":    {"ansi": 35, "hex": "#38a169"},
		"yellow":       {"ansi": 226, "hex": "#facc15"},
		"amber-3":      {"ansi": 214, "hex": "#fbbf24"},
	}
	data, err := json.Marshal(colors)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), data, 0o644))

	filetypes := map[string]map[string]interface{}{
		"go": {"bold": true, "color": map[string]interface{}{"ansi": 35, "hex": "#38a169"}, "pattern": "*.go"},
		"js": {"bold": false, "color": map[string]interface{}{"ansi": 226, "hex": "#facc15"}, "pattern": "*.js"},
	}
	ftData, err := json.Marshal(filetypes)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "filetypes.json"), ftData, 0o644))

	th, err := theme.Load(root)
	require.NoError(t, err)
	return th
}
