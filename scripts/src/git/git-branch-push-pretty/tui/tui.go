package tui

import (
	"strconv"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/progress"
)

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
// It composes the shared progress model and adds the push summary.
type Model struct {
	progress       progress.Model
	upToDate       bool
	branchName     string
	remoteName     string
	branchColor    int
	remoteColor    int
	fromRef        string
	toRef          string
	remoteMessages []string
}

// ExitCode returns the subprocess exit code after DoneMsg is received.
func (m Model) ExitCode() int {
	return m.progress.ExitCode()
}

// Errors returns accumulated error lines for the caller to print to stderr.
func (m Model) Errors() []string {
	return m.progress.Errors()
}

// FailureOutput returns the raw stderr when the subprocess failed without any
// classified error, so the caller can print what git actually said.
func (m Model) FailureOutput() string {
	return m.progress.FailureOutput()
}

// RawPanel returns the raw output panel content if the panel was open, empty string otherwise.
// Includes the separator to match the in-TUI visual.
func (m Model) RawPanel() string {
	return m.progress.RawPanel()
}

// New creates a TUI model with the given ANSI color index for the progress bar.
func New(ansiColor int) Model {
	return Model{progress: progress.New(ansiColor)}
}

// NewWithSummary creates a TUI model with full summary configuration.
func NewWithSummary(cfg Config) Model {
	return Model{
		progress:    progress.New(7),
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
// It handles the push-specific messages and forwards the others to the shared
// progress model.
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case UpToDateMsg:
		m.upToDate = true
	case RefUpdateMsg:
		m.fromRef = msg.FromRef
		m.toRef = msg.ToRef
	case RemoteMessageMsg:
		m.remoteMessages = append(m.remoteMessages, msg.Text)
	default:
		var cmd tea.Cmd
		m.progress, cmd = m.progress.Update(msg)
		return m, cmd
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
	return m.progress.View()
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
