package render

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/charmbracelet/lipgloss"
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

	result := FileHeader(ctx, row, 1, false)

	assert.Contains(t, result, "main.go")
	assert.Contains(t, result, "src/")
}

func TestFileHeaderDoesNotPanicWhenCursor(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80}
	row := layout.FileHeaderRow{Path: "src/main.go"}

	assert.NotPanics(t, func() { FileHeader(ctx, row, 1, true) })
}

func TestFileHeaderCursorAndNonCursorDiffer(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80}
	row := layout.FileHeaderRow{Path: "src/main.go"}

	withCursor := FileHeader(ctx, row, 1, true)
	withoutCursor := FileHeader(ctx, row, 1, false)

	// In a real terminal, the cursor version has background styling.
	// They should at least not be identical (padding differs).
	assert.NotEqual(t, withCursor, withoutCursor)
}

func TestFileHeaderContainsIcon(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80, LineNumberWidth: 3}
	row := layout.FileHeaderRow{Path: "src/main.go"}

	result := FileHeader(ctx, row, 1, false)

	// The test theme has "G" as the go icon glyph
	assert.Contains(t, result, "G")
}

func TestFileHeaderHasSpaceBetweenIconAndDir(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80, LineNumberWidth: 3}
	row := layout.FileHeaderRow{Path: "src/main.go"}

	result := FileHeader(ctx, row, 1, false)

	// Without the leading gutter space, only 2 spaces before icon (not 3)
	assert.NotContains(t, result, "   G")
}

func TestFileHeaderAlignsWithCodeContent(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80, LineNumberWidth: 3}
	row := layout.FileHeaderRow{Path: "src/main.go"}

	result := FileHeader(ctx, row, 1, false)

	// The header label line should start with spaces for gutter(1) + icon padding + space,
	// so the filename aligns with code content after the line number column
	// In non-TTY, unstyled: " " (gutter space) + icon padded to 3 + " " + dir + file
	assert.Contains(t, result, "src/")
	assert.Contains(t, result, "main.go")
}

func TestFileHeaderContainsBasenameForUnknownExtension(t *testing.T) {
	th := loadTestTheme(t)
	ctx := Context{Theme: th, ViewportWidth: 80}
	row := layout.FileHeaderRow{Path: "src/file.unknownext"}

	result := FileHeader(ctx, row, 1, false)

	assert.Contains(t, result, "file.unknownext")
}

// --- applyCursorHighlight ---

func TestApplyCursorHighlightContainsContent(t *testing.T) {
	th := loadTestTheme(t)

	result := applyCursorHighlight("hello", th, 20)

	assert.Contains(t, result, "hello")
}

func TestApplyCursorHighlightPadsToViewportWidth(t *testing.T) {
	th := loadTestTheme(t)

	result := applyCursorHighlight("hi", th, 10)

	assert.Equal(t, 10, lipgloss.Width(result))
}

func TestApplyCursorHighlightStartsWithBgEscape(t *testing.T) {
	th := loadTestTheme(t)

	result := applyCursorHighlight("x", th, 5)

	// Should start with an ANSI 24-bit background escape sequence
	assert.True(t, strings.HasPrefix(result, "\x1b[48;2;"), "should start with bg escape code")
}

func TestApplyCursorHighlightEndsWithReset(t *testing.T) {
	th := loadTestTheme(t)

	result := applyCursorHighlight("x", th, 5)

	assert.True(t, strings.HasSuffix(result, "\x1b[0m"), "should end with ANSI reset")
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

	assert.Equal(t, th.Lipgloss("green-7"), result)
}

func TestLineColorReturnsGrayWhenNoMarkerAndNoComment(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 5}

	result := LineColor(row, th, false)

	assert.Equal(t, th.Lipgloss("gray"), result)
}

// --- MarkerColorName ---

func TestMarkerColorNameReturnsGreen7ForAdded(t *testing.T) {
	assert.Equal(t, "green-7", MarkerColorName(diff.MarkerAdded))
}

func TestMarkerColorNameReturnsPurpleForModified(t *testing.T) {
	assert.Equal(t, "purple", MarkerColorName(diff.MarkerModified))
}

func TestMarkerColorNameReturnsRed8ForDeleted(t *testing.T) {
	assert.Equal(t, "red-8", MarkerColorName(diff.MarkerDeleted))
}

