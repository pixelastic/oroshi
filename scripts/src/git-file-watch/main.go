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

// GitIndexChangedMsg is sent when .git/index changes (commit, stage, unstage).
type GitIndexChangedMsg struct{}

// CommentsChangedMsg is sent when the comments file changes externally.
type CommentsChangedMsg struct{}

// SyntaxMapChangedMsg is sent when neovim-syntax.json changes on disk.
type SyntaxMapChangedMsg struct{}

// EditorFinishedMsg is sent when the external editor exits.
type EditorFinishedMsg struct{ err error }

// CommitFinishedMsg is sent when the commit process exits.
type CommitFinishedMsg struct{ err error }

// FlashExpiredMsg is sent when the flash highlight should be cleared.
type FlashExpiredMsg struct{}

// ReviewSentMsg is sent when the review has been sent to Claude.
type ReviewSentMsg struct{ err error }

type model struct {
	theme                *theme.Theme
	rows                 []layout.Row
	highlighted          map[string][]highlight.StyledLine
	rawLines             map[string][]string
	watchChannel          <-chan struct{}
	indexWatchChannel     <-chan struct{}
	commentsWatchChannel <-chan struct{}
	syntaxMapWatchChannel <-chan struct{}
	highlighter          *highlight.Highlighter
	nav                  navigation.State
	fileIndex            navigation.FileIndex
	viewContext          navigation.ViewContext
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
	resolveHead          func(string) (string, error)
	oroshiRoot           string
	wrapLines            bool
	showHelp             bool
	reviewSent           bool
	screenFlash          bool
}

func (m model) Init() tea.Cmd {
	var commands []tea.Cmd
	if m.watchChannel != nil {
		commands = append(commands, waitForChange[DiffChangedMsg](m.watchChannel))
	}
	if m.indexWatchChannel != nil {
		commands = append(commands, waitForChange[GitIndexChangedMsg](m.indexWatchChannel))
	}
	if m.commentsWatchChannel != nil {
		commands = append(commands, waitForChange[CommentsChangedMsg](m.commentsWatchChannel))
	}
	if m.syntaxMapWatchChannel != nil {
		commands = append(commands, waitForChange[SyntaxMapChangedMsg](m.syntaxMapWatchChannel))
	}
	return tea.Batch(commands...)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case DiffChangedMsg:
		cmd := m.rebuildDisplay()
		return m, tea.Batch(waitForChange[DiffChangedMsg](m.watchChannel), cmd)
	case GitIndexChangedMsg:
		cmd := m.rebuildDisplay()
		m.clearStaleComments()
		return m, tea.Batch(waitForChange[GitIndexChangedMsg](m.indexWatchChannel), cmd)
	case CommentsChangedMsg:
		m.reloadComments()
		return m, waitForChange[CommentsChangedMsg](m.commentsWatchChannel)
	case SyntaxMapChangedMsg:
		if err := m.highlighter.ReloadSyntaxMap(); err != nil {
			fmt.Fprintln(os.Stderr, err)
			return m, waitForChange[SyntaxMapChangedMsg](m.syntaxMapWatchChannel)
		}
		m.highlighter.InvalidateCache()
		cmd := m.rebuildDisplay()
		return m, tea.Batch(waitForChange[SyntaxMapChangedMsg](m.syntaxMapWatchChannel), cmd)
	case EditorFinishedMsg:
		// tea.ExecProcess blocks the event loop on an unbuffered p.msgs
		// channel. Watcher goroutines that fire during exec consume their
		// signal and queue a message; once exec returns, message delivery
		// order is non-deterministic. Re-subscribe here so watchers are
		// never left disconnected regardless of which message lands last.
		cmd := m.rebuildDisplay()
		return m, tea.Batch(
			waitForChange[DiffChangedMsg](m.watchChannel),
			waitForChange[GitIndexChangedMsg](m.indexWatchChannel),
			cmd,
		)
	case CommitFinishedMsg:
		if msg.err != nil {
			m.statusMessage = "Commit failed"
		}
		// Same re-subscription as EditorFinishedMsg — see comment above.
		cmd := m.rebuildDisplay()
		return m, tea.Batch(
			waitForChange[DiffChangedMsg](m.watchChannel),
			waitForChange[GitIndexChangedMsg](m.indexWatchChannel),
			cmd,
		)
	case ReviewSentMsg:
		m.screenFlash = false
		if msg.err == nil {
			m.reviewSent = true
		}
		return m, nil
	case FlashExpiredMsg:
		m.flashLines = nil
		return m, nil
	case tea.WindowSizeMsg:
		m.nav.ViewportHeight = msg.Height
		m.viewportWidth = msg.Width
		m.refreshIndices()
		return m, nil
	case tea.KeyMsg:
		if m.showHelp {
			m.showHelp = false
			return m, nil
		}
		if m.editState.Active {
			return m.updateEditing(msg)
		}
		return m.updateNormal(msg)
	}
	return m, nil
}

