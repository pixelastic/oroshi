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

// Model is the bubbletea model for the push progress TUI.
type Model struct {
	phase      string
	percentage int
	started    bool
	bar        progress.Model
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
	}
	return m, nil
}

// View implements tea.Model.
func (m Model) View() string {
	if !m.started {
		return ""
	}
	return fmt.Sprintf("%s  %s  %d%%", m.phase, m.bar.ViewAs(float64(m.percentage)/100.0), m.percentage)
}
