package watcher

import (
	"fmt"
	"path/filepath"

	"github.com/fsnotify/fsnotify"
)

// WatchFile watches a single file for changes and sends a signal on the
// returned channel when the file is written, created, or removed.
func WatchFile(filePath string) (<-chan struct{}, error) {
	fsWatcher, err := fsnotify.NewWatcher()
	if err != nil {
		return nil, fmt.Errorf("creating file watcher: %w", err)
	}

	dir := filepath.Dir(filePath)
	if err := fsWatcher.Add(dir); err != nil {
		_ = fsWatcher.Close()
		return nil, fmt.Errorf("watching directory %s: %w", dir, err)
	}

	signals := make(chan struct{}, 1)
	go fileWatchLoop(fsWatcher, filePath, signals)

	return signals, nil
}

func fileWatchLoop(fsWatcher *fsnotify.Watcher, targetPath string, signals chan<- struct{}) {
	defer func() { _ = fsWatcher.Close() }()

	targetName := filepath.Base(targetPath)
	for {
		select {
		case event, ok := <-fsWatcher.Events:
			if !ok {
				return
			}
			if filepath.Base(event.Name) != targetName {
				continue
			}
			if !isMeaningfulEvent(event) {
				continue
			}
			select {
			case signals <- struct{}{}:
			default:
			}
		case _, ok := <-fsWatcher.Errors:
			if !ok {
				return
			}
		}
	}
}