func (m model) updateEditing(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "enter":
		result := editing.Save(m.editState, m.editTextArea.Value())
		commitHash, err := git.Head(m.repoRoot)
		if err != nil {
			m.statusMessage = fmt.Sprintf("error: %s", err)
			m.editState = editing.Inactive()
			return m, nil
		}
		updated, err := applyEditResult(m.userComments, result, commitHash)
		if err != nil {
			m.statusMessage = fmt.Sprintf("error: %s", err)
			m.editState = editing.Inactive()
			return m, nil
		}
		m.userComments = updated
		m.persistComments()
		m.editState = editing.Inactive()
		m.reviewSent = false
		return m, nil
	case "esc", "ctrl+d":
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
			m.nav = navigation.GoToTop(m.nav, m.viewContext)
		}
		return m, nil
	}
	if m.pendingKey == "z" {
		m.pendingKey = ""
		if key == "a" {
			var folded bool
			m.nav, m.fileIndex, folded = navigation.ToggleFold(m.nav, m.fileIndex)
			m.refreshIndices()
			if !folded {
				// Unfold: move cursor to first line of the file
				m.nav = navigation.MoveDownVisible(m.nav, m.viewContext)
			}
		}
		return m, nil
	}
	switch key {
	case "q", "ctrl+c":
		return m, tea.Quit
	case "j":
		m.nav = navigation.MoveDownVisible(m.nav, m.viewContext)
	case "k":
		m.nav = navigation.MoveUpVisible(m.nav, m.viewContext)
	case "l":
		m.nav = navigation.NextFile(m.nav, m.fileIndex, m.viewContext)
	case "h":
		m.nav = navigation.PrevFile(m.nav, m.fileIndex, m.viewContext)
	case "i":
		cmd := editor.NvimCommand(m.rows, m.nav.Cursor, m.repoRoot)
		if cmd == nil {
			return m, nil
		}
		return m, tea.ExecProcess(cmd, func(err error) tea.Msg {
			return EditorFinishedMsg{err: err}
		})
	case "ctrl+r":
		return m.sendReviewToClaude()
	case "ctrl+y":
		return m.copyFilePath()
	case "enter":
		return m.openEditing()
	case "g":
		m.pendingKey = "g"
	case "d", "D":
		m.nav = navigation.PageDown(m.nav, m.viewContext)
	case "u", "U":
		m.nav = navigation.PageUp(m.nav, m.viewContext)
	case "G":
		m.nav = navigation.GoToBottom(m.nav, m.viewContext)
	case "z":
		m.pendingKey = "z"
	case "ctrl+s":
		cmd := exec.Command("bin-zsh", "git-commit-create-all-auto")
		cmd.Dir = m.repoRoot
		return m, tea.ExecProcess(cmd, func(err error) tea.Msg {
			return CommitFinishedMsg{err: err}
		})
	case "x", "delete":
		return m.deleteComment()
	case "?":
		m.showHelp = true
	case "f9":
		m.wrapLines = !m.wrapLines
		m.refreshIndices()
	}
	return m, nil
}

func (m model) deleteComment() (tea.Model, tea.Cmd) {
	lineRow, _, absolutePath, ok := m.cursorLineContext()
	if !ok {
		return m, nil
	}

	m.userComments = comments.Delete(m.userComments, absolutePath, lineRow.LineNumber)
	m.persistComments()

	return m, nil
}

