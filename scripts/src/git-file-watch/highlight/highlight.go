package highlight

import (
	"bytes"
	"strings"

	"github.com/alecthomas/chroma/v2"
	"github.com/alecthomas/chroma/v2/formatters"
	"github.com/alecthomas/chroma/v2/lexers"
	"github.com/alecthomas/chroma/v2/styles"
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
type Highlighter struct {
	cache map[string]cacheEntry
}

// New creates a Highlighter.
func New() *Highlighter {
	return &Highlighter{
		cache: make(map[string]cacheEntry),
	}
}

// Highlight returns syntax-highlighted lines for the given file content.
func (h *Highlighter) Highlight(filepath string, content string) []StyledLine {
	if cached, ok := h.cache[filepath]; ok && cached.content == content {
		return cached.lines
	}

	lexer := lexers.Match(filepath)
	if lexer == nil {
		lines := splitPlain(content)
		h.cache[filepath] = cacheEntry{content: content, lines: lines}
		return lines
	}
	lexer = chroma.Coalesce(lexer)

	lines := highlightContent(lexer, content)
	h.cache[filepath] = cacheEntry{content: content, lines: lines}
	return lines
}

func highlightContent(lexer chroma.Lexer, content string) []StyledLine {
	iterator, err := lexer.Tokenise(nil, content)
	if err != nil {
		return splitPlain(content)
	}

	formatter := formatters.Get("terminal256")
	style := styles.Get("monokai")

	var buf bytes.Buffer
	if err := formatter.Format(&buf, style, iterator); err != nil {
		return splitPlain(content)
	}

	return splitStyled(buf.String())
}

func splitStyled(rendered string) []StyledLine {
	// Remove trailing newline to avoid empty last line
	rendered = strings.TrimSuffix(rendered, "\n")
	if rendered == "" {
		return nil
	}

	raw := strings.Split(rendered, "\n")
	lines := make([]StyledLine, len(raw))
	for i, line := range raw {
		lines[i] = StyledLine{Content: line}
	}
	return lines
}

func splitPlain(content string) []StyledLine {
	content = strings.TrimSuffix(content, "\n")
	if content == "" {
		return nil
	}

	raw := strings.Split(content, "\n")
	lines := make([]StyledLine, len(raw))
	for i, line := range raw {
		lines[i] = StyledLine{Content: line}
	}
	return lines
}
