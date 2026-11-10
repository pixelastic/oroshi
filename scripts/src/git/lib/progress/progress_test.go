package progress

import (
	"testing"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/stream"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// update applies msgs in order and returns the resulting model.
func update(m Model, msgs ...tea.Msg) Model {
	for _, msg := range msgs {
		m, _ = m.Update(msg)
	}
	return m
}

// --- Phase and percentage ---

func TestStoresLatestPhaseAndPercentage(t *testing.T) {
	m := update(New(42),
		PhaseMsg{Phase: "Compressing objects", Percentage: 100},
		PhaseMsg{Phase: "Writing objects", Percentage: 30},
	)
	view := m.View()
	assert.Contains(t, view, "Writing objects")
	assert.Contains(t, view, "30%")
	assert.NotContains(t, view, "Compressing objects")
}

func TestViewEmptyBeforeAnyPhase(t *testing.T) {
	assert.Empty(t, New(42).View())
}

func TestViewShowsZeroAndFullPercentage(t *testing.T) {
	assert.Contains(t, update(New(42), PhaseMsg{Phase: "Counting", Percentage: 0}).View(), "0%")
	assert.Contains(t, update(New(42), PhaseMsg{Phase: "Resolving", Percentage: 100}).View(), "100%")
}

// --- Done and errors ---

func TestReportsExitCodeOnceDone(t *testing.T) {
	m := update(New(42), DoneMsg{ExitCode: 128})
	assert.Equal(t, 128, m.ExitCode())
}

func TestDoneQuitsProgram(t *testing.T) {
	_, cmd := New(42).Update(DoneMsg{ExitCode: 1})
	require.NotNil(t, cmd)
	assert.IsType(t, tea.QuitMsg{}, cmd())
}

func TestViewEmptyAfterDone(t *testing.T) {
	m := update(New(42), PhaseMsg{Phase: "Writing", Percentage: 50}, DoneMsg{})
	assert.Empty(t, m.View())
}

func TestRecordsErrors(t *testing.T) {
	m := update(New(42), ErrorMsg{Raw: "rejected"}, ErrorMsg{Raw: "non-fast-forward"})
	assert.Equal(t, []string{"rejected", "non-fast-forward"}, m.Errors())
}

func TestCtrlCQuitsProgram(t *testing.T) {
	_, cmd := New(42).Update(tea.KeyMsg{Type: tea.KeyCtrlC})
	require.NotNil(t, cmd)
	assert.IsType(t, tea.QuitMsg{}, cmd())
}

// --- Failure output ---

func TestFailureOutputReturnsRawLinesOnUnclassifiedFailure(t *testing.T) {
	m := update(New(42), stream.LineMsg{Line: "fatal: something unexpected"}, DoneMsg{ExitCode: 1})
	assert.Equal(t, "fatal: something unexpected", m.FailureOutput())
}

func TestFailureOutputEmptyOnSuccess(t *testing.T) {
	m := update(New(42), stream.LineMsg{Line: "Everything up-to-date"}, DoneMsg{ExitCode: 0})
	assert.Empty(t, m.FailureOutput())
}

func TestFailureOutputEmptyWhenErrorsAlreadyClassified(t *testing.T) {
	m := update(New(42),
		stream.LineMsg{Line: "! [rejected] main -> main"},
		ErrorMsg{Raw: "! [rejected] main -> main"},
		DoneMsg{ExitCode: 1},
	)
	assert.Empty(t, m.FailureOutput())
}

// --- Raw output ---

func TestRawOutputReturnsRawLinesEvenWhenErrorsAreClassified(t *testing.T) {
	m := update(New(42),
		stream.LineMsg{Line: "fatal: not a repository"},
		ErrorMsg{Raw: "not a repository"},
		stream.LineMsg{Line: "Please make sure you have the correct access rights"},
		DoneMsg{ExitCode: 128},
	)
	assert.Equal(t, "fatal: not a repository\nPlease make sure you have the correct access rights", m.RawOutput())
}

// --- Raw output toggle (Ctrl+O) ---

var ctrlO = tea.KeyMsg{Type: tea.KeyCtrlO}

func TestCtrlOShowsRawPanel(t *testing.T) {
	m := update(New(42), stream.LineMsg{Line: "Counting objects: 5"}, PhaseMsg{Phase: "Counting", Percentage: 50}, ctrlO)
	assert.Contains(t, m.View(), "Counting objects: 5")
}

func TestCtrlOAgainHidesRawPanel(t *testing.T) {
	m := update(New(42), stream.LineMsg{Line: "Counting objects: 5"}, PhaseMsg{Phase: "Counting", Percentage: 50}, ctrlO, ctrlO)
	assert.NotContains(t, m.View(), "Counting objects: 5")
}

func TestRawPanelUpdatesInRealTime(t *testing.T) {
	m := update(New(42), PhaseMsg{Phase: "Writing", Percentage: 10}, ctrlO, stream.LineMsg{Line: "new line after toggle"})
	assert.Contains(t, m.View(), "new line after toggle")
}

func TestLineMessageBuffersWithoutPanel(t *testing.T) {
	m := update(New(42), stream.LineMsg{Line: "buffered"}, PhaseMsg{Phase: "Writing", Percentage: 10})
	assert.NotContains(t, m.View(), "buffered")
}

func TestViewSeparatesProgressAndRawPanel(t *testing.T) {
	m := update(New(42), PhaseMsg{Phase: "Writing", Percentage: 50}, stream.LineMsg{Line: "raw"}, ctrlO)
	assert.Contains(t, m.View(), "───")
}

func TestOverwriteReplacesLastRawLine(t *testing.T) {
	m := update(New(42),
		PhaseMsg{Phase: "Counting", Percentage: 10},
		stream.LineMsg{Line: "Counting objects: 50%"},
		stream.LineMsg{Line: "Counting objects: 100%", Overwrite: true},
		ctrlO,
	)
	view := m.View()
	assert.NotContains(t, view, "50%")
	assert.Contains(t, view, "100%")
}

func TestOverwriteOnEmptyBufferAppends(t *testing.T) {
	m := update(New(42), PhaseMsg{Phase: "Counting", Percentage: 10}, stream.LineMsg{Line: "first", Overwrite: true}, ctrlO)
	assert.Contains(t, m.View(), "first")
}

func TestViewShowsHintWhenPanelClosed(t *testing.T) {
	m := update(New(42), PhaseMsg{Phase: "Writing", Percentage: 50})
	assert.Contains(t, m.View(), "ctrl+o")
}

func TestViewHidesHintWhenPanelOpen(t *testing.T) {
	m := update(New(42), PhaseMsg{Phase: "Writing", Percentage: 50}, ctrlO)
	assert.NotContains(t, m.View(), "ctrl+o")
}

func TestRawPanelAccessorAfterDone(t *testing.T) {
	m := update(New(42), stream.LineMsg{Line: "stderr output"}, ctrlO, DoneMsg{})
	panel := m.RawPanel()
	assert.Contains(t, panel, "───")
	assert.Contains(t, panel, "stderr output")
}

func TestRawPanelAccessorEmptyWhenClosed(t *testing.T) {
	m := update(New(42), stream.LineMsg{Line: "stderr output"}, DoneMsg{})
	assert.Empty(t, m.RawPanel())
}

// --- Terminal width / bar sizing ---

func TestBarWidthShrinksOnNarrowTerminal(t *testing.T) {
	m := update(New(42), tea.WindowSizeMsg{Width: 50, Height: 40})
	assert.Less(t, m.barWidth(), 40)
}

func TestBarWidthCapsAtMaxOnWideTerminal(t *testing.T) {
	m := update(New(42), tea.WindowSizeMsg{Width: 200, Height: 40}, PhaseMsg{Phase: "Writing objects", Percentage: 50})
	assert.Equal(t, 40, m.barWidth())
}

func TestBarWidthHasMinimum(t *testing.T) {
	m := update(New(42), tea.WindowSizeMsg{Width: 20, Height: 10})
	assert.GreaterOrEqual(t, m.barWidth(), 10)
}