func (m model) openEditing() (tea.Model, tea.Cmd) {
	lineRow, relativePath, absolutePath, ok := m.cursorLineContext()
	if !ok {
		return m, nil
	}

	lineContent := flash.RawLineContent(m.rawLines, relativePath, lineRow.LineNumber)
	existingReview := comments.FindReview(m.userComments, absolutePath, lineRow.LineNumber)

	m.editState = editing.Open(absolutePath, lineRow.LineNumber, lineContent, existingReview, m.nav.Cursor)

	orangeColor := m.theme.Lipgloss("orange")

	// textarea width: viewport minus indent (gutter+linenum+space), borders, padding
	indent := m.lineNumberWidth + 2
	taWidth := m.viewportWidth - indent - 4 // 4 = border(2) + padding(2)
	if taWidth < 30 {
		taWidth = 30
	}

	ta := textarea.New()
	ta.KeyMap.InsertNewline.SetKeys("⏎")
	ta.SetWidth(taWidth)
	ta.SetHeight(3)
	ta.ShowLineNumbers = false
	ta.Prompt = "  "
	ta.FocusedStyle.Base = lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(orangeColor).
		Padding(0, 1)
	ta.FocusedStyle.Text = lipgloss.NewStyle().Foreground(orangeColor)
	ta.FocusedStyle.Placeholder = lipgloss.NewStyle().Foreground(orangeColor)
	ta.FocusedStyle.CursorLine = lipgloss.NewStyle().Foreground(orangeColor)
	if existingReview != "" {
		ta.SetValue(existingReview)
	}
	ta.Focus()
	m.editTextArea = ta

	return m, nil
}

func applyEditResult(userComments []comments.Comment, result editing.SaveResult, commitHash string) ([]comments.Comment, error) {
	if result.IsEmpty {
		return comments.Delete(userComments, result.FilePath, result.LineNumber), nil
	}
	return comments.Upsert(userComments, comments.Comment{
		Filepath:    result.FilePath,
		LineNumber:  result.LineNumber,
		LineContent: result.LineContent,
		Review:      result.Text,
	}, commitHash)
}

func (m *model) rebuildDisplay() tea.Cmd {
	rows, highlighted, rawLines, err := buildDisplay(m.repoRoot, m.highlighter)
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
	m.fileIndex = findFileHeaders(rows, m.fileIndex)
	m.nav.RowCount = len(rows)
	if m.nav.Cursor >= len(rows) {
		m.nav.Cursor = max(0, len(rows)-1)
	}
	m.refreshIndices()
	m.lineNumberWidth = render.MaxLineNumberWidth(rows)

	m.userComments = comments.Reattach(m.userComments, absoluteRawLines(rawLines, m.repoRoot))
	m.persistComments()
	m.editState = editing.Inactive()

	if len(m.flashLines) > 0 {
		return tea.Tick(1500*time.Millisecond, func(time.Time) tea.Msg {
			return FlashExpiredMsg{}
		})
	}
	return nil
}

func (m model) sendReviewToClaude() (tea.Model, tea.Cmd) {
	m.screenFlash = true
	commentCount := len(m.userComments)
	return m, func() tea.Msg {
		tabID, err := currentTabID()
		if err != nil {
			return ReviewSentMsg{err: err}
		}
		windowID, err := claude.FindClaudeWindow(runCommand, tabID)
		if err != nil {
			return ReviewSentMsg{err: err}
		}
		if err := claude.SendReview(runCommand, windowID, commentCount); err != nil {
			return ReviewSentMsg{err: err}
		}
		return ReviewSentMsg{}
	}
}

func (m model) copyFilePath() (tea.Model, tea.Cmd) {
	relativePath := editor.CurrentFilePath(m.rows, m.nav.Cursor)
	if relativePath == "" {
		return m, nil
	}
	absolutePath := filepath.Join(m.repoRoot, relativePath)
	_ = exec.Command("bin-zsh", "clipboard-write", absolutePath).Run()
	return m, nil
}

