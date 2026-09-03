package render

import (
	"fmt"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/flash"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/highlight"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/theme"
)

// Context holds display state needed by rendering functions,
// without coupling to the bubbletea model.
type Context struct {
	Theme           *theme.Theme
	RepoRoot        string
	Highlighted     map[string][]highlight.StyledLine
	RawLines        map[string][]string
	CommentIndex    map[string]string
	FlashLines      map[string]bool
	FoldState       map[string]bool
	LineNumberWidth int
	ViewportWidth   int
	Cursor          int
}

// FileHeader renders a file header row with directory coloring and separator.
func FileHeader(ctx Context, row layout.FileHeaderRow, fileCount int, isCursor bool) string {
	var b strings.Builder
	if fileCount > 1 {
		separatorStyle := lipgloss.NewStyle().Foreground(ctx.Theme.Lipgloss("gray-7"))
		width := ctx.ViewportWidth
		if width <= 0 {
			width = 80
		}
		b.WriteString(separatorStyle.Render(strings.Repeat("─", width)))
		b.WriteByte('\n')
	}
	if fileCount == 1 {
		b.WriteByte('\n')
	}
	dir, file := filepath.Split(row.Path)
	dirStyle := lipgloss.NewStyle().Foreground(ctx.Theme.Lipgloss("directory"))
	styledFile := file
	fileColor, fileBold := ctx.Theme.FilenameColor(file)
	if fileColor != "" {
		s := lipgloss.NewStyle().Foreground(fileColor)
		if fileBold {
			s = s.Bold(true)
		}
		styledFile = s.Render(file)
	}

	// Icon in the line number column, colored like the filename
	icon := ctx.Theme.FilenameIcon(file)
	iconCol := strings.Repeat(" ", ctx.LineNumberWidth)
	if icon != "" {
		pad := ctx.LineNumberWidth - 1
		if pad < 0 {
			pad = 0
		}
		styledIcon := icon
		if fileColor != "" {
			styledIcon = lipgloss.NewStyle().Foreground(fileColor).Render(icon)
		}
		iconCol = strings.Repeat(" ", pad) + styledIcon
	}

	label := iconCol + "  " + dirStyle.Render(dir) + styledFile
	if ctx.FoldState[row.Path] {
		label += " [folded]"
	}
	if isCursor && ctx.ViewportWidth > 0 {
		bgStyle := lipgloss.NewStyle().Background(ctx.Theme.Lipgloss("gray-9"))
		visible := lipgloss.Width(label)
		pad := ctx.ViewportWidth - visible
		if pad > 0 {
			label += bgStyle.Render(strings.Repeat(" ", pad))
		}
	}
	b.WriteString(label)
	b.WriteByte('\n')
	return b.String()
}

// CommentLine renders a comment annotation above a code line.
func CommentLine(ctx Context, commentText string) string {
	orangeStyle := lipgloss.NewStyle().Foreground(ctx.Theme.Lipgloss("orange"))
	gutter := orangeStyle.Render("▌")
	numberPadding := strings.Repeat(" ", ctx.LineNumberWidth)
	return gutter + numberPadding + " " + orangeStyle.Render("REVIEW: "+commentText) + "\n"
}

// CodeLine renders a single code line with gutter, line number, and content.
func CodeLine(ctx Context, row layout.LineRow, isCursor bool) string {
	key := fmt.Sprintf("%s:%d", row.FilePath, row.LineNumber)
	commentText := ctx.CommentIndex[key]
	hasComment := commentText != ""
	isFlash := ctx.FlashLines[key]

	var b strings.Builder
	if hasComment {
		b.WriteString(CommentLine(ctx, commentText))
	}

	gutter := Gutter(row, ctx.Theme, hasComment)
	lineNumber := LineNumber(row, ctx.Theme, ctx.LineNumberWidth, isCursor, isFlash, hasComment)
	content := DimContent(ctx.Highlighted, ctx.RawLines, row.FilePath, row, ctx.Theme)
	line := gutter + lineNumber + " " + content

	if ctx.ViewportWidth > 0 {
		line = lipgloss.NewStyle().MaxWidth(ctx.ViewportWidth).Render(line)
	}

	if isCursor {
		bgStyle := lipgloss.NewStyle().Background(ctx.Theme.Lipgloss("gray-9"))
		visible := lipgloss.Width(line)
		pad := ctx.ViewportWidth - visible
		if pad > 0 {
			line += bgStyle.Render(strings.Repeat(" ", pad))
		}
	}

	b.WriteString(line)
	b.WriteByte('\n')
	return b.String()
}

