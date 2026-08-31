package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/charmbracelet/bubbles/textarea"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/claude"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/comments"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/editing"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/editor"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/highlight"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/navigation"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/theme"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/watcher"
)

// DiffChangedMsg is sent when the watcher detects a new git diff.
type DiffChangedMsg struct{}

// CommentsChangedMsg is sent when the comments file changes externally.
type CommentsChangedMsg struct{}

// EditorFinishedMsg is sent when the external editor exits.
type EditorFinishedMsg struct{ err error }

type model struct {
	theme                *theme.Theme
	rows                 []layout.Row
	highlighted          map[string][]highlight.StyledLine
	rawLines             map[string][]string
	watchChannel         <-chan struct{}
	commentsWatchChannel <-chan struct{}
	nav                  navigation.State
	fileHeaders          []int
	filePaths            []string
	foldState            map[string]bool
	visibleIndices       []int
	pendingKey           string
	repoRoot             string
	userComments         []comments.Comment
	commentsPath         string
	commentIndex         map[string]bool
	editState            editing.State
	editTextArea         textarea.Model
	statusMessage        string
}

func (m model) Init() tea.Cmd {
	var commands []tea.Cmd
	if m.watchChannel != nil {
		commands = append(commands, waitForDiffChange(m.watchChannel))
	}
	if m.commentsWatchChannel != nil {
		commands = append(commands, waitForCommentsChange(m.commentsWatchChannel))
	}
	return tea.Batch(commands...)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case DiffChangedMsg:
		m.rebuildDisplay()
		return m, waitForDiffChange(m.watchChannel)
	case CommentsChangedMsg:
		m.reloadComments()
		return m, waitForCommentsChange(m.commentsWatchChannel)
	case EditorFinishedMsg:
		m.rebuildDisplay()
		return m, nil
	case tea.WindowSizeMsg:
		m.nav.ViewportHeight = msg.Height
		return m, nil
	case tea.KeyMsg:
		if m.editState.Active {
			return m.updateEditing(msg)
		}
		return m.updateNormal(msg)
	}
	return m, nil
}

func (m model) updateEditing(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+s":
		result := editing.Save(m.editState, m.editTextArea.Value())
		m.userComments = applyEditResult(m.userComments, result)
		_ = comments.Save(m.commentsPath, m.userComments)
		m.commentIndex = buildCommentIndex(m.userComments)
		m.editState = editing.Inactive()
		return m, nil
	case "esc":
		m.editState = editing.Inactive()
		return m, nil
	}

	var cmd tea.Cmd
	m.editTextArea, cmd = m.editTextArea.Update(msg)
	return m, cmd
}

func (m model) updateNormal(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	m.statusMessage = ""
	key := msg.String()
	if m.pendingKey == "z" {
		m.pendingKey = ""
		if key == "a" {
			m.nav, m.foldState = navigation.ToggleFold(m.nav, m.fileHeaders, m.filePaths, m.foldState)
			m.visibleIndices = navigation.VisibleIndices(len(m.rows), m.fileHeaders, m.filePaths, m.foldState)
		}
		return m, nil
	}
	switch key {
	case "q", "ctrl+c":
		return m, tea.Quit
	case "j":
		m.nav = navigation.MoveDownVisible(m.nav, m.visibleIndices)
	case "k":
		m.nav = navigation.MoveUpVisible(m.nav, m.visibleIndices)
	case "l":
		m.nav = navigation.NextFileHeader(m.nav, m.fileHeaders, m.visibleIndices)
	case "h":
		m.nav = navigation.PrevFileHeader(m.nav, m.fileHeaders, m.visibleIndices)
	case "i":
		cmd := editor.NvimCommand(m.rows, m.nav.Cursor, m.repoRoot)
		if cmd == nil {
			return m, nil
		}
		return m, tea.ExecProcess(cmd, func(err error) tea.Msg {
			return EditorFinishedMsg{err: err}
		})
	case "r":
		return m.sendReviewToClaude()
	case "enter":
		return m.openEditing()
	case "z":
		m.pendingKey = "z"
	}
	return m, nil
}