func (m *model) clearStaleComments() {
	head, err := m.resolveHead(m.repoRoot)
	if err != nil {
		return
	}
	m.userComments = comments.ClearStale(m.userComments, head)
	m.persistComments()
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

func (m *model) persistComments() {
	_ = comments.Save(m.commentsPath, m.userComments)
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
}

func (m model) cursorLineContext() (layout.LineRow, string, string, bool) {
	lineRow, ok := m.rows[m.nav.Cursor].(layout.LineRow)
	if !ok {
		return layout.LineRow{}, "", "", false
	}

	relativePath := editor.CurrentFilePath(m.rows, m.nav.Cursor)
	if relativePath == "" {
		return layout.LineRow{}, "", "", false
	}

	absolutePath := filepath.Join(m.repoRoot, relativePath)
	return lineRow, relativePath, absolutePath, true
}

func (m *model) refreshIndices() {
	visible := navigation.VisibleIndices(len(m.rows), m.fileIndex)
	commentRows := make(map[int]bool)
	var wrapCosts map[int]int
	availableWidth := m.viewportWidth - m.lineNumberWidth - 2
	for i, row := range m.rows {
		lr, ok := row.(layout.LineRow)
		if !ok {
			continue
		}
		key := layout.LineKey(lr.FilePath, lr.LineNumber)
		if m.commentIndex[key] != "" {
			commentRows[i] = true
		}
		if m.wrapLines && availableWidth > 0 {
			rawContent := ""
			if lines, exists := m.rawLines[lr.FilePath]; exists && lr.LineNumber > 0 && lr.LineNumber <= len(lines) {
				rawContent = lines[lr.LineNumber-1]
			}
			count := render.WrapLineCount(rawContent, availableWidth)
			if count > 1 {
				if wrapCosts == nil {
					wrapCosts = make(map[int]int)
				}
				wrapCosts[i] = count
			}
		}
	}
	m.viewContext = navigation.ViewContext{
		Navigable:   navigableFromVisible(m.rows, visible, m.fileIndex.FoldState),
		Visible:     visible,
		Headers:     m.fileIndex.Headers,
		CommentRows: commentRows,
		WrapCosts:   wrapCosts,
	}
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

func waitForChange[T tea.Msg](channel <-chan struct{}) tea.Cmd {
	return func() tea.Msg {
		<-channel
		var zero T
		return zero
	}
}

func (m model) View() string {
	if m.showHelp {
		return m.renderHelp()
	}
	if len(m.rows) == 0 {
		noChanges := lipgloss.NewStyle().Foreground(m.theme.Lipgloss("gray-5")).Render("No changes")
		return "\n    " + noChanges + "\n"
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
		WrapLines:       m.wrapLines,
		Cursor:          m.nav.Cursor,
		ReviewSent:      m.reviewSent,
		ScreenFlash:     m.screenFlash,
		EditingRowIndex: m.editState.RowIndex,
		EditingView:     editingView(m.editState, m.editTextArea),
	}

	var builder strings.Builder
	rendered, fileCount := 0, 0
	for _, i := range m.viewContext.Visible { // Render visible rows within viewport
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
			s := render.FileHeader(ctx, r, fileCount, i == m.nav.Cursor)
			rendered += strings.Count(s, "\n") - 1
			builder.WriteString(s)
		case layout.SeparatorRow:
			builder.WriteByte('\n')
		case layout.BinaryRow:
			s := render.BinaryLine(ctx, i == m.nav.Cursor)
			builder.WriteString(s)
		case layout.LineRow:
			s := render.CodeLine(ctx, r, i == m.nav.Cursor)
			rendered += strings.Count(s, "\n") - 1
			builder.WriteString(s)
		}
	}
	if m.statusMessage != "" {
		fmt.Fprintf(&builder, "\n%s\n", m.statusMessage)
	}
	output := builder.String()
	if m.screenFlash && m.viewportWidth > 0 {
		flashBg := m.theme.Hex("orange-0")
		var flashed strings.Builder
		for _, line := range strings.Split(output, "\n") {
			flashed.WriteString(render.ApplyLineBackground(line, flashBg, m.viewportWidth))
			flashed.WriteByte('\n')
		}
		return flashed.String()
	}
	return output
}

func (m model) renderHelp() string {
	title := lipgloss.NewStyle().
		Bold(true).
		Foreground(m.theme.Lipgloss("yellow")).
		Render("Keybindings")

	dim := lipgloss.NewStyle().Foreground(m.theme.Lipgloss("gray"))
	key := lipgloss.NewStyle().Foreground(m.theme.Lipgloss("yellow")).Bold(true)

	lines := []struct{ k, desc string }{
		{"j / k", "Line down / up"},
		{"d / u", "Half page down / up"},
		{"l / h", "Next / previous file"},
		{"gg", "Go to top"},
		{"G", "Go to bottom"},
		{"za", "Toggle fold"},
		{"enter", "Add/edit comment"},
		{"", "  enter: save, shift+enter: newline, ctrl+d: cancel"},
		{"x", "Delete comment"},
		{"i", "Open in Neovim"},
		{"ctrl+y", "Copy file path"},
		{"r", "Send review to Claude"},
		{"F9", "Toggle line wrap"},
		{"ctrl+s", "Auto-commit all"},
		{"?", "Show this help"},
		{"q", "Quit"},
	}

	var b strings.Builder
	b.WriteString("\n  " + title + "\n\n")
	for _, l := range lines {
		b.WriteString("  " + key.Render(fmt.Sprintf("%-10s", l.k)) + " " + dim.Render(l.desc) + "\n")
	}
	b.WriteString("\n  " + dim.Render("Press any key to close") + "\n")
	return b.String()
}

func editingView(state editing.State, ta textarea.Model) string {
	if !state.Active {
		return ""
	}
	view := ta.View()
	// Inject "Review" title into the top border (replace same-width run of dashes)
	view = strings.Replace(view, "──────────", "─ Review ─", 1)
	return view
}

func navigableFromVisible(rows []layout.Row, visibleIndices []int, foldState map[string]bool) []int {
	nav := make([]int, 0, len(visibleIndices))
	for _, i := range visibleIndices {
		switch r := rows[i].(type) {
		case layout.LineRow:
			nav = append(nav, i)
		case layout.BinaryRow:
			nav = append(nav, i)
		case layout.FileHeaderRow:
			if foldState[r.Path] {
				nav = append(nav, i)
			}
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

func findFileHeaders(rows []layout.Row, previous navigation.FileIndex) navigation.FileIndex {
	var indices []int
	var paths []string
	binaryPaths := map[string]bool{}
	var lastHeader string
	for i, row := range rows {
		if header, ok := row.(layout.FileHeaderRow); ok {
			indices = append(indices, i)
			paths = append(paths, header.Path)
			lastHeader = header.Path
		}
		if _, ok := row.(layout.BinaryRow); ok && lastHeader != "" {
			binaryPaths[lastHeader] = true
		}
	}
	var foldState map[string]bool
	if previous.FoldState == nil {
		foldState = navigation.DefaultFoldState(paths, binaryPaths)
	} else {
		foldState = navigation.FoldNewFiles(previous.FoldState, previous.Paths, paths, binaryPaths)
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

	home, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	syntaxMapPath := filepath.Join(oroshiRoot, "tools/term/zsh/config/theming/dist/neovim-syntax.json")
	grammarDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/parser")
	queryDir := filepath.Join(home, ".local/share/nvim/lazy/nvim-treesitter/queries")
	highlighter := highlight.NewWithTreeSitter(th, syntaxMapPath, grammarDir, queryDir)

	rows, highlighted, rawLines, err := buildDisplay(repoRoot, highlighter)
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

	gitIndexPath, err := watcher.GitIndexPath()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	indexWatchChannel, err := watcher.WatchFile(gitIndexPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	commentsWatchChannel, err := watcher.WatchFile(commentsPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	syntaxMapWatchChannel, err := watcher.WatchFile(syntaxMapPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fileIndex := findFileHeaders(rows, navigation.FileIndex{})
	initialCursor := firstMarkedRowIndex(rows)
	m := model{
		theme:                 th,
		rows:                  rows,
		highlighted:           highlighted,
		rawLines:              rawLines,
		watchChannel:          watchChannel,
		indexWatchChannel:     indexWatchChannel,
		commentsWatchChannel:  commentsWatchChannel,
		syntaxMapWatchChannel: syntaxMapWatchChannel,
		highlighter:           highlighter,
		fileIndex:             fileIndex,
		lineNumberWidth:       render.MaxLineNumberWidth(rows),
		prevSnapshot:          func() *flash.Snapshot { s := flash.NewSnapshot(rows, rawLines); return &s }(),
		resolveHead:           git.Head,
		repoRoot:              repoRoot,
		oroshiRoot:            oroshiRoot,
		userComments:          userComments,
		commentsPath:          commentsPath,
		commentIndex:          buildCommentIndex(userComments, repoRoot),
		nav: navigation.State{
			Cursor:   initialCursor,
			RowCount: len(rows),
		},
	}
	m.refreshIndices()
	p := tea.NewProgram(m, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func buildDisplay(repoRoot string, highlighter *highlight.Highlighter) ([]layout.Row, map[string][]highlight.StyledLine, map[string][]string, error) {
	raw, err := git.Diff(repoRoot)
	if err != nil {
		return nil, nil, nil, err
	}

	fileDiffs := diff.Parse(raw)
	highlightedFiles := make(map[string][]highlight.StyledLine)
	rawLines := make(map[string][]string)
	var allRows []layout.Row

	for _, fileDiff := range fileDiffs {
		if fileDiff.Binary {
			rows := layout.Build(fileDiff, nil, 0)
			allRows = append(allRows, rows...)
			continue
		}

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
		key := layout.LineKey(relativePath, c.LineNumber)
		index[key] = c.Review
	}
	return index
}

