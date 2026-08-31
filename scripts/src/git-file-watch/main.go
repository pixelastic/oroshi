package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/highlight"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/navigation"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/theme"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/watcher"
)

// DiffChangedMsg is sent when the watcher detects a new git diff.
type DiffChangedMsg struct{}

type model struct {
	theme          *theme.Theme
	rows           []layout.Row
	highlighted    map[string][]highlight.StyledLine
	watchChannel   <-chan struct{}
	nav            navigation.State
	fileHeaders    []int
	filePaths      []string
	foldState      map[string]bool
	visibleIndices []int
	pendingKey     string
}

func (m model) Init() tea.Cmd {
	if m.watchChannel == nil {
		return nil
	}
	return waitForChange(m.watchChannel)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case DiffChangedMsg:
		rows, highlighted, err := buildDisplay()
		if err != nil {
			return m, waitForChange(m.watchChannel)
		}
		m.rows = rows
		m.highlighted = highlighted
		m.fileHeaders, m.filePaths = findFileHeaders(rows)
		m.nav.RowCount = len(rows)
		if m.nav.Cursor >= len(rows) {
			m.nav.Cursor = max(0, len(rows)-1)
		}
		m.visibleIndices = navigation.VisibleIndices(len(rows), m.fileHeaders, m.filePaths, m.foldState)
		return m, waitForChange(m.watchChannel)
	case tea.WindowSizeMsg:
		m.nav.ViewportHeight = msg.Height
		return m, nil
	case tea.KeyMsg:
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
		case "z":
			m.pendingKey = "z"
		}
	}
	return m, nil
}

func waitForChange(channel <-chan struct{}) tea.Cmd {
	return func() tea.Msg {
		<-channel
		return DiffChangedMsg{}
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
			builder.WriteString(lineNumber)
			builder.WriteByte(' ')
			builder.WriteString(content)
			builder.WriteByte('\n')
		}
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

	rows, highlighted, err := buildDisplay()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	repoRoot, err := gitRepoRoot()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	watchChannel, err := watcher.Watch(repoRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fileHeaders, filePaths := findFileHeaders(rows)
	foldState := map[string]bool{}
	visibleIndices := navigation.VisibleIndices(len(rows), fileHeaders, filePaths, foldState)
	p := tea.NewProgram(model{
		theme:          th,
		rows:           rows,
		highlighted:    highlighted,
		watchChannel:   watchChannel,
		fileHeaders:    fileHeaders,
		filePaths:      filePaths,
		foldState:      foldState,
		visibleIndices: visibleIndices,
		nav: navigation.State{
			RowCount: len(rows),
		},
	}, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func buildDisplay() ([]layout.Row, map[string][]highlight.StyledLine, error) {
	repoRoot, err := gitRepoRoot()
	if err != nil {
		return nil, nil, err
	}

	raw, err := runGitDiff(repoRoot)
	if err != nil {
		return nil, nil, err
	}

	fileDiffs := diff.Parse(raw)
	highlighter := highlight.New()
	highlightedFiles := make(map[string][]highlight.StyledLine)
	var allRows []layout.Row

	for _, fileDiff := range fileDiffs {
		absolutePath := filepath.Join(repoRoot, fileDiff.Path)
		content, readErr := os.ReadFile(absolutePath)
		if readErr != nil {
			continue
		}

		lines := highlighter.Highlight(fileDiff.Path, string(content))
		highlightedFiles[fileDiff.Path] = lines

		markers := diff.Classify(fileDiff.Hunks)
		rows := layout.Build(fileDiff, markers, len(lines))
		allRows = append(allRows, rows...)
	}

	return allRows, highlightedFiles, nil
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