// Gutter renders the left gutter bar character with appropriate color.
func Gutter(row layout.LineRow, th *theme.Theme, hasComment bool) string {
	return lipgloss.NewStyle().Foreground(LineColor(row, th, hasComment)).Render("▌")
}

// LineNumber renders a padded line number with priority-based coloring.
func LineNumber(row layout.LineRow, th *theme.Theme, width int, isCursor bool, isFlash bool, hasComment bool) string {
	numberString := fmt.Sprintf("%*d", width, row.LineNumber)

	if isFlash {
		return lipgloss.NewStyle().
			Foreground(th.Lipgloss("amber-3")).
			Bold(true).
			Render(numberString)
	}

	if isCursor {
		return lipgloss.NewStyle().
			Foreground(th.Lipgloss("yellow")).
			Bold(true).
			Render(numberString)
	}

	return lipgloss.NewStyle().Foreground(LineColor(row, th, hasComment)).Render(numberString)
}

// LineColor returns the appropriate color for a line based on comment/marker state.
func LineColor(row layout.LineRow, th *theme.Theme, hasComment bool) lipgloss.Color {
	if hasComment {
		return th.Lipgloss("orange")
	}
	if row.Marker != nil {
		return th.Lipgloss(MarkerColorName(*row.Marker))
	}
	return th.Lipgloss("gray")
}

// MarkerColorName maps a diff marker to its theme color name.
func MarkerColorName(marker diff.Marker) string {
	switch marker {
	case diff.MarkerAdded:
		return "git-added"
	case diff.MarkerModified:
		return "git-modified"
	case diff.MarkerDeleted:
		return "git-removed"
	default:
		return ""
	}
}

// MaxLineNumberWidth calculates the digit width needed for the largest line number.
func MaxLineNumberWidth(rows []layout.Row) int {
	maxNum := 0
	for _, row := range rows {
		if lr, ok := row.(layout.LineRow); ok && lr.LineNumber > maxNum {
			maxNum = lr.LineNumber
		}
	}
	if maxNum == 0 {
		return 1
	}
	width := 0
	for n := maxNum; n > 0; n /= 10 {
		width++
	}
	return width
}

// DimContent returns syntax-highlighted content for changed lines,
// and progressively dimmer plain content for context lines.
func DimContent(highlighted map[string][]highlight.StyledLine, rawLines map[string][]string, currentFile string, row layout.LineRow, th *theme.Theme) string {
	if row.Distance == 0 {
		return lineContent(highlighted, currentFile, row.LineNumber)
	}

	// Context line: use raw content with dim color
	plain := flash.RawLineContent(rawLines, currentFile, row.LineNumber)
	plain = strings.ReplaceAll(plain, "\t", "    ")

	colorName := dimColorForDistance(row.Distance)
	color := th.Lipgloss(colorName)
	if color == "" {
		return plain
	}
	return lipgloss.NewStyle().Foreground(color).Render(plain)
}

func lineContent(highlighted map[string][]highlight.StyledLine, path string, lineNumber int) string {
	lines, ok := highlighted[path]
	if !ok {
		return ""
	}
	index := lineNumber - 1
	if index < 0 || index >= len(lines) {
		return ""
	}
	return lines[index].Content
}

func dimColorForDistance(distance int) string {
	switch {
	case distance <= 1:
		return "gray-4"
	case distance <= 2:
		return "gray-5"
	default:
		return "gray-6"
	}
}
