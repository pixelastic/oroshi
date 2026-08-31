package claude

import (
	"encoding/json"
	"fmt"
	"path/filepath"
)

// CommandRunner executes a shell command and returns stdout.
type CommandRunner func(name string, args ...string) (string, error)

type kittyOSWindow struct {
	Tabs []kittyTab `json:"tabs"`
}

type kittyTab struct {
	ID      int           `json:"id"`
	Windows []kittyWindow `json:"windows"`
}

type kittyWindow struct {
	ID                  int            `json:"id"`
	ForegroundProcesses []kittyProcess `json:"foreground_processes"`
}

type kittyProcess struct {
	Cmdline []string `json:"cmdline"`
}

// FindClaudeWindow finds the Kitty window running Claude in the specified tab.
func FindClaudeWindow(run CommandRunner, currentTabID int) (int, error) {
	output, err := run("kitty-remote", "ls")
	if err != nil {
		return 0, fmt.Errorf("querying kitty windows: %w", err)
	}

	windows, err := parseKittyWindows([]byte(output))
	if err != nil {
		return 0, fmt.Errorf("parsing kitty windows: %w", err)
	}

	for _, window := range windows {
		if window.tabID != currentTabID {
			continue
		}
		if hasClaudeProcess(window) {
			return window.id, nil
		}
	}

	return 0, fmt.Errorf("no Claude window found in tab %d", currentTabID)
}

// SendReview sends the review command to a Claude window.
// Returns an error if there are no comments to send.
func SendReview(run CommandRunner, windowID int, commentCount int) error {
	if commentCount == 0 {
		return fmt.Errorf("no comments to send")
	}
	_, err := run("kitty-window-send-text", fmt.Sprintf("%d", windowID), "/git-file-watch-review\n")
	if err != nil {
		return fmt.Errorf("sending review to claude: %w", err)
	}
	return nil
}

type flatWindow struct {
	id       int
	tabID    int
	commands []string
}

func parseKittyWindows(data []byte) ([]flatWindow, error) {
	var osWindows []kittyOSWindow
	if err := json.Unmarshal(data, &osWindows); err != nil {
		return nil, fmt.Errorf("unmarshaling kitty output: %w", err)
	}

	var result []flatWindow
	for _, osWindow := range osWindows {
		for _, tab := range osWindow.Tabs {
			for _, window := range tab.Windows {
				var commands []string
				for _, process := range window.ForegroundProcesses {
					if len(process.Cmdline) > 0 {
						commands = append(commands, filepath.Base(process.Cmdline[0]))
					}
				}
				result = append(result, flatWindow{
					id:       window.ID,
					tabID:    tab.ID,
					commands: commands,
				})
			}
		}
	}
	return result, nil
}

func hasClaudeProcess(window flatWindow) bool {
	for _, cmd := range window.commands {
		if cmd == "claude" {
			return true
		}
	}
	return false
}