func (m model) openEditing() (tea.Model, tea.Cmd) {
	lineRow, ok := m.rows[m.nav.Cursor].(layout.LineRow)
	if !ok {
		return m, nil
	}

	relativePath := editor.CurrentFilePath(m.rows, m.nav.Cursor)
	if relativePath == "" {
		return m, nil
	}
	absolutePath := filepath.Join(m.repoRoot, relativePath)

	lineContent := rawLineContent(m.rawLines, absolutePath, lineRow.LineNumber)
	existingReview := comments.FindReview(m.userComments, absolutePath, lineRow.LineNumber)

	m.editState = editing.Open(absolutePath, lineRow.LineNumber, lineContent, existingReview, m.nav.Cursor)

	ta := textarea.New()
	ta.SetWidth(60)
	ta.SetHeight(3)
	ta.ShowLineNumbers = false
	ta.Prompt = "  "
	ta.FocusedStyle.Base = lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(lipgloss.Color("240")).
		Padding(0, 1)
	if existingReview != "" {
		ta.SetValue(existingReview)
	}
	ta.Focus()
	m.editTextArea = ta

	return m, nil
}

func applyEditResult(userComments []comments.Comment, result editing.SaveResult) []comments.Comment {
	if result.IsEmpty {
		return comments.Delete(userComments, result.FilePath, result.LineNumber)
	}
	return comments.Upsert(userComments, comments.Comment{
		Filepath:    result.FilePath,
		LineNumber:  result.LineNumber,
		LineContent: result.LineContent,
		Review:      result.Text,
	})
}

func rawLineContent(rawLines map[string][]string, absolutePath string, lineNumber int) string {
	lines, ok := rawLines[absolutePath]
	if !ok {
		return ""
	}
	index := lineNumber - 1
	if index < 0 || index >= len(lines) {
		return ""
	}
	return lines[index]
}

func (m *model) rebuildDisplay() {
	rows, highlighted, rawLines, err := buildDisplay()
	if err != nil {
		return
	}
	m.rows = rows
	m.highlighted = highlighted
	m.rawLines = rawLines
	m.fileHeaders, m.filePaths = findFileHeaders(rows)
	m.nav.RowCount = len(rows)
	if m.nav.Cursor >= len(rows) {
		m.nav.Cursor = max(0, len(rows)-1)
	}
	m.visibleIndices = navigation.VisibleIndices(len(rows), m.fileHeaders, m.filePaths, m.foldState)

	m.userComments = comments.Reattach(m.userComments, rawLines)
	_ = comments.Save(m.commentsPath, m.userComments)
	m.commentIndex = buildCommentIndex(m.userComments)
	m.editState = editing.Inactive()
}

func (m model) sendReviewToClaude() (tea.Model, tea.Cmd) {
	tabID, err := currentTabID()
	if err != nil {
		m.statusMessage = fmt.Sprintf("error: %s", err)
		return m, nil
	}

	windowID, err := claude.FindClaudeWindow(runCommand, tabID)
	if err != nil {
		m.statusMessage = fmt.Sprintf("error: %s", err)
		return m, nil
	}

	if err := claude.SendReview(runCommand, windowID, len(m.userComments)); err != nil {
		m.statusMessage = err.Error()
		return m, nil
	}

	m.statusMessage = "review sent to Claude"
	return m, nil
}

func (m *model) reloadComments() {
	loaded, err := comments.Load(m.commentsPath)
	if err != nil {
		return
	}
	m.userComments = loaded
	m.commentIndex = buildCommentIndex(m.userComments)
	m.editState = editing.Inactive()
}

func runCommand(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return string(output), nil
}

