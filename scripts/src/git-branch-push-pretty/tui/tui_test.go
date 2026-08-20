package tui

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	tea "github.com/charmbracelet/bubbletea"
)

func TestInitReturnsNil(t *testing.T) {
	m := New(42)
	assert.Nil(t, m.Init())
}

func TestViewShowsPhaseNameAfterProgress(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Compressing objects", Percentage: 50})
	assert.Contains(t, updated.(Model).View(), "Compressing objects")
}

func TestViewShowsPercentageAfterProgress(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Writing objects", Percentage: 75})
	assert.Contains(t, updated.(Model).View(), "75%")
}

func TestViewUpdatesPhaseOnNewEvent(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Compressing objects", Percentage: 100})
	m2, _ := m1.Update(ProgressMsg{Phase: "Writing objects", Percentage: 30})
	view := m2.(Model).View()
	assert.NotContains(t, view, "Compressing objects")
	assert.Contains(t, view, "Writing objects")
}

func TestViewEmptyBeforeAnyProgress(t *testing.T) {
	m := New(42)
	assert.Empty(t, m.View())
}

func TestCtrlCQuitsProgram(t *testing.T) {
	m := New(42)
	_, cmd := m.Update(tea.KeyMsg{Type: tea.KeyCtrlC})
	require.NotNil(t, cmd)
	msg := cmd()
	assert.IsType(t, tea.QuitMsg{}, msg)
}

func TestProgressAt100Percent(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Resolving deltas", Percentage: 100})
	assert.Contains(t, updated.(Model).View(), "100%")
}

func TestProgressAt0Percent(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(ProgressMsg{Phase: "Counting objects", Percentage: 0})
	view := updated.(Model).View()
	assert.Contains(t, view, "0%")
	assert.Contains(t, view, "Counting objects")
}

// --- Done message handling ---

func TestDoneWithZeroExitCodeQuits(t *testing.T) {
	m := New(42)
	_, cmd := m.Update(DoneMsg{ExitCode: 0})
	require.NotNil(t, cmd)
	assert.IsType(t, tea.QuitMsg{}, cmd())
}

func TestDoneWithNonZeroExitCodeQuits(t *testing.T) {
	m := New(42)
	_, cmd := m.Update(DoneMsg{ExitCode: 1})
	require.NotNil(t, cmd)
	assert.IsType(t, tea.QuitMsg{}, cmd())
}

func TestDoneExposesExitCode(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(DoneMsg{ExitCode: 128})
	assert.Equal(t, 128, updated.(Model).ExitCode())
}

// --- Error message handling ---

func TestErrorMsgAccumulatesRawText(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ErrorMsg{Raw: "rejected"})
	m2, _ := m1.Update(ErrorMsg{Raw: "non-fast-forward"})
	assert.Len(t, m2.(Model).errors, 2)
}

func TestErrorsAccessibleAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ErrorMsg{Raw: "[rejected] main -> main"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 1})
	errors := m2.(Model).Errors()
	require.Len(t, errors, 1)
	assert.Equal(t, "[rejected] main -> main", errors[0])
}

func TestViewEmptyOnError(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ErrorMsg{Raw: "rejected"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 1})
	assert.Empty(t, m2.(Model).View())
}

// --- Up to date handling ---

func TestViewEmptyAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(DoneMsg{ExitCode: 0})
	assert.Empty(t, m1.(Model).View())
}

func TestSummaryShowsUpToDateForSimpleModel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	assert.Contains(t, m2.(Model).Summary(), "up-to-date")
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
	assert.Contains(t, summary, "✔")
	assert.Contains(t, summary, "Branch")
	assert.Contains(t, summary, "feature")
	assert.Contains(t, summary, "pushed")
}

func TestSummaryHidesOriginRemote(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(DoneMsg{ExitCode: 0})
	assert.NotContains(t, m1.(Model).Summary(), "origin")
}

func TestSummaryShowsNonOriginRemote(t *testing.T) {
	m := newNonOriginModel()
	m1, _ := m.Update(DoneMsg{ExitCode: 0})
	summary := m1.(Model).Summary()
	assert.Contains(t, summary, "on remote")
	assert.Contains(t, summary, "upstream")
}

func TestSummaryUpToDateShowsBranch(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	assert.Contains(t, summary, "feature")
	assert.Contains(t, summary, "up to date")
	assert.NotContains(t, summary, "pushed")
}

func TestSummaryUpToDateShowsNonOriginRemote(t *testing.T) {
	m := newNonOriginModel()
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	assert.Contains(t, m2.(Model).Summary(), "on remote")
}

