package highlight

import (
	"bytes"
	"strings"

	"github.com/alecthomas/chroma/v2"
	"github.com/alecthomas/chroma/v2/formatters"
	"github.com/alecthomas/chroma/v2/lexers"
)

// StyledLine holds the ANSI-styled content for a single line.
type StyledLine struct {
	Content string
}

type cacheEntry struct {
	content string
	lines   []StyledLine
}

// Highlighter applies syntax highlighting with caching.
// It tries tree-sitter first when a loader and syntax map are available,
// falling back to Chroma otherwise.
type Highlighter struct {
	cache     map[string]cacheEntry
	style     *chroma.Style
	loader    *Loader
	syntaxMap *SyntaxMap
}

// ColorProvider returns a hex color for a named token.
type ColorProvider interface {
	Hex(name string) string
}

// New creates a Highlighter using Chroma only.
func New(colors ColorProvider) *Highlighter {
	return &Highlighter{
		cache: make(map[string]cacheEntry),
		style: buildStyle(colors),
	}
}

// NewWithTreeSitter creates a Highlighter that tries tree-sitter first and
// falls back to Chroma when no grammar is available.
func NewWithTreeSitter(colors ColorProvider, syntaxMapPath string, grammarDir string, queryDir string) *Highlighter {
	h := &Highlighter{
		cache: make(map[string]cacheEntry),
		style: buildStyle(colors),
	}

	syntaxMap, err := LoadSyntaxMap(syntaxMapPath, colors)
	if err != nil {
		return h
	}
	h.syntaxMap = syntaxMap
	h.loader = NewLoader(grammarDir, queryDir)

	return h
}

// Highlight returns syntax-highlighted lines for the given file content.
// It tries tree-sitter when a grammar is available, falling back to Chroma.
func (h *Highlighter) Highlight(filepath string, content string) []StyledLine {
	if cached, ok := h.cache[filepath]; ok && cached.content == content {
		return cached.lines
	}

	lines := h.highlightWithTreeSitter(filepath, content)
	if lines == nil {
		lines = h.highlightWithChroma(filepath, content)
	}

	h.cache[filepath] = cacheEntry{content: content, lines: lines}
	return lines
}

func (h *Highlighter) highlightWithTreeSitter(filepath string, content string) []StyledLine {
	if h.loader == nil || h.syntaxMap == nil {
		return nil
	}

	loaded := h.loader.Load(filepath)
	if loaded == nil {
		return nil
	}

	language := LanguageFromExtension(filepath)
	return HighlightTreeSitter(loaded, language, []byte(content), h.syntaxMap)
}

func (h *Highlighter) highlightWithChroma(filepath string, content string) []StyledLine {
	lexer := lexers.Match(filepath)
	if lexer == nil {
		return splitLines(content)
	}
	lexer = chroma.Coalesce(lexer)

	return highlightContent(lexer, h.style, content)
}

func highlightContent(lexer chroma.Lexer, style *chroma.Style, content string) []StyledLine {
	iterator, err := lexer.Tokenise(nil, content)
	if err != nil {
		return splitLines(content)
	}

	formatter := formatters.Get("terminal16m")

	var buf bytes.Buffer
	if err := formatter.Format(&buf, style, iterator); err != nil {
		return splitLines(content)
	}

	return splitLines(buf.String())
}

func buildStyle(colors ColorProvider) *chroma.Style {
	fg := colors.Hex("gray-3")

	return chroma.MustNewStyle("oroshi", chroma.StyleEntries{
		chroma.Text:               fg,
		chroma.Keyword:            colors.Hex("keyword"),
		chroma.KeywordConstant:    "bold " + colors.Hex("boolean"),
		chroma.KeywordDeclaration: colors.Hex("keyword"),
		chroma.KeywordNamespace:   colors.Hex("yellow-3"),
		chroma.KeywordType:        colors.Hex("variable-type"),
		chroma.Name:               fg,
		chroma.NameBuiltin:        colors.Hex("function"),
		chroma.NameClass:          colors.Hex("variable-type"),
		chroma.NameFunction:       colors.Hex("function"),
		chroma.NameDecorator:      colors.Hex("orange"),
		chroma.NameTag:            colors.Hex("keyword"),
		chroma.NameAttribute:      colors.Hex("key"),
		chroma.NameVariable:       colors.Hex("variable"),
		chroma.NameConstant:       "bold " + colors.Hex("constant"),
		chroma.NameException:      colors.Hex("red-3"),
		chroma.NameProperty:       colors.Hex("key"),
		chroma.LiteralString:      colors.Hex("string"),
		chroma.LiteralNumber:      colors.Hex("number"),
		chroma.Comment:            "italic " + colors.Hex("comment"),
		chroma.CommentPreproc:     colors.Hex("orange"),
		chroma.Operator:           colors.Hex("punctuation"),
		chroma.Punctuation:        colors.Hex("punctuation"),
		chroma.GenericInserted:    colors.Hex("keyword"),
		chroma.GenericDeleted:     colors.Hex("red-3"),
	})
}

const tabWidth = 4

func expandTabs(s string) string {
	return strings.ReplaceAll(s, "\t", strings.Repeat(" ", tabWidth))
}

func splitLines(content string) []StyledLine {
	content = strings.TrimSuffix(content, "\n")
	if content == "" {
		return nil
	}

	raw := strings.Split(content, "\n")
	lines := make([]StyledLine, len(raw))
	for i, line := range raw {
		lines[i] = StyledLine{Content: expandTabs(line)}
	}
	return lines
}
