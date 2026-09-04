package highlight

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func writeSyntaxJSON(t *testing.T, data map[string]map[string]any) string {
	t.Helper()
	dir := t.TempDir()
	path := filepath.Join(dir, "neovim-syntax.json")
	raw, err := json.Marshal(data)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(path, raw, 0o644))
	return path
}

type hexStub map[string]string

func (s hexStub) Hex(name string) string {
	if hex, ok := s[name]; ok {
		return hex
	}
	return ""
}

// --- Syntax map resolution ---

func TestResolvesDefaultCaptureToCorrectColor(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@keyword": map[string]any{"color": "keyword"},
		},
	})
	colors := hexStub{"keyword": "#38a169"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "keyword")
	assert.Equal(t, "#38a169", style.ColorHex)
}

func TestLanguageOverrideTakesPrecedenceOverDefault(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@keyword": map[string]any{"color": "keyword"},
		},
		"go": {
			"@keyword": map[string]any{"color": "orange"},
		},
	})
	colors := hexStub{"keyword": "#38a169", "orange": "#ea580c"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "keyword")
	assert.Equal(t, "#ea580c", style.ColorHex)
}

func TestCaptureHierarchyFallbackWorks(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@keyword": map[string]any{"color": "keyword"},
		},
	})
	colors := hexStub{"keyword": "#38a169"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "keyword.function")
	assert.Equal(t, "#38a169", style.ColorHex)
}

func TestUnknownCaptureReturnsEmpty(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {},
	})
	syntaxMap, err := LoadSyntaxMap(path, hexStub{})
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "nonexistent")
	assert.Empty(t, style.ColorHex)
	assert.False(t, style.Bold)
	assert.False(t, style.Italic)
}

func TestFallsBackToVimHighlightGroupWhenNoCaptureMatch(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"Comment": map[string]any{"color": "comment"},
		},
	})
	colors := hexStub{"comment": "#6b7280"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "comment")
	assert.Equal(t, "#6b7280", style.ColorHex)
}

func TestFallsBackToVimGroupAfterDotHierarchyExhausted(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"Keyword": map[string]any{"color": "keyword"},
		},
	})
	colors := hexStub{"keyword": "#38a169"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "keyword.function")
	assert.Equal(t, "#38a169", style.ColorHex)
}

func TestTreeSitterCaptureStillTakesPriorityOverVimGroup(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@comment": map[string]any{"color": "ts-comment"},
			"Comment":  map[string]any{"color": "vim-comment"},
		},
	})
	colors := hexStub{"ts-comment": "#111111", "vim-comment": "#222222"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "comment")
	assert.Equal(t, "#111111", style.ColorHex, "@comment should win over Comment")
}

func TestVimGroupFallbackPreservesBoldAndItalic(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"Number": map[string]any{"color": "number", "bold": true},
		},
	})
	colors := hexStub{"number": "#3182ce"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "number")
	assert.Equal(t, "#3182ce", style.ColorHex)
	assert.True(t, style.Bold)
}

func TestVimGroupFallbackReturnsEmptyWhenNoMatch(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"Comment": map[string]any{"color": "comment"},
		},
	})
	colors := hexStub{"comment": "#6b7280"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "nonexistent")
	assert.Empty(t, style.ColorHex)
}

func TestBoldAndItalicModifiersAreResolvedCorrectly(t *testing.T) {
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@comment": map[string]any{
				"color":  "comment",
				"bold":   true,
				"italic": true,
			},
		},
	})
	colors := hexStub{"comment": "#6b7280"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	style := syntaxMap.Resolve("go", "comment")
	assert.Equal(t, "#6b7280", style.ColorHex)
	assert.True(t, style.Bold)
	assert.True(t, style.Italic)
}
