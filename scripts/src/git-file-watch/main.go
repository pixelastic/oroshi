package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/textarea"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/claude"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/comments"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/editing"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/editor"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/flash"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/git"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/highlight"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/navigation"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/render"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/theme"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/watcher"
)

// DiffChangedMsg is sent when the watcher detects a new git diff.
type DiffChangedMsg struct{}

// CommentsChangedMsg is sent when the comments file changes externally.
type CommentsChangedMsg struct{}

// EditorFinishedMsg is sent when the external editor exits.
type EditorFinishedMsg struct{ err error }

// FlashExpiredMsg is sent when the flash highlight should be cleared.
type FlashExpiredMsg struct{}

type model struct {
	theme                *theme.Theme
	rows                 []layout.Row
	highlighted          map[string][]highlight.StyledLine
	rawLines             map[string][]string
	watchChannel         <-chan struct{}
	commentsWatchChannel <-chan struct{}
	nav              navigation.State
	fileIndex        navigation.FileIndex
	visibleIndices   []int
	navigableIndices []int
	pendingKey           string
	repoRoot             string
	userComments         []comments.Comment
	commentsPath         string
	commentIndex         map[string]string
	editState            editing.State
	editTextArea         textarea.Model
	statusMessage        string
	viewportWidth        int
	lineNumberWidth      int
	flashLines           map[string]bool
	prevSnapshot         *flash.Snapshot
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
		cmd := m.rebuildDisplay()
		return m, tea.Batch(waitForDiffChange(m.watchChannel), cmd)
	case CommentsChangedMsg:
		m.reloadComments()
		return m, waitForCommentsChange(m.commentsWatchChannel)
	case EditorFinishedMsg:
		m.rebuildDisplay()
		return m, nil
	case FlashExpiredMsg:
		m.flashLines = nil
		return m, nil
	case tea.WindowSizeMsg:
		m.nav.ViewportHeight = msg.Height
		m.viewportWidth = msg.Width
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
		m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
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
	if m.pendingKey == "g" {
		m.pendingKey = ""
		if key == "g" {
			m.nav = navigation.GoToTop(m.nav, m.navigableIndices, m.visibleIndices)
		}
		return m, nil
	}
	if m.pendingKey == "z" {
		m.pendingKey = ""
		if key == "a" {
			m.nav, m.fileIndex = navigation.ToggleFold(m.nav, m.fileIndex)
			m.visibleIndices = navigation.VisibleIndices(len(m.rows), m.fileIndex)
			m.navigableIndices = navigableFromVisible(m.rows, m.visibleIndices)
		}
		return m, nil
	}
	switch key {
	case "q", "ctrl+c":
		return m, tea.Quit
	case "j":
		m.nav = navigation.MoveDownVisible(m.nav, m.navigableIndices, m.visibleIndices)
	case "k":
		m.nav = navigation.MoveUpVisible(m.nav, m.navigableIndices, m.visibleIndices)
	case "l":
		m.nav = navigation.NextFile(m.nav, m.fileIndex, m.navigableIndices, m.visibleIndices)
	case "h":
		m.nav = navigation.PrevFile(m.nav, m.fileIndex, m.navigableIndices, m.visibleIndices)
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
	case "g":
		m.pendingKey = "g"
	case "G":
		m.nav = navigation.GoToBottom(m.nav, m.navigableIndices, m.visibleIndices)
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

	lineContent := flash.RawLineContent(m.rawLines, relativePath, lineRow.LineNumber)
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

func (m *model) rebuildDisplay() tea.Cmd {
	rows, highlighted, rawLines, err := buildDisplay(m.repoRoot, m.theme)
	if err != nil {
		return nil
	}

	// Detect changed marked lines
	snap := flash.NewSnapshot(rows, rawLines)
	m.flashLines = flash.DetectChangedLines(m.prevSnapshot, snap)
	m.prevSnapshot = &snap

	m.rows = rows
	m.highlighted = highlighted
	m.rawLines = rawLines
	m.fileIndex = findFileHeaders(rows, m.fileIndex.FoldState)
	m.nav.RowCount = len(rows)
	if m.nav.Cursor >= len(rows) {
		m.nav.Cursor = max(0, len(rows)-1)
	}
	m.visibleIndices = navigation.VisibleIndices(len(rows), m.fileIndex)
	m.navigableIndices = navigableFromVisible(rows, m.visibleIndices)
	m.lineNumberWidth = render.MaxLineNumberWidth(rows)

	m.userComments = comments.Reattach(m.userComments, absoluteRawLines(rawLines, m.repoRoot))
	_ = comments.Save(m.commentsPath, m.userComments)
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
	m.editState = editing.Inactive()

	if len(m.flashLines) > 0 {
		return tea.Tick(1500*time.Millisecond, func(time.Time) tea.Msg {
			return FlashExpiredMsg{}
		})
	}
	return nil
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
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
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

	output, err := runCommand("bin-zsh", "kitty-window-tab-id", kittyWindowID)
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
	if len(m.rows) == 0 {
		return "\n    " + lipgloss.NewStyle().Foreground(m.theme.Lipgloss("gray-5")).Render("No changes") + "\n"
	}

	ctx := render.Context{
		Theme:           m.theme,
		RepoRoot:        m.repoRoot,
		Highlighted:     m.highlighted,
		RawLines:        m.rawLines,
		CommentIndex:    m.commentIndex,
		FlashLines:      m.flashLines,
		FoldState:       m.fileIndex.FoldState,
		LineNumberWidth: m.lineNumberWidth,
		ViewportWidth:   m.viewportWidth,
		Cursor:          m.nav.Cursor,
	}

	var builder strings.Builder
	rendered, fileCount := 0, 0
	for _, i := range m.visibleIndices { // Render visible rows within viewport
		if i < m.nav.ViewportOffset { // Track file count for rows before viewport
			if _, ok := m.rows[i].(layout.FileHeaderRow); ok {
				fileCount++
			}
			continue
		}
		if rendered >= m.nav.ViewportHeight {
			break
		}
		rendered++
		switch r := m.rows[i].(type) {
		case layout.FileHeaderRow:
			fileCount++
			s := render.FileHeader(ctx, r, fileCount)
			rendered += strings.Count(s, "\n") - 1
			builder.WriteString(s)
		case layout.SeparatorRow:
			builder.WriteByte('\n')
		case layout.LineRow:
			s := render.CodeLine(ctx, r, i == m.nav.Cursor)
			rendered += strings.Count(s, "\n") - 1
			builder.WriteString(s)
			if m.editState.Active && i == m.editState.RowIndex {
				builder.WriteString(m.editTextArea.View() + "\n")
			}
		}
	}
	if m.statusMessage != "" {
		fmt.Fprintf(&builder, "\n%s\n", m.statusMessage)
	}
	return builder.String()
}

func navigableFromVisible(rows []layout.Row, visibleIndices []int) []int {
	nav := make([]int, 0, len(visibleIndices))
	for _, i := range visibleIndices {
		if _, ok := rows[i].(layout.LineRow); ok {
			nav = append(nav, i)
		}
	}
	return nav
}

func firstMarkedRowIndex(rows []layout.Row) int {
	for i, row := range rows {
		if lr, ok := row.(layout.LineRow); ok && lr.Marker != nil {
			return i
		}
	}
	return 0
}

func findFileHeaders(rows []layout.Row, foldState map[string]bool) navigation.FileIndex {
	var indices []int
	var paths []string
	for i, row := range rows {
		if header, ok := row.(layout.FileHeaderRow); ok {
			indices = append(indices, i)
			paths = append(paths, header.Path)
		}
	}
	if foldState == nil {
		foldState = map[string]bool{}
	}
	return navigation.FileIndex{
		Headers:   indices,
		Paths:     paths,
		FoldState: foldState,
	}
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

	repoRoot, err := git.RepoRoot()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	rows, highlighted, rawLines, err := buildDisplay(repoRoot, th)
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

	fileIndex := findFileHeaders(rows, nil)
	visibleIndices := navigation.VisibleIndices(len(rows), fileIndex)
	navIndices := navigableFromVisible(rows, visibleIndices)
	initialCursor := firstMarkedRowIndex(rows)
	p := tea.NewProgram(model{
		theme:                th,
		rows:                 rows,
		highlighted:          highlighted,
		rawLines:             rawLines,
		watchChannel:         watchChannel,
		commentsWatchChannel: commentsWatchChannel,
		fileIndex:            fileIndex,
		visibleIndices:       visibleIndices,
		navigableIndices:     navIndices,
		lineNumberWidth:      render.MaxLineNumberWidth(rows),
		prevSnapshot:         func() *flash.Snapshot { s := flash.NewSnapshot(rows, rawLines); return &s }(),
		repoRoot:             repoRoot,
		userComments:         userComments,
		commentsPath:         commentsPath,
		commentIndex:         buildCommentIndex(userComments, repoRoot),
		nav: navigation.State{
			Cursor:   initialCursor,
			RowCount: len(rows),
		},
	}, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func buildDisplay(repoRoot string, th *theme.Theme) ([]layout.Row, map[string][]highlight.StyledLine, map[string][]string, error) {
	raw, err := git.Diff(repoRoot)
	if err != nil {
		return nil, nil, nil, err
	}

	fileDiffs := diff.Parse(raw)
	highlighter := highlight.New(th)
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
		rawLines[fileDiff.Path] = strings.Split(string(content), "\n")

		markers := diff.Classify(fileDiff.Hunks)
		rows := layout.Build(fileDiff, markers, len(lines))
		allRows = append(allRows, rows...)
	}

	return allRows, highlightedFiles, rawLines, nil
}

func resolveCommentsPath() (string, error) {
	tmpFolder := os.Getenv("OROSHI_TMP_FOLDER")
	if tmpFolder == "" {
		return "", fmt.Errorf("OROSHI_TMP_FOLDER not set")
	}

	cmd := exec.Command("bin-zsh", "context-slug")
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

// absoluteRawLines converts relative-keyed rawLines to absolute-keyed,
// for use with comments.Reattach which expects absolute paths.
func absoluteRawLines(rawLines map[string][]string, repoRoot string) map[string][]string {
	absolute := make(map[string][]string, len(rawLines))
	for relativePath, lines := range rawLines {
		absolute[filepath.Join(repoRoot, relativePath)] = lines
	}
	return absolute
}

func buildCommentIndex(userComments []comments.Comment, repoRoot string) map[string]string {
	index := make(map[string]string, len(userComments))
	for _, c := range userComments {
		relativePath := strings.TrimPrefix(c.Filepath, repoRoot+"/")
		key := fmt.Sprintf("%s:%d", relativePath, c.LineNumber)
		index[key] = c.Review
	}
	return index
}

