package watcher

import (
	"bufio"
	"crypto/sha256"
	"fmt"
	"os/exec"
	"strings"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/git"
)

const (
	debounceQuiet    = 200 * time.Millisecond
	debounceDeadline = 1 * time.Second
)

// SignatureTracker detects whether git diff output has changed since the last check.
type SignatureTracker struct {
	lastHash [32]byte
	hasLast  bool
}

func NewSignatureTracker() *SignatureTracker {
	return &SignatureTracker{}
}

// Changed returns true if diffOutput differs from the previous call.
func (s *SignatureTracker) Changed(diffOutput string) bool {
	hash := sha256.Sum256([]byte(diffOutput))
	if s.hasLast && hash == s.lastHash {
		return false
	}
	s.lastHash = hash
	s.hasLast = true
	return true
}

// Watch watches repoRoot for meaningful file changes and sends a signal
// on the returned channel when the git diff output changes.
func Watch(repoRoot string) (<-chan struct{}, error) {
	fsWatcher, err := fsnotify.NewWatcher()
	if err != nil {
		return nil, fmt.Errorf("creating fsnotify watcher: %w", err)
	}

	ignoredDirs, err := gitIgnoredDirectories(repoRoot)
	if err != nil {
		_ = fsWatcher.Close()
		return nil, err
	}

	err = addDirectoriesRecursive(fsWatcher, repoRoot, ignoredDirs)
	if err != nil {
		_ = fsWatcher.Close()
		return nil, fmt.Errorf("adding watch paths: %w", err)
	}

	signals := make(chan struct{}, 1)
	go debounceLoop(fsWatcher, repoRoot, signals)

	return signals, nil
}

func debounceLoop(fsWatcher *fsnotify.Watcher, repoRoot string, signals chan<- struct{}) {
	defer func() { _ = fsWatcher.Close() }()

	tracker := NewSignatureTracker()
	// Seed the tracker with current diff so initial identical diffs don't signal
	if initial, err := git.Diff(repoRoot); err == nil {
		tracker.Changed(initial)
	}

	var quietTimer *time.Timer
	var deadlineTimer *time.Timer

	resetQuiet := func() {
		if quietTimer != nil {
			quietTimer.Stop()
		}
		quietTimer = time.NewTimer(debounceQuiet)
	}

	startDeadline := func() {
		if deadlineTimer == nil {
			deadlineTimer = time.NewTimer(debounceDeadline)
		}
	}

	fire := func() {
		if deadlineTimer != nil {
			deadlineTimer.Stop()
			deadlineTimer = nil
		}
		diffOutput, err := git.Diff(repoRoot)
		if err != nil {
			return
		}
		if !tracker.Changed(diffOutput) {
			return
		}
		select {
		case signals <- struct{}{}:
		default:
		}
	}

	for {
		var quietCh <-chan time.Time
		if quietTimer != nil {
			quietCh = quietTimer.C
		}
		var deadlineCh <-chan time.Time
		if deadlineTimer != nil {
			deadlineCh = deadlineTimer.C
		}

		select {
		case event, ok := <-fsWatcher.Events:
			if !ok {
				return
			}
			if !isMeaningfulEvent(event) {
				continue
			}
			resetQuiet()
			startDeadline()
		case _, ok := <-fsWatcher.Errors:
			if !ok {
				return
			}
		case <-quietCh:
			fire()
		case <-deadlineCh:
			if quietTimer != nil {
				quietTimer.Stop()
			}
			fire()
		}
	}
}

func isMeaningfulEvent(event fsnotify.Event) bool {
	return event.Op&(fsnotify.Write|fsnotify.Create|fsnotify.Remove|fsnotify.Rename) != 0
}

func gitIgnoredDirectories(repoRoot string) (map[string]bool, error) {
	cmd := exec.Command("git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory")
	cmd.Dir = repoRoot
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("listing ignored directories: %w", err)
	}

	ignored := make(map[string]bool)
	ignored[".git"] = true

	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		dir := strings.TrimSuffix(strings.TrimSpace(scanner.Text()), "/")
		if dir != "" {
			ignored[dir] = true
		}
	}

	return ignored, nil
}

func addDirectoriesRecursive(fsWatcher *fsnotify.Watcher, root string, ignoredDirs map[string]bool) error {
	cmd := exec.Command("find", root, "-type", "d")
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("listing directories: %w", err)
	}

	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		dir := scanner.Text()
		relative := strings.TrimPrefix(dir, root+"/")

		if shouldIgnoreDirectory(relative, ignoredDirs) {
			continue
		}
		if err := fsWatcher.Add(dir); err != nil {
			return fmt.Errorf("watching %s: %w", dir, err)
		}
	}

	return nil
}

func shouldIgnoreDirectory(relativePath string, ignoredDirs map[string]bool) bool {
	parts := strings.Split(relativePath, "/")
	for i := range parts {
		prefix := strings.Join(parts[:i+1], "/")
		if ignoredDirs[prefix] {
			return true
		}
	}
	return false
}

