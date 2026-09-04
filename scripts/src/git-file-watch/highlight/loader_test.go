package highlight

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Language resolution ---

func TestResolvesGoFilepathToGoLanguage(t *testing.T) {
	result := LanguageFromExtension("main.go")
	assert.Equal(t, "go", result)
}

func TestResolvesJsFilepathToJavascriptLanguage(t *testing.T) {
	result := LanguageFromExtension("app.js")
	assert.Equal(t, "javascript", result)
}

func TestResolvesTypescriptFilepathToTypescriptLanguage(t *testing.T) {
	result := LanguageFromExtension("index.ts")
	assert.Equal(t, "typescript", result)
}

func TestResolvesUnknownExtensionToExtensionItself(t *testing.T) {
	result := LanguageFromExtension("file.gleam")
	assert.Equal(t, "gleam", result)
}

// --- Missing resources ---

func TestReturnsNilWhenGrammarFileIsMissing(t *testing.T) {
	root := t.TempDir()
	queryDir := filepath.Join(root, "queries")
	langDir := filepath.Join(queryDir, "go")
	require.NoError(t, os.MkdirAll(langDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(langDir, "highlights.scm"), []byte("(comment) @comment"), 0o644))

	parserDir := filepath.Join(root, "parser")
	require.NoError(t, os.MkdirAll(parserDir, 0o755))
	// no .so file

	loader := NewLoader(parserDir, queryDir)
	result := loader.Load("main.go")
	assert.Nil(t, result)
}

func TestReturnsNilWhenHighlightQueryIsMissing(t *testing.T) {
	root := t.TempDir()
	parserDir := filepath.Join(root, "parser")
	require.NoError(t, os.MkdirAll(parserDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(parserDir, "go.so"), []byte("fake"), 0o644))

	queryDir := filepath.Join(root, "queries")
	require.NoError(t, os.MkdirAll(queryDir, 0o755))
	// no highlights.scm

	loader := NewLoader(parserDir, queryDir)
	result := loader.Load("main.go")
	assert.Nil(t, result)
}

// --- Inherits directive ---

func TestResolvesInheritsDirectiveInHighlightQuery(t *testing.T) {
	root := t.TempDir()
	queryDir := filepath.Join(root, "queries")

	// ecma base query
	ecmaDir := filepath.Join(queryDir, "ecma")
	require.NoError(t, os.MkdirAll(ecmaDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(ecmaDir, "highlights.scm"), []byte("(identifier) @variable\n"), 0o644))

	// jsx base query
	jsxDir := filepath.Join(queryDir, "jsx")
	require.NoError(t, os.MkdirAll(jsxDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(jsxDir, "highlights.scm"), []byte("(jsx_element) @tag\n"), 0o644))

	// javascript query that inherits both
	jsDir := filepath.Join(queryDir, "javascript")
	require.NoError(t, os.MkdirAll(jsDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(jsDir, "highlights.scm"),
		[]byte("; inherits: ecma,jsx\n(formal_parameters (identifier) @variable.parameter)\n"), 0o644))

	result := resolveInherits(filepath.Join(jsDir, "highlights.scm"), queryDir)

	assert.Contains(t, string(result), "(identifier) @variable", "should contain ecma content")
	assert.Contains(t, string(result), "(jsx_element) @tag", "should contain jsx content")
	assert.Contains(t, string(result), "(formal_parameters", "should contain own content")
	assert.NotContains(t, string(result), "; inherits:", "should strip the inherits directive")
}

func TestReturnsOwnContentWhenNoInheritsDirective(t *testing.T) {
	root := t.TempDir()
	queryDir := filepath.Join(root, "queries")
	goDir := filepath.Join(queryDir, "go")
	require.NoError(t, os.MkdirAll(goDir, 0o755))
	content := "(package_clause) @keyword\n"
	require.NoError(t, os.WriteFile(filepath.Join(goDir, "highlights.scm"), []byte(content), 0o644))

	result := resolveInherits(filepath.Join(goDir, "highlights.scm"), queryDir)
	assert.Equal(t, content, string(result))
}

func TestResolvesRecursiveInheritsDirective(t *testing.T) {
	root := t.TempDir()
	queryDir := filepath.Join(root, "queries")

	// base query
	baseDir := filepath.Join(queryDir, "base")
	require.NoError(t, os.MkdirAll(baseDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(baseDir, "highlights.scm"), []byte("(comment) @comment\n"), 0o644))

	// ecma inherits base
	ecmaDir := filepath.Join(queryDir, "ecma")
	require.NoError(t, os.MkdirAll(ecmaDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(ecmaDir, "highlights.scm"),
		[]byte("; inherits: base\n(identifier) @variable\n"), 0o644))

	// js inherits ecma
	jsDir := filepath.Join(queryDir, "javascript")
	require.NoError(t, os.MkdirAll(jsDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(jsDir, "highlights.scm"),
		[]byte("; inherits: ecma\n(formal_parameters (identifier) @variable.parameter)\n"), 0o644))

	result := resolveInherits(filepath.Join(jsDir, "highlights.scm"), queryDir)

	assert.Contains(t, string(result), "(comment) @comment", "should contain base content transitively")
	assert.Contains(t, string(result), "(identifier) @variable", "should contain ecma content")
	assert.Contains(t, string(result), "(formal_parameters", "should contain own content")
}

func TestSkipsMissingParentInInheritsDirective(t *testing.T) {
	root := t.TempDir()
	queryDir := filepath.Join(root, "queries")

	jsDir := filepath.Join(queryDir, "javascript")
	require.NoError(t, os.MkdirAll(jsDir, 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(jsDir, "highlights.scm"),
		[]byte("; inherits: nonexistent\n(identifier) @variable\n"), 0o644))

	result := resolveInherits(filepath.Join(jsDir, "highlights.scm"), queryDir)

	assert.Contains(t, string(result), "(identifier) @variable", "own content should still be present")
	assert.NotContains(t, string(result), "inherits", "inherits directive should be stripped")
}

// --- Grammar loading ---

func TestLoadsGrammarAndQueryFromNvimTreesitter(t *testing.T) {
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
	result := loader.Load("main.go")

	require.NotNil(t, result)
	assert.NotNil(t, result.Language, "grammar language pointer should not be nil")
	assert.NotEmpty(t, result.HighlightQuery, "highlight query content should not be empty")
}
