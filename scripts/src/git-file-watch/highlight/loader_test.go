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
