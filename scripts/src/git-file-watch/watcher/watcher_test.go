package watcher

import (
	"testing"

	"github.com/fsnotify/fsnotify"
	"github.com/stretchr/testify/assert"
)

// --- isMeaningfulEvent ---

func TestGitIndexWriteIsMeaningful(t *testing.T) {
	event := fsnotify.Event{Name: "/repo/.git/index", Op: fsnotify.Write}

	assert.True(t, isMeaningfulEvent(event))
}

// --- shouldIgnoreDirectory ---

func TestGitDirIsIgnored(t *testing.T) {
	ignored := map[string]bool{".git": true}

	assert.True(t, shouldIgnoreDirectory(".git", ignored))
	assert.True(t, shouldIgnoreDirectory(".git/objects", ignored))
	assert.True(t, shouldIgnoreDirectory(".git/refs", ignored))
}

// --- gitIndexPath ---

func TestGitIndexPathReturnsGitIndex(t *testing.T) {
	result := GitIndexPath("/repo")

	assert.Equal(t, "/repo/.git/index", result)
}

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
