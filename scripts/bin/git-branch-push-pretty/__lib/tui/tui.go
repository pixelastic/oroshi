package tui

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/charmbracelet/bubbles/progress"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
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

// RefUpdateMsg carries ref update data from parsed git stderr.
type RefUpdateMsg struct {
	FromRef string
	ToRef   string
}

// RemoteMessageMsg carries a remote message line (e.g. PR creation URL).
type RemoteMessageMsg struct {
	Text string
}

// Config holds the initial configuration for the TUI model.
type Config struct {
	BranchName  string
	RemoteName  string
	BranchColor int
	RemoteColor int
}

// Model is the bubbletea model for the push progress TUI.
type Model struct {
	phase          string
	percentage     int
	started        bool
	bar            progress.Model
	errors         []string
	upToDate       bool
	exitCode       int
	done           bool
	branchName     string
	remoteName     string
	branchColor    int
	remoteColor    int
	icon           string
	fromRef        string
	toRef          string
	remoteMessages []string
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

// NewWithSummary creates a TUI model with full summary configuration.
func NewWithSummary(cfg Config) Model {
	bar := progress.New(
		progress.WithSolidFill("7"),
		progress.WithoutPercentage(),
	)
	return Model{
		bar:         bar,
		branchName:  cfg.BranchName,
		remoteName:  cfg.RemoteName,
		branchColor: cfg.BranchColor,
		remoteColor: cfg.RemoteColor,
	}
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
	case RefUpdateMsg:
		m.fromRef = msg.FromRef
		m.toRef = msg.ToRef
	case RemoteMessageMsg:
		m.remoteMessages = append(m.remoteMessages, msg.Text)
	case DoneMsg:
		m.exitCode = msg.ExitCode
		m.done = true
		return m, tea.Quit
	}
	return m, nil
}

// Summary returns the styled summary line for the caller to print after p.Run().
// BubbleTea clears its render area on exit, so the summary must be printed externally.
func (m Model) Summary() string {
	return m.viewSummary()
}

// View implements tea.Model.
func (m Model) View() string {
	if m.done {
		return ""
	}
	if !m.started {
		return ""
	}
	return fmt.Sprintf("%s  %3d%%  %s", m.bar.ViewAs(float64(m.percentage)/100.0), m.percentage, m.phase)
}

func (m Model) viewSummary() string {
	// No summary config — fallback to plain text (backward compat with New())
	if m.branchName == "" {
		if m.upToDate {
			return "Already up-to-date"
		}
		return "Push complete"
	}

	successStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("2"))
	branchStyle := lipgloss.NewStyle().Foreground(lipgloss.Color(strconv.Itoa(m.branchColor)))

	summary := successStyle.Render("✔") + " Branch " + branchStyle.Render(m.branchName)

	if m.upToDate {
		summary += " up to date"
	} else {
		summary += " pushed"
	}

	// Only mention remote when it's not the default
	if m.remoteName != "origin" {
		remoteStyle := lipgloss.NewStyle().Foreground(lipgloss.Color(strconv.Itoa(m.remoteColor)))
		summary += " on remote " + remoteStyle.Render(m.remoteName)
	}

	if len(m.remoteMessages) > 0 {
		summary += "\n" + strings.Join(m.remoteMessages, "\n")
	}

	return summary
}
