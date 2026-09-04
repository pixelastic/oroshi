package highlight

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func loadGoGrammar(t *testing.T) *LoadedLanguage {
	t.Helper()
	home, err := os.UserHomeDir()
	require.NoError(t, err)

	parserDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/parser")
	queryDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/queries")

	if _, err := os.Stat(filepath.Join(parserDir, "go.so")); os.IsNotExist(err) {
		t.Skip("nvim-treesitter go.so not found")
	}
	if _, err := os.Stat(filepath.Join(queryDir, "go/highlights.scm")); os.IsNotExist(err) {
		t.Skip("nvim-treesitter go highlights.scm not found")
	}

	loader := NewLoader(parserDir, queryDir)
	loaded := loader.Load("main.go")
	require.NotNil(t, loaded)
	return loaded
}

func testSyntaxMap(t *testing.T, overrides map[string]map[string]any) *SyntaxMap {
	t.Helper()
	data := map[string]map[string]any{
		"default": {
			"@keyword":  map[string]any{"color": "keyword"},
			"@function": map[string]any{"color": "function"},
			"@string":   map[string]any{"color": "string"},
			"@comment":  map[string]any{"color": "comment"},
		},
	}
	for k, v := range overrides {
		data[k] = v
	}
	path := writeSyntaxJSON(t, data)
	colors := hexStub{
		"keyword":  "#38a169",
		"function": "#d69e2e",
		"string":   "#3182ce",
		"comment":  "#6b7280",
	}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)
	return syntaxMap
}

func hexToANSI(hex string) string {
	var r, g, b int
	_, _ = fmt.Sscanf(hex, "#%02x%02x%02x", &r, &g, &b)
	return fmt.Sprintf("\033[38;2;%d;%d;%dm", r, g, b)
}

// --- Tree-sitter rendering ---

func TestGoSourceProducesFunctionColorInOutput(t *testing.T) {
	loaded := loadGoGrammar(t)
	syntaxMap := testSyntaxMap(t, nil)

	source := []byte("package main\n\nfunc main() {\n}\n")
	lines := HighlightTreeSitter(loaded, "go", source, syntaxMap)

	functionANSI := hexToANSI("#d69e2e")
	found := false
	for _, line := range lines {
		if strings.Contains(line.Content, functionANSI) {
			found = true
			break
		}
	}
	assert.True(t, found, "output should contain ANSI color for function: %s", functionANSI)
}

func TestGoSourceProducesKeywordColorInOutput(t *testing.T) {
	loaded := loadGoGrammar(t)
	syntaxMap := testSyntaxMap(t, nil)

	source := []byte("package main\n\nfunc main() {\n}\n")
	lines := HighlightTreeSitter(loaded, "go", source, syntaxMap)

	keywordANSI := hexToANSI("#38a169")
	found := false
	for _, line := range lines {
		if strings.Contains(line.Content, keywordANSI) {
			found = true
			break
		}
	}
	assert.True(t, found, "output should contain ANSI color for keyword: %s", keywordANSI)
}

func TestBoldModifierAppliedAsANSIBold(t *testing.T) {
	loaded := loadGoGrammar(t)
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@keyword": map[string]any{"color": "keyword", "bold": true},
		},
	})
	colors := hexStub{"keyword": "#38a169"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	source := []byte("package main\n")
	lines := HighlightTreeSitter(loaded, "go", source, syntaxMap)

	found := false
	for _, line := range lines {
		if strings.Contains(line.Content, "\033[1;") || strings.Contains(line.Content, "\033[1m") {
			found = true
			break
		}
	}
	assert.True(t, found, "output should contain ANSI bold escape code")
}

func TestItalicModifierAppliedAsANSIItalic(t *testing.T) {
	loaded := loadGoGrammar(t)
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@comment": map[string]any{"color": "comment", "italic": true},
		},
	})
	colors := hexStub{"comment": "#6b7280"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	source := []byte("// hello\npackage main\n")
	lines := HighlightTreeSitter(loaded, "go", source, syntaxMap)

	found := false
	for _, line := range lines {
		if strings.Contains(line.Content, "\033[3;") || strings.Contains(line.Content, "\033[3m") {
			found = true
			break
		}
	}
	assert.True(t, found, "output should contain ANSI italic escape code")
}

