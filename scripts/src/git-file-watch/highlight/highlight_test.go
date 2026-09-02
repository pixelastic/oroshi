package highlight

import (
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
