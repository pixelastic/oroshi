package highlight

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const ansiEscape = "\033["

func containsANSI(s string) bool {
	return strings.Contains(s, ansiEscape)
}

// --- Syntax highlighting ---

func TestHighlightsGoSourceCode(t *testing.T) {
	h := New()
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
	h := New()
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
	h := New()
	content := "some random text\nanother line\n"
	lines := h.Highlight("file.unknownext", content)

	require.Len(t, lines, 2)
	for _, line := range lines {
		assert.False(t, containsANSI(line.Content), "unknown file type should not contain ANSI: %q", line.Content)
	}
}

// --- Caching ---

func TestCachesResultForUnchangedContent(t *testing.T) {
	h := New()
	code := "package main\n"
	first := h.Highlight("main.go", code)
	second := h.Highlight("main.go", code)

	require.Len(t, first, 1)
	require.Len(t, second, 1)
	assert.Equal(t, first[0].Content, second[0].Content)
}

func TestInvalidatesCacheWhenContentChanges(t *testing.T) {
	h := New()
	first := h.Highlight("main.go", "package main\n")
	second := h.Highlight("main.go", "package foo\n")

	require.Len(t, first, 1)
	require.Len(t, second, 1)
	assert.NotEqual(t, first[0].Content, second[0].Content)
}
