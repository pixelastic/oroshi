package claude

import (
	"fmt"
	"strconv"
	"strings"
)

// CommandRunner executes a shell command and returns stdout.
type CommandRunner func(name string, args ...string) (string, error)

// FindClaudeWindow finds the Kitty window running Claude in the specified tab.
func FindClaudeWindow(run CommandRunner, currentTabID int) (int, error) {
	output, err := run("bin-zsh", "kitty-window-filter-process", "claude", "--tab", fmt.Sprintf("%d", currentTabID))
	if err != nil {
		return 0, fmt.Errorf("no Claude window found in tab %d", currentTabID)
	}

	windowID, err := strconv.Atoi(strings.TrimSpace(output))
	if err != nil {
		return 0, fmt.Errorf("parsing window ID %q: %w", output, err)
	}
	return windowID, nil
}

// SendReview sends the review command to a Claude window.
// Returns an error if there are no comments to send.
func SendReview(run CommandRunner, windowID int, commentCount int) error {
	if commentCount == 0 {
		return fmt.Errorf("no comments to send")
	}
	_, err := run("bin-zsh", "kitty-window-send-text", fmt.Sprintf("%d", windowID), "/git-file-watch-review\n")
	if err != nil {
		return fmt.Errorf("sending review to claude: %w", err)
	}
	return nil
}
