package highlight

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"unsafe"

	"github.com/ebitengine/purego"
	tree_sitter "github.com/tree-sitter/go-tree-sitter"
)

// GrammarDir is the default directory for nvim-treesitter compiled grammar .so files.
var GrammarDir = filepath.Join(os.Getenv("HOME"), ".local/share/nvim/lazy/nvim-treesitter/parser")

// QueryDir is the default directory for nvim-treesitter highlight query files.
var QueryDir = filepath.Join(os.Getenv("HOME"), ".local/share/nvim/lazy/nvim-treesitter/queries")

// extensionToLanguage maps file extensions to tree-sitter language names.
var extensionToLanguage = map[string]string{
	"js":   "javascript",
	"ts":   "typescript",
	"tsx":  "tsx",
	"py":   "python",
	"rb":   "ruby",
	"rs":   "rust",
	"yml":  "yaml",
	"md":   "markdown",
	"sh":   "bash",
	"zsh":  "bash",
	"go":   "go",
	"lua":  "lua",
	"css":  "css",
	"html": "html",
	"json": "json",
	"toml": "toml",
	"xml":  "xml",
	"vue":  "vue",
}

// LoadedLanguage holds a tree-sitter grammar and its highlight query.
type LoadedLanguage struct {
	Language       *tree_sitter.Language
	HighlightQuery []byte
}

// Loader resolves and loads tree-sitter grammars and highlight queries.
type Loader struct {
	parserDir string
	queryDir  string
}

// NewLoader creates a Loader that looks for grammars in parserDir and queries in queryDir.
func NewLoader(parserDir string, queryDir string) *Loader {
	return &Loader{
		parserDir: parserDir,
		queryDir:  queryDir,
	}
}

// LanguageFromExtension returns the tree-sitter language name for a filepath.
func LanguageFromExtension(filepath string) string {
	ext := strings.TrimPrefix(extensionForFile(filepath), ".")
	if lang, ok := extensionToLanguage[ext]; ok {
		return lang
	}
	return ext
}

// Load resolves the language for filepath and loads its grammar and highlight query.
// Returns nil if either the grammar .so or highlights.scm is missing.
func (l *Loader) Load(path string) *LoadedLanguage {
	lang := LanguageFromExtension(path)

	grammarPath := filepath.Join(l.parserDir, lang+".so")
	if _, err := os.Stat(grammarPath); err != nil {
		return nil
	}

	queryPath := filepath.Join(l.queryDir, lang, "highlights.scm")
	queryContent, err := os.ReadFile(queryPath)
	if err != nil {
		return nil
	}

	language, err := loadGrammar(grammarPath, lang)
	if err != nil {
		return nil
	}

	return &LoadedLanguage{
		Language:       language,
		HighlightQuery: queryContent,
	}
}

func loadGrammar(path string, lang string) (*tree_sitter.Language, error) {
	lib, err := purego.Dlopen(path, purego.RTLD_LAZY)
	if err != nil {
		return nil, fmt.Errorf("opening %s: %w", path, err)
	}

	symbolName := "tree_sitter_" + lang
	ptr, err := purego.Dlsym(lib, symbolName)
	if err != nil {
		return nil, fmt.Errorf("finding symbol %s: %w", symbolName, err)
	}

	// The symbol is a function pointer that returns *TSLanguage.
	// Call it via purego to get the language pointer.
	var languageFunc func() unsafe.Pointer
	purego.RegisterFunc(&languageFunc, ptr)

	return tree_sitter.NewLanguage(languageFunc()), nil
}

func extensionForFile(path string) string {
	return filepath.Ext(path)
}
