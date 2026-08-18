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

// --- Done message handling ---

func TestDoneWithZeroExitCodeQuits(t *testing.T) {
	m := New(42)
	_, cmd := m.Update(DoneMsg{ExitCode: 0})
	if cmd == nil {
		t.Fatal("DoneMsg should return a command")
	}
	msg := cmd()
	if _, ok := msg.(tea.QuitMsg); !ok {
		t.Errorf("expected QuitMsg, got %T", msg)
	}
}

func TestDoneWithNonZeroExitCodeQuits(t *testing.T) {
	m := New(42)
	_, cmd := m.Update(DoneMsg{ExitCode: 1})
	if cmd == nil {
		t.Fatal("DoneMsg should return a command")
	}
	msg := cmd()
	if _, ok := msg.(tea.QuitMsg); !ok {
		t.Errorf("expected QuitMsg, got %T", msg)
	}
}

func TestDoneExposesExitCode(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(DoneMsg{ExitCode: 128})
	if updated.(Model).ExitCode() != 128 {
		t.Errorf("expected exit code 128, got %d", updated.(Model).ExitCode())
	}
}

// --- Error message handling ---

func TestErrorMsgAccumulatesRawText(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ErrorMsg{Raw: "rejected"})
	m2, _ := m1.Update(ErrorMsg{Raw: "non-fast-forward"})
	model := m2.(Model)
	if len(model.errors) != 2 {
		t.Errorf("expected 2 errors, got %d", len(model.errors))
	}
}

func TestErrorsAccessibleAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ErrorMsg{Raw: "[rejected] main -> main"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 1})
	model := m2.(Model)
	errors := model.Errors()
	if len(errors) != 1 || errors[0] != "[rejected] main -> main" {
		t.Errorf("expected error text in Errors(), got: %v", errors)
	}
}

func TestViewEmptyOnError(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ErrorMsg{Raw: "rejected"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 1})
	view := m2.(Model).View()
	if view != "" {
		t.Errorf("view should be empty on error (errors go to stderr), got: %q", view)
	}
}

// --- Up to date handling ---

func TestViewEmptyAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(DoneMsg{ExitCode: 0})
	view := m1.(Model).View()
	if view != "" {
		t.Errorf("view should be empty after done (summary printed externally), got: %q", view)
	}
}

func TestSummaryShowsUpToDateForSimpleModel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	if !strings.Contains(summary, "up-to-date") {
		t.Errorf("summary should show up-to-date message, got: %q", summary)
	}
}

// --- Summary line ---

func newOriginModel() Model {
	return NewWithSummary(Config{
		BranchName:  "feature",
		RemoteName:  "origin",
		BranchColor: 42,
		RemoteColor: 73,
	})
}

func newNonOriginModel() Model {
	return NewWithSummary(Config{
		BranchName:  "feature",
		RemoteName:  "upstream",
		BranchColor: 42,
		RemoteColor: 73,
	})
}

func TestSummaryShowsCheckmarkAndBranchPushed(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(DoneMsg{ExitCode: 0})
	summary := m1.(Model).Summary()
	if !strings.Contains(summary, "✔") {
		t.Errorf("summary should contain checkmark, got: %q", summary)
	}
	if !strings.Contains(summary, "Branch") {
		t.Errorf("summary should contain 'Branch' (capitalized), got: %q", summary)
	}
	if !strings.Contains(summary, "feature") {
		t.Errorf("summary should contain branch name, got: %q", summary)
	}
	if !strings.Contains(summary, "pushed") {
		t.Errorf("summary should contain 'pushed', got: %q", summary)
	}
}

func TestSummaryHidesOriginRemote(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(DoneMsg{ExitCode: 0})
	summary := m1.(Model).Summary()
	if strings.Contains(summary, "origin") {
		t.Errorf("summary should not mention origin remote, got: %q", summary)
	}
}

func TestSummaryShowsNonOriginRemote(t *testing.T) {
	m := newNonOriginModel()
	m1, _ := m.Update(DoneMsg{ExitCode: 0})
	summary := m1.(Model).Summary()
	if !strings.Contains(summary, "on remote") {
		t.Errorf("summary should contain 'on remote', got: %q", summary)
	}
	if !strings.Contains(summary, "upstream") {
		t.Errorf("summary should contain remote name, got: %q", summary)
	}
}

func TestSummaryUpToDateShowsBranch(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	if !strings.Contains(summary, "feature") {
		t.Errorf("up-to-date summary should contain branch name, got: %q", summary)
	}
	if !strings.Contains(summary, "up to date") {
		t.Errorf("up-to-date summary should contain 'up to date', got: %q", summary)
	}
	if strings.Contains(summary, "pushed") {
		t.Errorf("up-to-date summary should not contain 'pushed', got: %q", summary)
	}
}

func TestSummaryUpToDateShowsNonOriginRemote(t *testing.T) {
	m := newNonOriginModel()
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	if !strings.Contains(summary, "on remote") {
		t.Errorf("up-to-date summary should mention non-origin remote, got: %q", summary)
	}
}

func TestSummaryIncludesRemoteMessages(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(RemoteMessageMsg{Text: "https://github.com/user/repo/pull/new/feature"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	if !strings.Contains(summary, "https://github.com/user/repo/pull/new/feature") {
		t.Errorf("summary should include remote messages, got: %q", summary)
	}
}

func TestSummaryNoProgressBarContent(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(ProgressMsg{Phase: "Writing objects", Percentage: 75})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	if strings.Contains(summary, "Writing objects") {
		t.Errorf("summary should not contain progress phase, got: %q", summary)
	}
	if strings.Contains(summary, "75%") {
		t.Errorf("summary should not contain percentage, got: %q", summary)
	}
}
