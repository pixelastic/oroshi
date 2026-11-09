// Package progress is the bubbletea model of a progress bar fed by a process
// output stream.
package progress

import (
	"fmt"
	"strconv"
	"strings"

	bubbleprogress "github.com/charmbracelet/bubbles/progress"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/stream"
)

const rawSeparator = "───────────────────────────────────────"

// PhaseMsg carries progress data from parsed git stderr events.
type PhaseMsg struct {
	Phase      string
	Percentage int
}

// DoneMsg signals the subprocess has exited.
type DoneMsg struct {
	ExitCode int
}

// ErrorMsg carries a raw error line from git stderr.
type ErrorMsg struct {
	Raw string
}

// Model is the bubbletea model for the progress bar.
type Model struct {
	phase      string
	percentage int
	started    bool
	bar        bubbleprogress.Model
	errors     []string
	exitCode   int
	done       bool
	rawLines   []string
	showRaw    bool
	termWidth  int
}

// ExitCode returns the subprocess exit code after DoneMsg is received.
func (m Model) ExitCode() int {
	return m.exitCode
}

// Errors returns accumulated error lines for the caller to print to stderr.
func (m Model) Errors() []string {
	return m.errors
}

// FailureOutput returns the raw stderr when the subprocess failed without any
// classified error, so the caller can print what git actually said.
func (m Model) FailureOutput() string {
	if m.exitCode == 0 || len(m.errors) > 0 {
		return ""
	}
	return strings.Join(m.rawLines, "\n")
}

// RawPanel returns the raw output panel content if the panel was open, empty string otherwise.
// Includes the separator to match the in-TUI visual.
func (m Model) RawPanel() string {
	if !m.showRaw || len(m.rawLines) == 0 {
		return ""
	}
	return rawSeparator + "\n" + strings.Join(m.rawLines, "\n")
}

// New creates a progress model with the given ANSI color index for the bar.
func New(ansiColor int) Model {
	bar := bubbleprogress.New(
		bubbleprogress.WithSolidFill(strconv.Itoa(ansiColor)),
		bubbleprogress.WithoutPercentage(),
	)
	return Model{bar: bar}
}

// Init implements tea.Model.
func (m Model) Init() tea.Cmd {
	return nil
}

// Update handles the messages of the progress bar and ignores the others.
// It returns the concrete Model instead of a tea.Model.
func (m Model) Update(msg tea.Msg) (Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		if msg.Type == tea.KeyCtrlC {
			return m, tea.Quit
		}
		if msg.Type == tea.KeyCtrlO {
			m.showRaw = !m.showRaw
		}
	case PhaseMsg:
		m.phase = msg.Phase
		m.percentage = msg.Percentage
		m.started = true
	case ErrorMsg:
		m.errors = append(m.errors, msg.Raw)
	case stream.LineMsg:
		if msg.Overwrite && len(m.rawLines) > 0 {
			m.rawLines[len(m.rawLines)-1] = msg.Line
		} else {
			m.rawLines = append(m.rawLines, msg.Line)
		}
	case tea.WindowSizeMsg:
		m.termWidth = msg.Width
	case DoneMsg:
		m.exitCode = msg.ExitCode
		m.done = true
		return m, tea.Quit
	}
	return m, nil
}

const (
	maxBarWidth = 40
	minBarWidth = 10
)

// barWidth computes the progress bar width from terminal width minus the suffix,
// capped at maxBarWidth (default bubbles width).
func (m Model) barWidth() int {
	if m.termWidth == 0 {
		return maxBarWidth
	}
	// "  " + pct (4 chars max "100%") + "  " + phase + "  " + hint (14 chars)
	suffix := 2 + 4 + 2 + len(m.phase) + 2 + 14
	width := m.termWidth - suffix
	if width > maxBarWidth {
		width = maxBarWidth
	}
	if width < minBarWidth {
		width = minBarWidth
	}
	return width
}

// View renders the bar, and the raw panel when open. It is empty until the
// first PhaseMsg and after DoneMsg.
func (m Model) View() string {
	if m.done {
		return ""
	}
	if !m.started {
		return ""
	}
	m.bar.Width = m.barWidth()
	line := fmt.Sprintf("%s  %3d%%  %s", m.bar.ViewAs(float64(m.percentage)/100.0), m.percentage, m.phase)
	if !m.showRaw {
		hint := lipgloss.NewStyle().Faint(true).Render("ctrl+o raw log")
		line += "  " + hint
	}
	if m.showRaw && len(m.rawLines) > 0 {
		line += "\n" + rawSeparator + "\n" + strings.Join(m.rawLines, "\n")
	}
	return line
}
