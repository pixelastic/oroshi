package tui

import (
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/parser"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/progress"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestKeepsEventsInArrivalOrder(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(EventMsg{Event: parser.Event{Type: parser.BranchUpdate, Branch: "main"}})
	m2, _ := m1.Update(EventMsg{Event: parser.Event{Type: parser.NewTag, Tag: "v1"}})
	events := m2.(Model).Events()
	require.Len(t, events, 2)
	assert.Equal(t, "main", events[0].Branch)
	assert.Equal(t, "v1", events[1].Tag)
}

func TestForwardsProgressToTheSharedModel(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(progress.PhaseMsg{Phase: "Receiving objects", Percentage: 50})
	assert.Contains(t, m1.(Model).View(), "Receiving objects")
}

func TestExposesExitCodeAfterDone(t *testing.T) {
	m := New(42)
	m1, _ := m.Update(progress.DoneMsg{ExitCode: 128})
	assert.Equal(t, 128, m1.(Model).ExitCode())
}
