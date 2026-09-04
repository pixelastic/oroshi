package highlight

import (
	"fmt"
	"sort"
	"strings"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
)

// HighlightTreeSitter highlights source code using tree-sitter and returns styled lines.
func HighlightTreeSitter(loaded *LoadedLanguage, language string, source []byte, syntaxMap *SyntaxMap) []StyledLine {
	if len(source) == 0 {
		return nil
	}

	parser := tree_sitter.NewParser()
	defer parser.Close()

	if err := parser.SetLanguage(loaded.Language); err != nil {
		return splitLines(string(source))
	}

	tree := parser.Parse(source, nil)
	defer tree.Close()

	query, queryError := tree_sitter.NewQuery(loaded.Language, string(loaded.HighlightQuery))
	if queryError != nil {
		return splitLines(string(source))
	}
	defer query.Close()

	captureStyles := resolveCaptureStyles(query.CaptureNames(), language, syntaxMap)
	byteStyles := paintCaptures(query, tree.RootNode(), source, captureStyles)

	return buildStyledLines(source, byteStyles, captureStyles)
}

func resolveCaptureStyles(names []string, language string, syntaxMap *SyntaxMap) []SyntaxStyle {
	styles := make([]SyntaxStyle, len(names))
	for i, name := range names {
		styles[i] = syntaxMap.Resolve(language, name)
	}
	return styles
}

type captureSpan struct {
	start      uint
	end        uint
	styleIndex int
	patternIndex uint
}

// paintCaptures assigns a style index to each byte of source.
// Captures are sorted largest-first so parent captures are painted before
// children. Within same-size spans, higher pattern indices (more specific
// patterns in highlights.scm) paint last and win.
func paintCaptures(query *tree_sitter.Query, root *tree_sitter.Node, source []byte, captureStyles []SyntaxStyle) []int {
	spans := collectCaptures(query, root, source, captureStyles)
	sortSpansForPainting(spans)

	byteStyles := make([]int, len(source))
	for i := range byteStyles {
		byteStyles[i] = -1
	}
	for _, span := range spans {
		for i := span.start; i < span.end && int(i) < len(source); i++ {
			byteStyles[i] = span.styleIndex
		}
	}

	return byteStyles
}

func collectCaptures(query *tree_sitter.Query, root *tree_sitter.Node, source []byte, captureStyles []SyntaxStyle) []captureSpan {
	cursor := tree_sitter.NewQueryCursor()
	defer cursor.Close()

	var spans []captureSpan
	captures := cursor.Captures(query, root, source)
	for match, captureIndex := captures.Next(); match != nil; match, captureIndex = captures.Next() {
		// Skip patterns with general predicates (e.g. #lua-match?) that we
		// cannot evaluate — matching them unconditionally causes wrong captures.
		if len(query.GeneralPredicates(match.PatternIndex)) > 0 {
			continue
		}

		capture := match.Captures[captureIndex]
		styleIndex := int(capture.Index)
		if styleIndex >= len(captureStyles) {
			continue
		}
		style := captureStyles[styleIndex]
		if style.ColorHex == "" && !style.Bold && !style.Italic {
			continue
		}
		spans = append(spans, captureSpan{
			start:        capture.Node.StartByte(),
			end:          capture.Node.EndByte(),
			styleIndex:   styleIndex,
			patternIndex: match.PatternIndex,
		})
	}
	return spans
}

// sortSpansForPainting orders spans so that broader parent captures are
// painted first and narrower child captures overwrite them.
func sortSpansForPainting(spans []captureSpan) {
	sort.Slice(spans, func(i, j int) bool {
		sizeI := spans[i].end - spans[i].start
		sizeJ := spans[j].end - spans[j].start
		if sizeI != sizeJ {
			return sizeI > sizeJ
		}
		return spans[i].patternIndex < spans[j].patternIndex
	})
}

func buildStyledLines(source []byte, byteStyles []int, captureStyles []SyntaxStyle) []StyledLine {
	var builder strings.Builder
	currentStyle := -1

	for i, b := range source {
		style := byteStyles[i]
		if style != currentStyle {
			if currentStyle != -1 {
				builder.WriteString("\033[0m")
			}
			if style != -1 {
				ansiCode := styleToANSI(captureStyles[style])
				builder.WriteString(ansiCode)
			}
			currentStyle = style
		}
		builder.WriteByte(b)
	}
	if currentStyle != -1 {
		builder.WriteString("\033[0m")
	}

	return splitLines(builder.String())
}

func styleToANSI(style SyntaxStyle) string {
	if style.ColorHex == "" && !style.Bold && !style.Italic {
		return ""
	}

	var parts []string
	if style.Bold {
		parts = append(parts, "1")
	}
	if style.Italic {
		parts = append(parts, "3")
	}
	if style.ColorHex != "" {
		r, g, b := hexToRGB(style.ColorHex)
		parts = append(parts, fmt.Sprintf("38;2;%d;%d;%d", r, g, b))
	}
	return "\033[" + strings.Join(parts, ";") + "m"
}

func hexToRGB(hex string) (int, int, int) {
	hex = strings.TrimPrefix(hex, "#")
	if len(hex) != 6 {
		return 0, 0, 0
	}
	var r, g, b int
	_, _ = fmt.Sscanf(hex, "%02x%02x%02x", &r, &g, &b)
	return r, g, b
}
