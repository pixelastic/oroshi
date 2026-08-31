package watcher

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// --- Signature dedup ---

func TestSignalsWhenDiffOutputChanges(t *testing.T) {
	tracker := NewSignatureTracker()

	changed := tracker.Changed("diff --git a/file.go\n+new line")

	assert.True(t, changed)
}

func TestDoesNotSignalWhenDiffOutputIsIdentical(t *testing.T) {
	tracker := NewSignatureTracker()
	tracker.Changed("diff --git a/file.go\n+new line")

	changed := tracker.Changed("diff --git a/file.go\n+new line")

	assert.False(t, changed)
}

func TestSignalsAgainAfterNoChangeFollowedByChange(t *testing.T) {
	tracker := NewSignatureTracker()
	tracker.Changed("diff --git a/file.go\n+first")
	tracker.Changed("diff --git a/file.go\n+first")

	changed := tracker.Changed("diff --git a/file.go\n+second")

	assert.True(t, changed)
}