func TestTabsExpandedToFourSpaces(t *testing.T) {
	loaded := loadGoGrammar(t)
	syntaxMap := testSyntaxMap(t, nil)

	source := []byte("package main\n\nfunc main() {\n\tx := 1\n}\n")
	lines := HighlightTreeSitter(loaded, "go", source, syntaxMap)

	require.True(t, len(lines) >= 4)
	// Strip ANSI to check content
	stripped := stripANSI(lines[3].Content)
	assert.Contains(t, stripped, "    x", "tabs should be expanded to 4 spaces")
	assert.NotContains(t, stripped, "\t", "no literal tabs should remain")
}

func TestMultiLineInputProducesCorrectNumberOfStyledLines(t *testing.T) {
	loaded := loadGoGrammar(t)
	syntaxMap := testSyntaxMap(t, nil)

	source := []byte("package main\n\nfunc main() {\n\tfmt.Println(\"hello\")\n}\n")
	lines := HighlightTreeSitter(loaded, "go", source, syntaxMap)

	assert.Len(t, lines, 5)
}

func stripANSI(s string) string {
	result := strings.Builder{}
	i := 0
	for i < len(s) {
		if s[i] == '\033' && i+1 < len(s) && s[i+1] == '[' {
			j := i + 2
			for j < len(s) && s[j] != 'm' {
				j++
			}
			if j < len(s) {
				i = j + 1
				continue
			}
		}
		result.WriteByte(s[i])
		i++
	}
	return result.String()
}

// --- General predicates ---

func TestSkipsMatchesWithUnevaluatedGeneralPredicates(t *testing.T) {
	home, err := os.UserHomeDir()
	require.NoError(t, err)

	parserDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/parser")
	queryDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/queries")

	if _, err := os.Stat(filepath.Join(parserDir, "javascript.so")); os.IsNotExist(err) {
		t.Skip("nvim-treesitter javascript.so not found")
	}

	loader := NewLoader(parserDir, queryDir)
	loaded := loader.Load("app.js")
	require.NotNil(t, loaded)

	// The syntax map has @variable (purple) and Constant (orange).
	// Without predicate filtering, #lua-match? patterns cause all identifiers
	// to match @constant, painting them orange instead of purple.
	path := writeSyntaxJSON(t, map[string]map[string]any{
		"default": {
			"@variable": map[string]any{"color": "variable"},
			"Constant":  map[string]any{"color": "constant"},
		},
	})
	colors := hexStub{"variable": "#a78bfa", "constant": "#ea580c"}
	syntaxMap, err := LoadSyntaxMap(path, colors)
	require.NoError(t, err)

	source := []byte("const message = 'hello';\n")
	lines := HighlightTreeSitter(loaded, "javascript", source, syntaxMap)

	variableANSI := hexToANSI("#a78bfa")
	constantANSI := hexToANSI("#ea580c")

	hasVariable := false
	hasConstant := false
	for _, line := range lines {
		if strings.Contains(line.Content, variableANSI) {
			hasVariable = true
		}
		if strings.Contains(line.Content, constantANSI) {
			hasConstant = true
		}
	}
	assert.True(t, hasVariable, "identifiers should use @variable color (purple), not @constant")
	assert.False(t, hasConstant, "identifiers should not use Constant color (orange) from unfiltered #lua-match?")
}

// --- Edge cases ---

func TestHandlesEmptySourceInput(t *testing.T) {
	loaded := loadGoGrammar(t)
	syntaxMap := testSyntaxMap(t, nil)

	lines := HighlightTreeSitter(loaded, "go", []byte(""), syntaxMap)
	assert.Nil(t, lines)
}

func TestSyntaxMapResolvesCaptureNamesFromJSON(t *testing.T) {
	oroshiRoot := os.Getenv("OROSHI_ROOT")
	if oroshiRoot == "" {
		t.Skip("OROSHI_ROOT not set")
	}

	syntaxPath := filepath.Join(oroshiRoot, "tools/term/zsh/config/theming/dist/neovim-syntax.json")
	raw, err := os.ReadFile(syntaxPath)
	require.NoError(t, err)

	var data map[string]map[string]json.RawMessage
	require.NoError(t, json.Unmarshal(raw, &data))

	defaultSection, ok := data["default"]
	require.True(t, ok, "neovim-syntax.json should have a default section")
	assert.NotEmpty(t, defaultSection, "default section should not be empty")
}
