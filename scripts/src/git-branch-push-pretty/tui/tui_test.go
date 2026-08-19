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

// --- Raw output toggle (Ctrl+O) ---

func TestCtrlOShowsRawPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "Counting objects: 5"})
	m2, _ := m1.Update(ProgressMsg{Phase: "Counting objects", Percentage: 50})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m3.(Model).View()
	if !strings.Contains(view, "Counting objects: 5") {
		t.Errorf("view should show raw lines after Ctrl+O, got: %q", view)
	}
}

func TestCtrlOAgainHidesRawPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "Counting objects: 5"})
	m2, _ := m1.Update(ProgressMsg{Phase: "Counting objects", Percentage: 50})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m4.(Model).View()
	if strings.Contains(view, "Counting objects: 5") {
		t.Errorf("view should hide raw lines after second Ctrl+O, got: %q", view)
	}
}

func TestRawPanelShowsAllLinesFromBeforeToggle(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "first line"})
	m2, _ := m1.Update(RawLineMsg{Line: "second line"})
	m3, _ := m2.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m4.(Model).View()
	if !strings.Contains(view, "first line") {
		t.Errorf("view should contain first buffered line, got: %q", view)
	}
	if !strings.Contains(view, "second line") {
		t.Errorf("view should contain second buffered line, got: %q", view)
	}
}

func TestRawPanelUpdatesInRealTime(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	m2, _ := m1.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	m3, _ := m2.Update(RawLineMsg{Line: "new line after toggle"})
	view := m3.(Model).View()
	if !strings.Contains(view, "new line after toggle") {
		t.Errorf("view should show lines received after toggle, got: %q", view)
	}
}

func TestMultipleTogglesWork(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	m2, _ := m1.Update(RawLineMsg{Line: "a raw line"})
	// Toggle on
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	if !strings.Contains(m3.(Model).View(), "a raw line") {
		t.Error("first toggle on should show raw panel")
	}
	// Toggle off
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	if strings.Contains(m4.(Model).View(), "a raw line") {
		t.Error("toggle off should hide raw panel")
	}
	// Toggle on again
	m5, _ := m4.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	if !strings.Contains(m5.(Model).View(), "a raw line") {
		t.Error("second toggle on should show raw panel again")
	}
}

func TestRawPanelAccessorAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "stderr output"})
	m2, _ := m1.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	m3, _ := m2.Update(DoneMsg{ExitCode: 0})
	panel := m3.(Model).RawPanel()
	if !strings.Contains(panel, "───") {
		t.Errorf("RawPanel() should include separator, got: %q", panel)
	}
	if !strings.Contains(panel, "stderr output") {
		t.Errorf("RawPanel() should return raw content when panel was open, got: %q", panel)
	}
}

func TestRawPanelAccessorEmptyWhenClosed(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "stderr output"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	panel := m2.(Model).RawPanel()
	if panel != "" {
		t.Errorf("RawPanel() should be empty when panel was closed, got: %q", panel)
	}
}

func TestRawLineMsgBuffersWithoutPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "buffered"})
	m2, _ := m1.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	view := m2.(Model).View()
	if strings.Contains(view, "buffered") {
		t.Error("raw lines should not appear in view when panel is closed")
	}
}

func TestViewSeparatesProgressAndRawPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 50})
	m2, _ := m1.Update(RawLineMsg{Line: "raw"})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m3.(Model).View()
	if !strings.Contains(view, "───") {
		t.Errorf("view should contain a separator between progress and raw panel, got: %q", view)
	}
}

func TestOverwriteReplacesLastRawLine(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Counting", Percentage: 10})
	m2, _ := m1.Update(RawLineMsg{Line: "Counting objects: 50%"})
	m3, _ := m2.Update(RawLineMsg{Line: "Counting objects: 100%", Overwrite: true})
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m4.(Model).View()
	if strings.Contains(view, "50%") {
		t.Errorf("overwritten line should be replaced, got: %q", view)
	}
	if !strings.Contains(view, "100%") {
		t.Errorf("view should show the overwrite line, got: %q", view)
	}
}

func TestOverwriteOnEmptyBufferAppends(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Counting", Percentage: 10})
	m2, _ := m1.Update(RawLineMsg{Line: "first", Overwrite: true})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m3.(Model).View()
	if !strings.Contains(view, "first") {
		t.Errorf("overwrite on empty buffer should append, got: %q", view)
	}
}

func TestViewShowsHintWhenPanelClosed(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 50})
	view := m1.(Model).View()
	if !strings.Contains(view, "ctrl+o") {
		t.Errorf("view should show ctrl+o hint when panel is closed, got: %q", view)
	}
}

func TestViewHidesHintWhenPanelOpen(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 50})
	m2, _ := m1.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m2.(Model).View()
	if strings.Contains(view, "ctrl+o") {
		t.Errorf("view should not show hint when panel is open, got: %q", view)
	}
}

// --- Terminal width / bar sizing ---

func TestWindowSizeMsgSetsTermWidth(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 120, Height: 40})
	model := m1.(Model)
	if model.termWidth != 120 {
		t.Errorf("expected termWidth 120, got %d", model.termWidth)
	}
}

func TestBarWidthShrinksOnNarrowTerminal(t *testing.T) {
	m := New(42)
	// Narrow terminal: bar should shrink below default
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 50, Height: 40})
	model := m1.(Model)
	if model.barWidth() >= 40 {
		t.Errorf("narrow terminal should shrink bar below 40, got %d", model.barWidth())
	}
}

func TestBarWidthCapsAtMaxOnWideTerminal(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 200, Height: 40})
	m2, _ := m1.Update(ProgressMsg{Phase: "Writing objects", Percentage: 50})
	model := m2.(Model)
	if model.barWidth() != 40 {
		t.Errorf("wide terminal should cap bar at 40, got %d", model.barWidth())
	}
}

func TestBarWidthHasMinimum(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 20, Height: 10})
	model := m1.(Model)
	if model.barWidth() < 10 {
		t.Errorf("bar width should have minimum of 10, got %d", model.barWidth())
	}
}