func TestSummaryIncludesRemoteMessages(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(RemoteMessageMsg{Text: "https://github.com/user/repo/pull/new/feature"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	assert.Contains(t, m2.(Model).Summary(), "https://github.com/user/repo/pull/new/feature")
}

func TestSummaryNoProgressBarContent(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(ProgressMsg{Phase: "Writing objects", Percentage: 75})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	assert.NotContains(t, summary, "Writing objects")
	assert.NotContains(t, summary, "75%")
}

// --- Raw output toggle (Ctrl+O) ---

func TestCtrlOShowsRawPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "Counting objects: 5"})
	m2, _ := m1.Update(ProgressMsg{Phase: "Counting objects", Percentage: 50})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.Contains(t, m3.(Model).View(), "Counting objects: 5")
}

func TestCtrlOAgainHidesRawPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "Counting objects: 5"})
	m2, _ := m1.Update(ProgressMsg{Phase: "Counting objects", Percentage: 50})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.NotContains(t, m4.(Model).View(), "Counting objects: 5")
}

func TestRawPanelShowsAllLinesFromBeforeToggle(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "first line"})
	m2, _ := m1.Update(RawLineMsg{Line: "second line"})
	m3, _ := m2.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m4.(Model).View()
	assert.Contains(t, view, "first line")
	assert.Contains(t, view, "second line")
}

func TestRawPanelUpdatesInRealTime(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	m2, _ := m1.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	m3, _ := m2.Update(RawLineMsg{Line: "new line after toggle"})
	assert.Contains(t, m3.(Model).View(), "new line after toggle")
}

func TestMultipleTogglesWork(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	m2, _ := m1.Update(RawLineMsg{Line: "a raw line"})
	// Toggle on
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.Contains(t, m3.(Model).View(), "a raw line")
	// Toggle off
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.NotContains(t, m4.(Model).View(), "a raw line")
	// Toggle on again
	m5, _ := m4.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.Contains(t, m5.(Model).View(), "a raw line")
}

func TestRawPanelAccessorAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "stderr output"})
	m2, _ := m1.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	m3, _ := m2.Update(DoneMsg{ExitCode: 0})
	panel := m3.(Model).RawPanel()
	assert.Contains(t, panel, "───")
	assert.Contains(t, panel, "stderr output")
}

func TestRawPanelAccessorEmptyWhenClosed(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "stderr output"})
	m2, _ := m1.Update(DoneMsg{ExitCode: 0})
	assert.Empty(t, m2.(Model).RawPanel())
}

func TestRawLineMsgBuffersWithoutPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(RawLineMsg{Line: "buffered"})
	m2, _ := m1.Update(ProgressMsg{Phase: "Writing", Percentage: 10})
	assert.NotContains(t, m2.(Model).View(), "buffered")
}

func TestViewSeparatesProgressAndRawPanel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 50})
	m2, _ := m1.Update(RawLineMsg{Line: "raw"})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.Contains(t, m3.(Model).View(), "───")
}

func TestOverwriteReplacesLastRawLine(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Counting", Percentage: 10})
	m2, _ := m1.Update(RawLineMsg{Line: "Counting objects: 50%"})
	m3, _ := m2.Update(RawLineMsg{Line: "Counting objects: 100%", Overwrite: true})
	m4, _ := m3.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	view := m4.(Model).View()
	assert.NotContains(t, view, "50%")
	assert.Contains(t, view, "100%")
}

func TestOverwriteOnEmptyBufferAppends(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Counting", Percentage: 10})
	m2, _ := m1.Update(RawLineMsg{Line: "first", Overwrite: true})
	m3, _ := m2.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.Contains(t, m3.(Model).View(), "first")
}

func TestViewShowsHintWhenPanelClosed(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 50})
	assert.Contains(t, m1.(Model).View(), "ctrl+o")
}

func TestViewHidesHintWhenPanelOpen(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(ProgressMsg{Phase: "Writing", Percentage: 50})
	m2, _ := m1.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	assert.NotContains(t, m2.(Model).View(), "ctrl+o")
}

// --- Terminal width / bar sizing ---

func TestWindowSizeMsgSetsTermWidth(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 120, Height: 40})
	assert.Equal(t, 120, m1.(Model).termWidth)
}

func TestBarWidthShrinksOnNarrowTerminal(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 50, Height: 40})
	assert.Less(t, m1.(Model).barWidth(), 40)
}

func TestBarWidthCapsAtMaxOnWideTerminal(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 200, Height: 40})
	m2, _ := m1.Update(ProgressMsg{Phase: "Writing objects", Percentage: 50})
	assert.Equal(t, 40, m2.(Model).barWidth())
}

func TestBarWidthHasMinimum(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(tea.WindowSizeMsg{Width: 20, Height: 10})
	assert.GreaterOrEqual(t, m1.(Model).barWidth(), 10)
}
