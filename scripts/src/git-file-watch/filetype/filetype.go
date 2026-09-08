package filetype

import (
	"path/filepath"
	"strings"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/shebang"
)

// Result holds the resolved language and filetype key for a file.
type Result struct {
	Language    string
	FiletypeKey string
}

// pathPatterns maps path substrings to language/filetype for extensionless files.
var pathPatterns = []struct {
	contains    string
	language    string
	filetypeKey string
}{
	{"tools/term/zsh/config/functions/autoload/", "bash", "zsh"},
}

// interpreterMap maps shebang interpreter names to language/filetype.
var interpreterMap = map[string]struct {
	language    string
	filetypeKey string
}{
	"zsh":     {"bash", "zsh"},
	"bash":    {"bash", "sh"},
	"sh":      {"bash", "sh"},
	"python":  {"python", "py"},
	"python3": {"python", "py"},
	"node":    {"javascript", "js"},
	"ruby":    {"ruby", "rb"},
	"perl":    {"perl", "perl"},
}

// Resolve returns the language and filetype key for a file path and its first line.
// Resolution order: extension → path pattern → shebang.
// For files with extensions, Language is the raw extension — callers may remap it
// (e.g. highlight/loader.go remaps "js" → "javascript" for tree-sitter).
func Resolve(path string, firstLine string) Result {
	ext := strings.TrimPrefix(filepath.Ext(path), ".")

	if ext != "" {
		return Result{Language: ext, FiletypeKey: ext}
	}

	for _, p := range pathPatterns {
		if strings.Contains(path, p.contains) {
			return Result{Language: p.language, FiletypeKey: p.filetypeKey}
		}
	}

	if interp := shebang.Interpreter(firstLine); interp != "" {
		if entry, ok := interpreterMap[interp]; ok {
			return Result{Language: entry.language, FiletypeKey: entry.filetypeKey}
		}
	}

	return Result{}
}
