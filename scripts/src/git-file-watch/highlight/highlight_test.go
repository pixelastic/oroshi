package highlight

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type stubColors struct{}

func (s stubColors) Hex(name string) string {
	defaults := map[string]string{
		"black":         "#0c0f15",
		"gray-3":        "#d1d5db",
		"keyword":       "#38a169",
		"boolean":       "#f59e0b",
		"yellow-3":      "#f6e05e",
		"variable-type": "#f87171",
		"function":      "#d69e2e",
		"orange":        "#ea580c",
		"key":           "#c4b5fd",
		"variable":      "#a78bfa",
		"constant":      "#ea580c",
		"red-3":         "#f87171",
		"string":        "#3182ce",
		"number":        "#3182ce",
		"comment":       "#6b7280",
		"punctuation":   "#0f766e",
	}
	if hex, ok := defaults[name]; ok {
		return hex
	}
	return "#ffffff"
}

const ansiEscape = "\033["

func containsANSI(s string) bool {
	return strings.Contains(s, ansiEscape)
}

// --- Syntax highlighting ---

func TestHighlightsGoSourceCode(t *testing.T) {
	h := New(stubColors{})
	code := "package main\n\nfunc main() {\n\tfmt.Println(\"hello\")\n}\n"
	lines := h.Highlight("main.go", code)

	require.Len(t, lines, 5)

	hasANSI := false
	for _, line := range lines {
		if containsANSI(line.Content) {
			hasANSI = true
			break
		}
	}
	assert.True(t, hasANSI, "Go code should contain ANSI escape sequences")
}

func TestHighlightsJavaScriptSourceCode(t *testing.T) {
	h := New(stubColors{})
	code := "const x = 42;\nconsole.log(x);\n"
	lines := h.Highlight("app.js", code)

	require.Len(t, lines, 2)

	hasANSI := false
	for _, line := range lines {
		if containsANSI(line.Content) {
			hasANSI = true
			break
		}
	}
	assert.True(t, hasANSI, "JavaScript code should contain ANSI escape sequences")
}

func TestReturnsUnstyledContentForUnknownFileTypes(t *testing.T) {
	h := New(stubColors{})
	content := "some random text\nanother line\n"
	lines := h.Highlight("file.unknownext", content)

	require.Len(t, lines, 2)
	for _, line := range lines {
		assert.False(t, containsANSI(line.Content), "unknown file type should not contain ANSI: %q", line.Content)
	}
}

// --- Caching ---

func TestCachesResultForUnchangedContent(t *testing.T) {
	h := New(stubColors{})
	code := "package main\n"
	first := h.Highlight("main.go", code)
	second := h.Highlight("main.go", code)

	require.Len(t, first, 1)
	require.Len(t, second, 1)
	assert.Equal(t, first[0].Content, second[0].Content)
}

func TestInvalidatesCacheWhenContentChanges(t *testing.T) {
	h := New(stubColors{})
	first := h.Highlight("main.go", "package main\n")
	second := h.Highlight("main.go", "package foo\n")

	require.Len(t, first, 1)
	require.Len(t, second, 1)
	assert.NotEqual(t, first[0].Content, second[0].Content)
}

// --- Routing helpers ---

func newRoutingColors() hexStub {
	return hexStub{
		// Tree-sitter keyword via syntax map
		"ts-keyword": "#ff0000",
		// Chroma buildStyle colors
		"gray-3":        "#d1d5db",
		"keyword":       "#38a169",
		"boolean":       "#f59e0b",
		"yellow-3":      "#f6e05e",
		"variable-type": "#f87171",
		"function":      "#d69e2e",
		"orange":        "#ea580c",
		"key":           "#c4b5fd",
		"variable":      "#a78bfa",
		"constant":      "#ea580c",
		"red-3":         "#f87171",
		"string":        "#3182ce",
		"number":        "#3182ce",
		"comment":       "#6b7280",
		"punctuation":   "#0f766e",
	}
}

func treeSitterDirs(t *testing.T) (string, string) {
	t.Helper()
	home, err := os.UserHomeDir()
	require.NoError(t, err)

	grammarDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/parser")
	queryDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/queries")

	if _, err := os.Stat(filepath.Join(grammarDir, "go.so")); os.IsNotExist(err) {
		t.Skip("nvim-treesitter go.so not found")
	}
	if _, err := os.Stat(filepath.Join(queryDir, "go/highlights.scm")); os.IsNotExist(err) {
		t.Skip("nvim-treesitter go highlights.scm not found")
	}

	return grammarDir, queryDir
}

// --- Routing ---

func TestUsesTreeSitterColorsWhenGrammarAvailable(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@keyword":  map[string]any{"color": "ts-keyword"},
			"@function": map[string]any{"color": "function"},
			"@string":   map[string]any{"color": "string"},
		},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)
	lines := h.Highlight("main.go", "package main\n")

	require.NotEmpty(t, lines)
	tsKeywordANSI := hexToANSI("#ff0000")
	found := false
	for _, line := range lines {
		if strings.Contains(line.Content, tsKeywordANSI) {
			found = true
			break
		}
	}
	assert.True(t, found, "Go file should use tree-sitter keyword color #ff0000")
}

