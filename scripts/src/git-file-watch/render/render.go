package render

import (
	"fmt"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/color"
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
	WrapLines       bool
	Cursor          int
	ReviewSent      bool
	ScreenFlash     bool
	EditingRowIndex int
	EditingView     string
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
	pathWidth := ctx.ViewportWidth - ctx.LineNumberWidth - 2
	dir, file := filepath.Split(FitPath(row.Path, pathWidth))
	firstLine := firstLineForFile(ctx.RawLines, row.Path)
	dirStyle := lipgloss.NewStyle().Foreground(ctx.Theme.Lipgloss("directory"))
	styledFile := file
	fileColor, fileBold := ctx.Theme.FilenameColorForPath(row.Path, firstLine)
	if fileColor != "" {
		s := lipgloss.NewStyle().Foreground(fileColor)
		if fileBold {
			s = s.Bold(true)
		}
		styledFile = s.Render(file)
	}

	// Icon in the line number column, colored like the filename
	icon := ctx.Theme.FilenameIconForPath(row.Path, firstLine)
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
		label = applyCursorHighlight(label, ctx.Theme, ctx.ViewportWidth)
	}
	b.WriteString(label)
	b.WriteByte('\n')
	return b.String()
}

// BinaryLine renders a placeholder for binary file content.
func BinaryLine(ctx Context) string {
	style := lipgloss.NewStyle().Foreground(ctx.Theme.Lipgloss("gray-5")).Italic(true)
	padding := strings.Repeat(" ", ctx.LineNumberWidth+2)
	return padding + style.Render("Binary file") + "\n"
}

// CommentLine renders a comment annotation above a code line.
func CommentLine(ctx Context, commentText string) string {
	colorName := commentColorName(ctx.ReviewSent)
	style := lipgloss.NewStyle().Foreground(ctx.Theme.Lipgloss(colorName))
	gutter := style.Render("▌")
	numberPadding := strings.Repeat(" ", ctx.LineNumberWidth)
	return gutter + numberPadding + " " + style.Render("REVIEW: "+commentText) + "\n"
}

// CodeLine renders a single code line with gutter, line number, and content.
func CodeLine(ctx Context, row layout.LineRow, isCursor bool) string {
	key := layout.LineKey(row.FilePath, row.LineNumber)
	commentText := ctx.CommentIndex[key]
	hasComment := commentText != ""
	isFlash := ctx.FlashLines[key]

	isEditing := ctx.EditingView != "" && ctx.EditingRowIndex == ctx.Cursor && isCursor

	var b strings.Builder
	if isEditing {
		// Show the textarea above the line, indented to align with code
		indent := strings.Repeat(" ", ctx.LineNumberWidth+2)
		for _, editLine := range strings.Split(ctx.EditingView, "\n") {
			if editLine != "" {
				b.WriteString(indent + editLine)
			}
			b.WriteByte('\n')
		}
	} else if hasComment {
		b.WriteString(CommentLine(ctx, commentText))
	}

	var gutter, lineNumber string
	if isEditing {
		orangeStyle := lipgloss.NewStyle().Foreground(ctx.Theme.Lipgloss("orange"))
		gutter = orangeStyle.Render("▌")
		lineNumber = orangeStyle.Bold(true).Render(fmt.Sprintf("%*d", ctx.LineNumberWidth, row.LineNumber))
	} else {
		gutter = Gutter(row, ctx.Theme, hasComment, ctx.ReviewSent)
		lineNumber = LineNumber(row, ctx.Theme, ctx.LineNumberWidth, isCursor, isFlash, hasComment, ctx.ReviewSent)
	}
	content := DimContent(ctx, row)
	bgHex := lineBackgroundHex(ctx, row, isCursor, isEditing)

	// Wrap mode: split into multiple display lines
	if ctx.WrapLines && ctx.ViewportWidth > 0 {
		availableWidth := ctx.ViewportWidth - ctx.LineNumberWidth - 2
		displayLines := WrapLine(content, availableWidth)

		if len(displayLines) > 1 {
			contPrefix := continuationPrefix(ctx.Theme, ctx.LineNumberWidth)
			lines := make([]string, len(displayLines))
			lines[0] = gutter + lineNumber + " " + displayLines[0]
			for i, dl := range displayLines[1:] {
				lines[i+1] = contPrefix + dl
			}
			for i, l := range lines {
				if bgHex != "" {
					lines[i] = ApplyLineBackground(l, bgHex, ctx.ViewportWidth)
				}
			}
			b.WriteString(strings.Join(lines, "\n"))
			b.WriteByte('\n')
			return b.String()
		}
	}

	// Single line (no wrap or fits within width)
	line := gutter + lineNumber + " " + content
	if ctx.ViewportWidth > 0 {
		line = lipgloss.NewStyle().MaxWidth(ctx.ViewportWidth).Render(line)
	}
	if bgHex != "" {
		line = ApplyLineBackground(line, bgHex, ctx.ViewportWidth)
	}

	b.WriteString(line)
	b.WriteByte('\n')
	return b.String()
}

