package tui

import (
	"testing"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/progress"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/stream"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestInitReturnsNil(t *testing.T) {
	m := New(42)
	assert.Nil(t, m.Init())
}

// --- Forwarding to the progress model ---

func TestViewShowsPhaseAndPercentageAfterProgress(t *testing.T) {
	m := New(42)
	updated, _ := m.Update(progress.PhaseMsg{Phase: "Compressing objects", Percentage: 50})
	view := updated.(Model).View()
	assert.Contains(t, view, "Compressing objects")
	assert.Contains(t, view, "50%")
}

func TestViewEmptyBeforeAnyProgress(t *testing.T) {
	m := New(42)
	assert.Empty(t, m.View())
}

func TestCtrlCQuitsProgram(t *testing.T) {
	m := New(42)
	_, cmd := m.Update(tea.KeyMsg{Type: tea.KeyCtrlC})
	require.NotNil(t, cmd)
	assert.IsType(t, tea.QuitMsg{}, cmd())
}

func TestDoneQuitsAndExposesExitCode(t *testing.T) {
	m := New(42)
	updated, cmd := m.Update(progress.DoneMsg{ExitCode: 128})
	require.NotNil(t, cmd)
	assert.IsType(t, tea.QuitMsg{}, cmd())
	assert.Equal(t, 128, updated.(Model).ExitCode())
}

func TestErrorsAccessibleAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(progress.ErrorMsg{Raw: "[rejected] main -> main"})
	m2, _ := m1.Update(progress.DoneMsg{ExitCode: 1})
	errors := m2.(Model).Errors()
	require.Len(t, errors, 1)
	assert.Equal(t, "[rejected] main -> main", errors[0])
}

func TestViewEmptyAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(progress.DoneMsg{ExitCode: 0})
	assert.Empty(t, m1.(Model).View())
}

func TestFailureOutputReturnsRawLinesOnUnclassifiedFailure(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(stream.LineMsg{Line: "fatal: something unexpected"})
	m2, _ := m1.Update(progress.DoneMsg{ExitCode: 1})
	assert.Equal(t, "fatal: something unexpected", m2.(Model).FailureOutput())
}

func TestRawPanelAccessorAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(stream.LineMsg{Line: "stderr output"})
	m2, _ := m1.Update(tea.KeyMsg{Type: tea.KeyCtrlO})
	m3, _ := m2.Update(progress.DoneMsg{ExitCode: 0})
	panel := m3.(Model).RawPanel()
	assert.Contains(t, panel, "───")
	assert.Contains(t, panel, "stderr output")
}

// --- Up to date handling ---

func TestSummaryShowsUpToDateForSimpleModel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(progress.DoneMsg{ExitCode: 0})
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
	m1, _ := m.Update(progress.DoneMsg{ExitCode: 0})
	summary := m1.(Model).Summary()
	assert.Contains(t, summary, "✔")
	assert.Contains(t, summary, "Branch")
	assert.Contains(t, summary, "feature")
	assert.Contains(t, summary, "pushed")
}

func TestSummaryHidesOriginRemote(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(progress.DoneMsg{ExitCode: 0})
	assert.NotContains(t, m1.(Model).Summary(), "origin")
}

func TestSummaryShowsNonOriginRemote(t *testing.T) {
	m := newNonOriginModel()
	m1, _ := m.Update(progress.DoneMsg{ExitCode: 0})
	summary := m1.(Model).Summary()
	assert.Contains(t, summary, "on remote")
	assert.Contains(t, summary, "upstream")
}

func TestSummaryUpToDateShowsBranch(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(progress.DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	assert.Contains(t, summary, "feature")
	assert.Contains(t, summary, "up to date")
	assert.NotContains(t, summary, "pushed")
}

func TestSummaryUpToDateShowsNonOriginRemote(t *testing.T) {
	m := newNonOriginModel()
	m1, _ := m.Update(UpToDateMsg{})
	m2, _ := m1.Update(progress.DoneMsg{ExitCode: 0})
	assert.Contains(t, m2.(Model).Summary(), "on remote")
}

func TestSummaryIncludesRemoteMessages(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(RemoteMessageMsg{Text: "https://github.com/user/repo/pull/new/feature"})
	m2, _ := m1.Update(progress.DoneMsg{ExitCode: 0})
	assert.Contains(t, m2.(Model).Summary(), "https://github.com/user/repo/pull/new/feature")
}

func TestSummaryNoProgressBarContent(t *testing.T) {
	m := newOriginModel()
	m1, _ := m.Update(progress.PhaseMsg{Phase: "Writing objects", Percentage: 75})
	m2, _ := m1.Update(progress.DoneMsg{ExitCode: 0})
	summary := m2.(Model).Summary()
	assert.NotContains(t, summary, "Writing objects")
	assert.NotContains(t, summary, "75%")
}