func TestUsesChromaWhenNoTreeSitterGrammar(t *testing.T) {
	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "ts-keyword"}},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, t.TempDir(), t.TempDir())
	lines := h.Highlight("app.py", "def hello():\n    pass\n")

	require.NotEmpty(t, lines)
	chromaKeywordANSI := hexToANSI("#38a169")
	found := false
	for _, line := range lines {
		if strings.Contains(line.Content, chromaKeywordANSI) {
			found = true
			break
		}
	}
	assert.True(t, found, "Python file should use Chroma keyword color when no tree-sitter grammar")
}

func TestBothPathsProduceNonEmptyOutput(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "keyword"}},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)

	goLines := h.Highlight("main.go", "package main\n")
	assert.NotEmpty(t, goLines, "tree-sitter path should produce lines")

	confLines := h.Highlight("app.conf", "key = value\n")
	assert.NotEmpty(t, confLines, "Chroma fallback path should produce lines")
}

func TestUnknownFileTypeProducesPlainTextWithTreeSitter(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "keyword"}},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)
	lines := h.Highlight("file.unknownext", "some random text\nanother line\n")

	require.Len(t, lines, 2)
	for _, line := range lines {
		assert.False(t, containsANSI(line.Content), "unknown file type should not contain ANSI: %q", line.Content)
	}
}

// --- Caching (tree-sitter path) ---

func TestCachesTreeSitterResultForUnchangedContent(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "keyword"}},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)

	code := "package main\n"
	first := h.Highlight("main.go", code)
	second := h.Highlight("main.go", code)

	require.NotEmpty(t, first)
	require.NotEmpty(t, second)
	assert.Equal(t, first[0].Content, second[0].Content)
}

func TestInvalidatesTreeSitterCacheWhenContentChanges(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "keyword"}},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)

	first := h.Highlight("main.go", "package main\n")
	second := h.Highlight("main.go", "package foo\n")

	require.NotEmpty(t, first)
	require.NotEmpty(t, second)
	assert.NotEqual(t, first[0].Content, second[0].Content)
}

// --- Hot-reload ---

func TestCacheIsEmptyAfterInvalidateCache(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "keyword"}},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)

	h.Highlight("main.go", "package main\n")
	require.NotEmpty(t, h.cache)

	h.InvalidateCache()
	assert.Empty(t, h.cache)
}

func TestReloadSyntaxMapReturnsErrorWhenFileMissing(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	syntaxMapPath := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "keyword"}},
	})
	colors := newRoutingColors()
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)

	// Remove the file to simulate a temporary write
	require.NoError(t, os.Remove(syntaxMapPath))

	err := h.ReloadSyntaxMap()
	assert.Error(t, err)

	// Existing syntax map should still be intact — highlighting still works
	lines := h.Highlight("main.go", "package main\n")
	assert.NotEmpty(t, lines)
}

func TestHighlightUsesNewMappingAfterReloadSyntaxMap(t *testing.T) {
	grammarDir, queryDir := treeSitterDirs(t)

	// Write syntax map with color-a for keywords
	dir := t.TempDir()
	syntaxMapPath := filepath.Join(dir, "neovim-syntax.json")
	raw, err := json.Marshal(map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "color-a"}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(syntaxMapPath, raw, 0o644))

	colors := hexStub{
		"color-a":      "#ff0000",
		"color-b":      "#00ff00",
		"gray-3":       "#d1d5db",
		"keyword":      "#38a169",
		"boolean":      "#f59e0b",
		"yellow-3":     "#f6e05e",
		"variable-type": "#f87171",
		"function":     "#d69e2e",
		"orange":       "#ea580c",
		"key":          "#c4b5fd",
		"variable":     "#a78bfa",
		"constant":     "#ea580c",
		"red-3":        "#f87171",
		"string":       "#3182ce",
		"number":       "#3182ce",
		"comment":      "#6b7280",
		"punctuation":  "#0f766e",
	}
	h := NewWithTreeSitter(colors, syntaxMapPath, grammarDir, queryDir)

	code := "package main\n"
	firstLines := h.Highlight("main.go", code)
	require.NotEmpty(t, firstLines)
	assert.True(t, strings.Contains(firstLines[0].Content, hexToANSI("#ff0000")),
		"first highlight should use color-a (#ff0000)")

	// Overwrite syntax map with color-b for keywords
	raw, err = json.Marshal(map[string]map[string]any{
		"default": {"@keyword": map[string]any{"color": "color-b"}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(syntaxMapPath, raw, 0o644))

	require.NoError(t, h.ReloadSyntaxMap())
	h.InvalidateCache()

	secondLines := h.Highlight("main.go", code)
	require.NotEmpty(t, secondLines)
	assert.True(t, strings.Contains(secondLines[0].Content, hexToANSI("#00ff00")),
		"second highlight should use color-b (#00ff00)")
}