// applyCursorHighlight applies the cursor background color to the entire line.
func applyCursorHighlight(line string, th *theme.Theme, viewportWidth int) string {
	return ApplyLineBackground(line, th.Hex("yellow-0"), viewportWidth)
}

// ApplyLineBackground applies a hex background color to the entire line and pads to viewport width.
// It uses raw ANSI escapes to inject a background that survives lipgloss resets.
func ApplyLineBackground(line string, hex string, viewportWidth int) string {
	if hex == "" {
		return line
	}
	visible := lipgloss.Width(line)
	pad := viewportWidth - visible
	if pad > 0 {
		line += strings.Repeat(" ", pad)
	}
	r, g, b := color.ParseHexColor(hex)
	bgCode := fmt.Sprintf("\x1b[48;2;%d;%d;%dm", r, g, b)
	// Re-apply background after every ANSI reset so it persists through styled segments
	line = strings.ReplaceAll(line, "\x1b[0m", "\x1b[0m"+bgCode)
	return bgCode + line + "\x1b[0m"
}

// Gutter renders the left gutter bar character with appropriate color.
func Gutter(row layout.LineRow, th *theme.Theme, hasComment bool, reviewSent bool) string {
	return lipgloss.NewStyle().Foreground(LineColor(row, th, hasComment, reviewSent)).Render("▌")
}

// LineNumber renders a padded line number with priority-based coloring.
func LineNumber(row layout.LineRow, th *theme.Theme, width int, isCursor bool, isFlash bool, hasComment bool, reviewSent bool) string {
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

	return lipgloss.NewStyle().Foreground(LineColor(row, th, hasComment, reviewSent)).Render(numberString)
}

// LineColor returns the appropriate color for a line based on comment/marker state.
func LineColor(row layout.LineRow, th *theme.Theme, hasComment bool, reviewSent bool) lipgloss.Color {
	if hasComment {
		return th.Lipgloss(commentColorName(reviewSent))
	}
	if row.Marker != nil {
		return th.Lipgloss(MarkerColorName(*row.Marker))
	}
	return th.Lipgloss("gray")
}

// MarkerColorName maps a diff marker to its foreground theme color name.
// Uses the same colors as Neovim's GitSigns gutter highlights.
func MarkerColorName(marker diff.Marker) string {
	switch marker {
	case diff.MarkerAdded:
		return "green-7"
	case diff.MarkerModified:
		return "purple"
	case diff.MarkerDeleted:
		return "red-8"
	default:
		return ""
	}
}

// MarkerBgColorName maps a diff marker to its background theme color name.
func MarkerBgColorName(marker diff.Marker) string {
	switch marker {
	case diff.MarkerAdded:
		return "green-0"
	case diff.MarkerModified:
		return "purple-0"
	case diff.MarkerDeleted:
		return "red-0"
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
func DimContent(ctx Context, row layout.LineRow) string {
	if row.Distance == 0 {
		return lineContent(ctx.Highlighted, row.FilePath, row.LineNumber)
	}

	// Context line: use raw content with dim color
	plain := flash.RawLineContent(ctx.RawLines, row.FilePath, row.LineNumber)
	plain = strings.ReplaceAll(plain, "\t", "    ")

	colorName := dimColorForDistance(row.Distance)
	color := ctx.Theme.Lipgloss(colorName)
	if color == "" {
		return plain
	}
	return lipgloss.NewStyle().Foreground(color).Render(plain)
}

func firstLineForFile(rawLines map[string][]string, path string) string {
	lines := rawLines[path]
	if len(lines) > 0 {
		return lines[0]
	}
	return ""
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

// lineBackgroundHex returns the background hex color for a code line, or "" for none.
func lineBackgroundHex(ctx Context, row layout.LineRow, isCursor bool, isEditing bool) string {
	if ctx.ViewportWidth <= 0 {
		return ""
	}
	if isEditing {
		return ctx.Theme.Hex("orange-0")
	}
	if isCursor {
		return ctx.Theme.Hex("yellow-0")
	}
	if row.Marker == nil {
		return ""
	}
	colorName := MarkerBgColorName(*row.Marker)
	if colorName == "" {
		return ""
	}
	return ctx.Theme.Hex(colorName)
}

// continuationPrefix builds the prefix for wrapped continuation lines:
// blank gutter (1 char) + ↪ right-aligned in line number column (dimmed gray) + space.
// Uses raw ANSI escapes so the color survives non-TTY environments.
func continuationPrefix(th *theme.Theme, lineNumberWidth int) string {
	pad := lineNumberWidth - 1
	if pad < 0 {
		pad = 0
	}
	r, g, b := color.ParseHexColor(th.Hex("gray"))
	fgCode := fmt.Sprintf("\x1b[38;2;%d;%d;%dm", r, g, b)
	arrow := fgCode + "↪" + "\x1b[0m"
	return " " + strings.Repeat(" ", pad) + arrow + " "
}

func commentColorName(reviewSent bool) string {
	if reviewSent {
		return "orange-8"
	}
	return "orange"
}