func currentTabID() (int, error) {
	kittyWindowID := os.Getenv("KITTY_WINDOW_ID")
	if kittyWindowID == "" {
		return 0, fmt.Errorf("KITTY_WINDOW_ID not set")
	}

	output, err := runCommand("kitty-window-tab-id", kittyWindowID)
	if err != nil {
		return 0, fmt.Errorf("resolving tab ID: %w", err)
	}

	tabID, err := strconv.Atoi(strings.TrimSpace(output))
	if err != nil {
		return 0, fmt.Errorf("parsing tab ID %q: %w", output, err)
	}
	return tabID, nil
}

func waitForDiffChange(channel <-chan struct{}) tea.Cmd {
	return func() tea.Msg {
		<-channel
		return DiffChangedMsg{}
	}
}

func waitForCommentsChange(channel <-chan struct{}) tea.Cmd {
	return func() tea.Msg {
		<-channel
		return CommentsChangedMsg{}
	}
}

func (m model) View() string {
	var builder strings.Builder
	var currentFile string

	// Render visible rows within viewport
	rendered := 0
	for _, i := range m.visibleIndices {
		if i < m.nav.ViewportOffset {
			// Track current file for rows before viewport
			if header, ok := m.rows[i].(layout.FileHeaderRow); ok {
				currentFile = header.Path
			}
			continue
		}
		if rendered >= m.nav.ViewportHeight {
			break
		}

		row := m.rows[i]
		isCursor := i == m.nav.Cursor
		rendered++

		switch r := row.(type) {
		case layout.FileHeaderRow:
			currentFile = r.Path
			style := lipgloss.NewStyle().Bold(true)
			line := style.Render(r.Path)
			if m.foldState[r.Path] {
				line += " [folded]"
			}
			if isCursor {
				line = "> " + line
			} else {
				line = "  " + line
			}
			builder.WriteString(line)
			builder.WriteByte('\n')
		case layout.SeparatorRow:
			if isCursor {
				builder.WriteString("> ···\n")
			} else {
				builder.WriteString("  ···\n")
			}
		case layout.LineRow:
			lineNumber := renderLineNumber(r, m.theme)
			content := lineContent(m.highlighted, currentFile, r.LineNumber)
			if isCursor {
				builder.WriteString("> ")
			} else {
				builder.WriteString("  ")
			}
			absolutePath := filepath.Join(m.repoRoot, currentFile)
			builder.WriteString(commentIndicator(m.commentIndex, m.theme, absolutePath, r.LineNumber))
			builder.WriteString(lineNumber)
			builder.WriteByte(' ')
			builder.WriteString(content)
			builder.WriteByte('\n')
		}

		if m.editState.Active && i == m.editState.RowIndex {
			builder.WriteString(m.editTextArea.View())
			builder.WriteByte('\n')
		}
	}

	if m.statusMessage != "" {
		builder.WriteByte('\n')
		builder.WriteString(m.statusMessage)
		builder.WriteByte('\n')
	}

	return builder.String()
}

func renderLineNumber(row layout.LineRow, th *theme.Theme) string {
	numberString := fmt.Sprintf("%4d", row.LineNumber)
	if row.Marker == nil {
		return numberString
	}

	colorName := markerColorName(*row.Marker)
	ansi, err := th.Color(colorName)
	if err != nil {
		return numberString
	}

	style := lipgloss.NewStyle().Foreground(theme.ANSIToLipgloss(ansi))
	return style.Render(numberString)
}

