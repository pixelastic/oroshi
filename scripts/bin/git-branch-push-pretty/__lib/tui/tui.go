package tui

import (
	"fmt"
	"strconv"

	"github.com/charmbracelet/bubbles/progress"
	tea "github.com/charmbracelet/bubbletea"
)

// ProgressMsg carries progress data from parsed git stderr events.
type ProgressMsg struct {
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

// UpToDateMsg signals "Everything up-to-date" was detected.
type UpToDateMsg struct{}

// Model is the bubbletea model for the push progress TUI.
type Model struct {
	phase      string
	percentage int
	started    bool
	bar        progress.Model
	errors     []string
	upToDate   bool
	exitCode   int
	done       bool
}

// ExitCode returns the subprocess exit code after DoneMsg is received.
func (m Model) ExitCode() int {
	return m.exitCode
}

// Errors returns accumulated error lines for the caller to print to stderr.
func (m Model) Errors() []string {
	return m.errors
}

// New creates a TUI model with the given ANSI color index for the progress bar.
func New(ansiColor int) Model {
	bar := progress.New(
		progress.WithSolidFill(strconv.Itoa(ansiColor)),
		progress.WithoutPercentage(),
	)
	return Model{bar: bar}
}

// Init implements tea.Model.
func (m Model) Init() tea.Cmd {
	return nil
}

// Update implements tea.Model.
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		if msg.Type == tea.KeyCtrlC {
			return m, tea.Quit
		}
	case ProgressMsg:
		m.phase = msg.Phase
		m.percentage = msg.Percentage
		m.started = true
	case ErrorMsg:
		m.errors = append(m.errors, msg.Raw)
	case UpToDateMsg:
		m.upToDate = true
	case DoneMsg:
		m.exitCode = msg.ExitCode
		m.done = true
		return m, tea.Quit
	}
	return m, nil
}

// View implements tea.Model.
func (m Model) View() string {
	if m.done {
		if m.upToDate {
			return "Already up-to-date"
		}
		if len(m.errors) > 0 {
			return ""
		}
		return "Push complete"
	}
	if !m.started {
		return ""
	}
	return fmt.Sprintf("%s  %s  %d%%", m.phase, m.bar.ViewAs(float64(m.percentage)/100.0), m.percentage)
}
