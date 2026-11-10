// Package tui is the bubbletea model of the pull progress bar.
package tui

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/parser"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/progress"
)

// EventMsg carries a parsed event that the recap needs.
type EventMsg struct {
	Event parser.Event
}

// Model composes the shared progress model and keeps the events for the recap.
type Model struct {
	progress progress.Model
	events   []parser.Event
}

// New creates a model with the given ANSI color index for the progress bar.
func New(ansiColor int) Model {
	return Model{progress: progress.New(ansiColor)}
}

// ExitCode returns the subprocess exit code after DoneMsg is received.
func (m Model) ExitCode() int {
	return m.progress.ExitCode()
}

// RawOutput returns the raw stderr lines of the subprocess.
func (m Model) RawOutput() string {
	return m.progress.RawOutput()
}

// Events returns the branch and tag events in arrival order.
func (m Model) Events() []parser.Event {
	return m.events
}

// Init implements tea.Model.
func (m Model) Init() tea.Cmd {
	return nil
}

// Update implements tea.Model.
// It keeps the events and forwards the other messages to the progress model.
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	if eventMsg, ok := msg.(EventMsg); ok {
		m.events = append(m.events, eventMsg.Event)
		return m, nil
	}
	var cmd tea.Cmd
	m.progress, cmd = m.progress.Update(msg)
	return m, cmd
}

// View implements tea.Model.
func (m Model) View() string {
	return m.progress.View()
}