func markerColorName(marker diff.Marker) string {
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

func findFileHeaders(rows []layout.Row) ([]int, []string) {
	var indices []int
	var paths []string
	for i, row := range rows {
		if header, ok := row.(layout.FileHeaderRow); ok {
			indices = append(indices, i)
			paths = append(paths, header.Path)
		}
	}
	return indices, paths
}

func main() {
	oroshiRoot := os.Getenv("OROSHI_ROOT")
	if oroshiRoot == "" {
		fmt.Fprintln(os.Stderr, "OROSHI_ROOT not set")
		os.Exit(1)
	}

	th, err := theme.Load(oroshiRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	rows, highlighted, rawLines, err := buildDisplay()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	repoRoot, err := gitRepoRoot()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	commentsPath, err := resolveCommentsPath()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	userComments, err := comments.Load(commentsPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	watchChannel, err := watcher.Watch(repoRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	commentsWatchChannel, err := watcher.WatchFile(commentsPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fileHeaders, filePaths := findFileHeaders(rows)
	foldState := map[string]bool{}
	visibleIndices := navigation.VisibleIndices(len(rows), fileHeaders, filePaths, foldState)
	p := tea.NewProgram(model{
		theme:                th,
		rows:                 rows,
		highlighted:          highlighted,
		rawLines:             rawLines,
		watchChannel:         watchChannel,
		commentsWatchChannel: commentsWatchChannel,
		fileHeaders:          fileHeaders,
		filePaths:            filePaths,
		foldState:            foldState,
		visibleIndices:       visibleIndices,
		repoRoot:             repoRoot,
		userComments:         userComments,
		commentsPath:         commentsPath,
		commentIndex:         buildCommentIndex(userComments),
		nav: navigation.State{
			RowCount: len(rows),
		},
	}, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func buildDisplay() ([]layout.Row, map[string][]highlight.StyledLine, map[string][]string, error) {
	repoRoot, err := gitRepoRoot()
	if err != nil {
		return nil, nil, nil, err
	}

	raw, err := runGitDiff(repoRoot)
	if err != nil {
		return nil, nil, nil, err
	}

	fileDiffs := diff.Parse(raw)
	highlighter := highlight.New()
	highlightedFiles := make(map[string][]highlight.StyledLine)
	rawLines := make(map[string][]string)
	var allRows []layout.Row

	for _, fileDiff := range fileDiffs {
		absolutePath := filepath.Join(repoRoot, fileDiff.Path)
		content, readErr := os.ReadFile(absolutePath)
		if readErr != nil {
			continue
		}

		lines := highlighter.Highlight(fileDiff.Path, string(content))
		highlightedFiles[fileDiff.Path] = lines
		rawLines[absolutePath] = strings.Split(string(content), "\n")

		markers := diff.Classify(fileDiff.Hunks)
		rows := layout.Build(fileDiff, markers, len(lines))
		allRows = append(allRows, rows...)
	}

	return allRows, highlightedFiles, rawLines, nil
}

func gitRepoRoot() (string, error) {
	cmd := exec.Command("git", "rev-parse", "--show-toplevel")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("finding git root: %w", err)
	}
	return strings.TrimSpace(string(output)), nil
}

func runGitDiff(repoRoot string) (string, error) {
	cmd := exec.Command("git", "diff")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("running git diff: %w", err)
	}
	return string(output), nil
}

func resolveCommentsPath() (string, error) {
	tmpFolder := os.Getenv("OROSHI_TMP_FOLDER")
	if tmpFolder == "" {
		return "", fmt.Errorf("OROSHI_TMP_FOLDER not set")
	}

	cmd := exec.Command("context-slug")
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("resolving context-slug: %w", err)
	}

	slug := strings.TrimSpace(string(output))
	dir := filepath.Join(tmpFolder, "git-file-watch")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return "", fmt.Errorf("creating comments directory: %w", err)
	}

	return filepath.Join(dir, slug+".json"), nil
}

func buildCommentIndex(userComments []comments.Comment) map[string]bool {
	index := make(map[string]bool, len(userComments))
	for _, c := range userComments {
		key := fmt.Sprintf("%s:%d", c.Filepath, c.LineNumber)
		index[key] = true
	}
	return index
}

func commentIndicator(index map[string]bool, th *theme.Theme, absolutePath string, lineNumber int) string {
	key := fmt.Sprintf("%s:%d", absolutePath, lineNumber)
	if !index[key] {
		return " "
	}
	ansi, err := th.Color("orange")
	if err != nil {
		return "●"
	}
	style := lipgloss.NewStyle().Foreground(theme.ANSIToLipgloss(ansi))
	return style.Render("●")
}
