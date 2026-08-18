package tui

import (
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
)

func TestInitReturnsNil(t *testing.T) {
	m := New(42)
	cmd := m.Init()
	if cmd != nil {
		t.Error("Init should return nil")
	}
}

func TestViewShowsPhaseNameAfterProgress(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Compressing objects", Percentage: 50})
	view := updated.(Model).View()
	if !strings.Contains(view, "Compressing objects") {
		t.Errorf("view should contain phase name, got: %q", view)
	}
}

func TestViewShowsPercentageAfterProgress(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Writing objects", Percentage: 75})
	view := updated.(Model).View()
	if !strings.Contains(view, "75%") {
		t.Errorf("view should contain percentage, got: %q", view)
	}
}

func TestViewUpdatesPhaseOnNewEvent(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Compressing objects", Percentage: 100})
	m2, _ := m1.Update(ProgressMsg{Phase: "Writing objects", Percentage: 30})
	view := m2.(Model).View()
	if strings.Contains(view, "Compressing objects") {
		t.Error("old phase should be replaced")
	}
	if !strings.Contains(view, "Writing objects") {
		t.Errorf("view should show new phase, got: %q", view)
	}
}

func TestViewEmptyBeforeAnyProgress(t *testing.T) {
	m := New(42)
	view := m.View()
	if view != "" {
		t.Errorf("view should be empty before any progress, got: %q", view)
	}
}

func TestCtrlCQuitsProgram(t *testing.T) {
	m := New(42)
	_, cmd := m.Update(tea.KeyMsg{Type: tea.KeyCtrlC})
	if cmd == nil {
		t.Fatal("ctrl+c should return a command")
	}
	// Execute the command to verify it produces a QuitMsg
	msg := cmd()
	if _, ok := msg.(tea.QuitMsg); !ok {
		t.Errorf("ctrl+c command should produce QuitMsg, got %T", msg)
	}
}

func TestProgressAt100Percent(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Resolving deltas", Percentage: 100})
	view := updated.(Model).View()
	if !strings.Contains(view, "100%") {
		t.Errorf("view should show 100%%, got: %q", view)
	}
}

func TestProgressAt0Percent(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Counting objects", Percentage: 0})
	view := updated.(Model).View()
	if !strings.Contains(view, "0%") {
		t.Errorf("view should show 0%%, got: %q", view)
	}
	if !strings.Contains(view, "Counting objects") {
		t.Errorf("view should show phase name, got: %q", view)
	}
}