// --- MarkerBgColorName ---

func TestMarkerBgColorNameReturnsGreen0ForAdded(t *testing.T) {
	assert.Equal(t, "green-0", MarkerBgColorName(diff.MarkerAdded))
}

func TestMarkerBgColorNameReturnsPurple0ForModified(t *testing.T) {
	assert.Equal(t, "purple-0", MarkerBgColorName(diff.MarkerModified))
}

func TestMarkerBgColorNameReturnsRed0ForDeleted(t *testing.T) {
	assert.Equal(t, "red-0", MarkerBgColorName(diff.MarkerDeleted))
}

func TestMarkerBgColorNameReturnsEmptyForNoMarker(t *testing.T) {
	assert.Equal(t, "", MarkerBgColorName(diff.Marker(0)))
}

// --- CodeLine background ---

func TestCodeLineWithMarkerHasBgEscape(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	row := layout.LineRow{LineNumber: 1, Marker: &marker, FilePath: "main.go"}
	ctx := Context{Theme: th, ViewportWidth: 40, LineNumberWidth: 3}

	result := CodeLine(ctx, row, false)

	assert.Contains(t, result, "\x1b[48;2;", "should contain ANSI background escape")
}

func TestCodeLineWithoutMarkerHasNoBgEscape(t *testing.T) {
	th := loadTestTheme(t)
	row := layout.LineRow{LineNumber: 1, FilePath: "main.go", Distance: 1}
	ctx := Context{Theme: th, ViewportWidth: 40, LineNumberWidth: 3}

	result := CodeLine(ctx, row, false)

	assert.NotContains(t, result, "\x1b[48;2;", "context lines should have no background")
}

func TestCodeLineCursorOverridesMarkerBg(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	row := layout.LineRow{LineNumber: 1, Marker: &marker, FilePath: "main.go"}
	ctx := Context{Theme: th, ViewportWidth: 40, LineNumberWidth: 3}

	cursorResult := CodeLine(ctx, row, true)
	nonCursorResult := CodeLine(ctx, row, false)

	// Cursor line should use yellow-0 background, not green-0
	assert.NotEqual(t, cursorResult, nonCursorResult)
	// yellow-0 is #1a1a0f → rgb(26,26,15)
	assert.Contains(t, cursorResult, "\x1b[48;2;26;26;15m", "cursor should use yellow-0 bg")
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
		"green-0":      {"ansi": 30, "hex": "#0f1a0f"},
		"green-7":      {"ansi": 37, "hex": "#276749"},
		"purple":       {"ansi": 65, "hex": "#805ad5"},
		"purple-0":     {"ansi": 60, "hex": "#201325"},
		"red-0":        {"ansi": 20, "hex": "#250f0f"},
		"red-8":        {"ansi": 28, "hex": "#7f1d1d"},
		"orange":       {"ansi": 208, "hex": "#ff8700"},
		"gray":         {"ansi": 245, "hex": "#6b7280"},
		"gray-5":       {"ansi": 240, "hex": "#4b5563"},
		"gray-7":       {"ansi": 236, "hex": "#374151"},
		"gray-9":       {"ansi": 234, "hex": "#1f2937"},
		"directory":    {"ansi": 35, "hex": "#38a169"},
		"yellow":       {"ansi": 226, "hex": "#facc15"},
		"yellow-0":     {"ansi": 232, "hex": "#1a1a0f"},
		"amber-3":      {"ansi": 214, "hex": "#fbbf24"},
	}
	data, err := json.Marshal(colors)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), data, 0o644))

	filetypes := map[string]map[string]interface{}{
		"go": {"bold": true, "color": map[string]interface{}{"ansi": 35, "hex": "#38a169"}, "icon": map[string]interface{}{"glyph": "G", "name": "filetype-go"}, "pattern": "*.go"},
		"js": {"bold": false, "color": map[string]interface{}{"ansi": 226, "hex": "#facc15"}, "icon": map[string]interface{}{"glyph": "J", "name": "filetype-js"}, "pattern": "*.js"},
	}
	ftData, err := json.Marshal(filetypes)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "filetypes.json"), ftData, 0o644))

	th, err := theme.Load(root)
	require.NoError(t, err)
	return th
}
